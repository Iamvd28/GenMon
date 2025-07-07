const express = require('express');
const { ObjectId } = require('mongodb');
const Joi = require('joi');
const axios = require('axios');

const router = express.Router();

// Validation schemas
const submissionSchema = Joi.object({
  contestId: Joi.string().required(),
  code: Joi.string().required().max(50000),
  language: Joi.string().required(),
  languageId: Joi.number().integer().required()
});

// Scoring algorithms
class ScoringEngine {
  static calculateAccuracyScore(testCasesPassed, totalTestCases) {
    return totalTestCases > 0 ? testCasesPassed / totalTestCases : 0;
  }

  static calculateSpeedScore(submissionTime, contestStartTime, contestEndTime) {
    const totalDuration = contestEndTime - contestStartTime;
    const submissionDelay = submissionTime - contestStartTime;
    
    if (totalDuration <= 0) return 1;
    
    const normalizedDelay = submissionDelay / totalDuration;
    return Math.max(0, 1 - normalizedDelay);
  }

  static calculateEfficiencyScore(executionTime, memoryUsage, baselineTime = 1000, baselineMemory = 1024) {
    const timeScore = Math.max(0, 1 - (executionTime / baselineTime));
    const memoryScore = Math.max(0, 1 - (memoryUsage / baselineMemory));
    return (timeScore * 0.6) + (memoryScore * 0.4);
  }

  static calculateCompositeScore(accuracy, speed, efficiency) {
    const accuracyWeight = 0.4;
    const speedWeight = 0.35;
    const efficiencyWeight = 0.25;
    
    return (accuracy * accuracyWeight * 100) + 
           (speed * speedWeight * 100) + 
           (efficiency * efficiencyWeight * 100);
  }
}

// Code execution function
async function executeCode(code, languageId, testCases, config) {
  const results = {
    testCasesPassed: 0,
    executionTime: 0,
    memoryUsage: 0,
    testResults: []
  };

  try {
    for (const testCase of testCases) {
      const payload = {
        source_code: Buffer.from(code).toString('base64'),
        language_id: languageId,
        stdin: Buffer.from(testCase.input).toString('base64'),
        expected_output: Buffer.from(testCase.expectedOutput).toString('base64')
      };

      // Submit to Judge0
      const submitResponse = await axios.post(
        `${config.JUDGE0_API_URL}/submissions`,
        payload,
        {
          headers: {
            'X-RapidAPI-Key': config.JUDGE0_API_KEY,
            'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com',
            'Content-Type': 'application/json'
          }
        }
      );

      const token = submitResponse.data.token;

      // Wait for execution and get result
      let executionResult;
      let attempts = 0;
      const maxAttempts = 30;

      do {
        await new Promise(resolve => setTimeout(resolve, 1000));
        const resultResponse = await axios.get(
          `${config.JUDGE0_API_URL}/submissions/${token}`,
          {
            headers: {
              'X-RapidAPI-Key': config.JUDGE0_API_KEY,
              'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com'
            }
          }
        );
        executionResult = resultResponse.data;
        attempts++;
      } while (executionResult.status.id <= 2 && attempts < maxAttempts);

      const testResult = {
        input: testCase.input,
        expectedOutput: testCase.expectedOutput,
        actualOutput: executionResult.stdout ? Buffer.from(executionResult.stdout, 'base64').toString() : '',
        passed: executionResult.status.id === 3,
        executionTime: parseFloat(executionResult.time) || 0,
        memory: parseInt(executionResult.memory) || 0,
        status: executionResult.status.description
      };

      results.testResults.push(testResult);
      results.executionTime = Math.max(results.executionTime, testResult.executionTime);
      results.memoryUsage = Math.max(results.memoryUsage, testResult.memory);

      if (testResult.passed) {
        results.testCasesPassed++;
      }
    }
  } catch (error) {
    console.error('Code execution error:', error);
    throw new Error('Code execution failed');
  }

  return results;
}

// Leaderboard update function
async function updateLeaderboard(contestId, db, io) {
  try {
    // Get all submissions for this contest
    const submissions = await db.collection('submissions')
      .find({ contestId: contestId })
      .toArray();

    // Group by user and get best submission for each user
    const userBestSubmissions = {};
    submissions.forEach(submission => {
      const userId = submission.userId;
      if (!userBestSubmissions[userId] || 
          submission.compositeScore > userBestSubmissions[userId].compositeScore) {
        userBestSubmissions[userId] = submission;
      }
    });

    // Sort by composite score, then by submission time
    const leaderboardEntries = Object.values(userBestSubmissions)
      .sort((a, b) => {
        if (b.compositeScore !== a.compositeScore) {
          return b.compositeScore - a.compositeScore;
        }
        return new Date(a.submittedAt) - new Date(b.submittedAt);
      })
      .map((submission, index) => ({
        userId: submission.userId,
        username: submission.username,
        compositeScore: submission.compositeScore,
        accuracy: submission.accuracy,
        speed: submission.speed,
        efficiency: submission.efficiency,
        submittedAt: submission.submittedAt,
        rank: index + 1
      }));

    // Update leaderboard collection
    await db.collection('leaderboards').updateOne(
      { contestId: contestId },
      {
        $set: {
          contestId: contestId,
          entries: leaderboardEntries,
          lastUpdated: new Date()
        }
      },
      { upsert: true }
    );

    // Emit leaderboard update
    io.emit('leaderboardUpdate', { contestId, leaderboard: leaderboardEntries });

    console.log(`Leaderboard updated for contest ${contestId}`);
  } catch (error) {
    console.error('Error updating leaderboard:', error);
  }
}

// Submit code/answer
router.post('/', async (req, res) => {
  try {
    const { error: validationError, value } = submissionSchema.validate(req.body);
    if (validationError) {
      return res.status(400).json({ error: validationError.details[0].message });
    }

    const { contestId, code, language, languageId } = value;
    const userId = req.user.userId;
    const db = req.app.locals.db;
    const io = req.app.locals.io;
    const config = req.app.locals.config;

    // Verify contest exists and user is participant
    const contest = await db.collection('contests').findOne({ 
      _id: new ObjectId(contestId) 
    });

    if (!contest) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    if (!contest.participants.includes(userId)) {
      return res.status(403).json({ error: 'Not a participant in this contest' });
    }

    if (contest.status !== 'live') {
      return res.status(400).json({ error: 'Contest is not live' });
    }

    // Check if user already submitted (optional - remove if multiple submissions allowed)
    const existingSubmission = await db.collection('submissions').findOne({
      contestId: contestId,
      userId: userId
    });

    if (existingSubmission) {
      return res.status(400).json({ error: 'Already submitted for this contest' });
    }

    // Execute code using Judge0
    const executionResult = await executeCode(code, languageId, contest.testCases, config);

    // Calculate scores
    const submissionTime = new Date();
    const accuracy = ScoringEngine.calculateAccuracyScore(
      executionResult.testCasesPassed,
      contest.testCases.length
    );
    const speed = ScoringEngine.calculateSpeedScore(
      submissionTime,
      contest.startTime,
      contest.endTime
    );
    const efficiency = ScoringEngine.calculateEfficiencyScore(
      executionResult.executionTime,
      executionResult.memoryUsage
    );
    const compositeScore = ScoringEngine.calculateCompositeScore(accuracy, speed, efficiency);

    // Create submission record
    const submission = {
      contestId: contestId,
      userId: userId,
      username: req.user.username,
      code: code,
      language: language,
      submittedAt: submissionTime,
      executionTime: executionResult.executionTime,
      memoryUsage: executionResult.memoryUsage,
      testCasesPassed: executionResult.testCasesPassed,
      totalTestCases: contest.testCases.length,
      accuracy: accuracy,
      speed: speed,
      efficiency: efficiency,
      compositeScore: compositeScore,
      testResults: executionResult.testResults
    };

    const result = await db.collection('submissions').insertOne(submission);
    submission._id = result.insertedId;

    // Update leaderboard
    await updateLeaderboard(contestId, db, io);

    // Emit real-time update
    io.emit('newSubmission', { contestId, submission });

    res.status(201).json(submission);
  } catch (error) {
    console.error('Error processing submission:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get submission by ID
router.get('/:id', async (req, res) => {
  try {
    const submissionId = new ObjectId(req.params.id);
    const db = req.app.locals.db;

    const submission = await db.collection('submissions').findOne({ _id: submissionId });

    if (!submission) {
      return res.status(404).json({ error: 'Submission not found' });
    }

    // Check if user can view this submission
    if (submission.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json(submission);
  } catch (error) {
    console.error('Error fetching submission:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user's submissions for a contest
router.get('/contest/:contestId/user/:userId', async (req, res) => {
  try {
    const { contestId, userId } = req.params;
    const db = req.app.locals.db;

    // Check if user can view submissions (own submissions or admin)
    if (userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const submissions = await db.collection('submissions')
      .find({ 
        contestId: contestId,
        userId: userId 
      })
      .sort({ submittedAt: -1 })
      .toArray();

    res.json(submissions);
  } catch (error) {
    console.error('Error fetching user submissions:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all submissions for a contest (admin only)
router.get('/contest/:contestId', async (req, res) => {
  try {
    const contestId = req.params.contestId;
    const { limit = 50, offset = 0 } = req.query;
    const db = req.app.locals.db;

    const submissions = await db.collection('submissions')
      .find({ contestId: contestId })
      .sort({ submittedAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset))
      .project({ code: 0 }) // Don't send code in list view
      .toArray();

    res.json(submissions);
  } catch (error) {
    console.error('Error fetching contest submissions:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user's submission statistics
router.get('/user/:userId/stats', async (req, res) => {
  try {
    const userId = req.params.userId;
    const db = req.app.locals.db;

    // Check if user can view stats (own stats or admin)
    if (userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Get user's submission statistics
    const pipeline = [
      { $match: { userId: userId } },
      {
        $group: {
          _id: null,
          totalSubmissions: { $sum: 1 },
          avgCompositeScore: { $avg: '$compositeScore' },
          avgAccuracy: { $avg: '$accuracy' },
          avgSpeed: { $avg: '$speed' },
          avgEfficiency: { $avg: '$efficiency' },
          bestScore: { $max: '$compositeScore' },
          contestsParticipated: { $addToSet: '$contestId' }
        }
      },
      {
        $project: {
          totalSubmissions: 1,
          avgCompositeScore: { $round: ['$avgCompositeScore', 2] },
          avgAccuracy: { $round: ['$avgAccuracy', 3] },
          avgSpeed: { $round: ['$avgSpeed', 3] },
          avgEfficiency: { $round: ['$avgEfficiency', 3] },
          bestScore: { $round: ['$bestScore', 2] },
          contestsParticipated: { $size: '$contestsParticipated' }
        }
      }
    ];

    const stats = await db.collection('submissions')
      .aggregate(pipeline)
      .toArray();

    const userStats = stats[0] || {
      totalSubmissions: 0,
      avgCompositeScore: 0,
      avgAccuracy: 0,
      avgSpeed: 0,
      avgEfficiency: 0,
      bestScore: 0,
      contestsParticipated: 0
    };

    res.json(userStats);
  } catch (error) {
    console.error('Error fetching user stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router; 