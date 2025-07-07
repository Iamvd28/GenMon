const express = require('express');
const { ObjectId } = require('mongodb');
const Joi = require('joi');

const router = express.Router();

// Validation schemas
const contestSchema = Joi.object({
  title: Joi.string().required().min(3).max(100),
  type: Joi.string().valid('coding', 'quiz', 'sports').required(),
  category: Joi.string().required(),
  question: Joi.string().required(),
  testCases: Joi.array().items(Joi.object({
    input: Joi.string().required(),
    expectedOutput: Joi.string().required()
  })).min(1),
  maxParticipants: Joi.number().integer().min(1).max(1000),
  duration: Joi.number().integer().min(300).max(86400) // 5 minutes to 24 hours
});

// Get all contests with filtering
router.get('/', async (req, res) => {
  try {
    const { status, type, category, limit = 20, offset = 0 } = req.query;
    const db = req.app.locals.db;
    const filter = {};
    
    if (status) filter.status = status;
    if (type) filter.type = type;
    if (category) filter.category = category;

    const contests = await db.collection('contests')
      .find(filter)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset))
      .toArray();

    res.json(contests);
  } catch (error) {
    console.error('Error fetching contests:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get contest by ID
router.get('/:id', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const contest = await db.collection('contests').findOne({ 
      _id: new ObjectId(req.params.id) 
    });
    
    if (!contest) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    res.json(contest);
  } catch (error) {
    console.error('Error fetching contest:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new contest
router.post('/', async (req, res) => {
  try {
    const { error, value } = contestSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const db = req.app.locals.db;
    const contest = {
      ...value,
      createdBy: req.user.userId,
      participants: [],
      status: 'waiting',
      createdAt: new Date(),
      startTime: new Date(Date.now() + 60000), // Start in 1 minute
      endTime: new Date(Date.now() + 60000 + (value.duration * 1000))
    };

    const result = await db.collection('contests').insertOne(contest);
    contest._id = result.insertedId;

    // Emit new contest to all connected clients
    req.app.locals.io.emit('newContest', contest);

    res.status(201).json(contest);
  } catch (error) {
    console.error('Error creating contest:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Join contest
router.post('/:id/join', async (req, res) => {
  try {
    const contestId = new ObjectId(req.params.id);
    const userId = req.user.userId;
    const db = req.app.locals.db;

    const contest = await db.collection('contests').findOne({ _id: contestId });
    
    if (!contest) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    if (contest.participants.includes(userId)) {
      return res.status(400).json({ error: 'Already joined this contest' });
    }

    if (contest.participants.length >= contest.maxParticipants) {
      return res.status(400).json({ error: 'Contest is full' });
    }

    if (contest.status !== 'waiting' && contest.status !== 'live') {
      return res.status(400).json({ error: 'Cannot join this contest' });
    }

    await db.collection('contests').updateOne(
      { _id: contestId },
      { $push: { participants: userId } }
    );

    // Emit participant joined event
    req.app.locals.io.emit('participantJoined', { 
      contestId: req.params.id, 
      userId 
    });

    res.json({ message: 'Successfully joined contest' });
  } catch (error) {
    console.error('Error joining contest:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Leave contest
router.post('/:id/leave', async (req, res) => {
  try {
    const contestId = new ObjectId(req.params.id);
    const userId = req.user.userId;
    const db = req.app.locals.db;

    const contest = await db.collection('contests').findOne({ _id: contestId });
    
    if (!contest) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    if (!contest.participants.includes(userId)) {
      return res.status(400).json({ error: 'Not a participant in this contest' });
    }

    if (contest.status === 'completed') {
      return res.status(400).json({ error: 'Cannot leave completed contest' });
    }

    await db.collection('contests').updateOne(
      { _id: contestId },
      { $pull: { participants: userId } }
    );

    // Emit participant left event
    req.app.locals.io.emit('participantLeft', { 
      contestId: req.params.id, 
      userId 
    });

    res.json({ message: 'Successfully left contest' });
  } catch (error) {
    console.error('Error leaving contest:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get contest participants
router.get('/:id/participants', async (req, res) => {
  try {
    const contestId = new ObjectId(req.params.id);
    const db = req.app.locals.db;

    const contest = await db.collection('contests').findOne({ _id: contestId });
    
    if (!contest) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    // Get participant details
    const participants = await db.collection('users')
      .find({ _id: { $in: contest.participants.map(id => new ObjectId(id)) } })
      .project({ username: 1, displayName: 1, _id: 1 })
      .toArray();

    res.json(participants);
  } catch (error) {
    console.error('Error fetching participants:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get contest submissions
router.get('/:id/submissions', async (req, res) => {
  try {
    const contestId = req.params.id;
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
    console.error('Error fetching submissions:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update contest status (admin only)
router.put('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const contestId = new ObjectId(req.params.id);
    const db = req.app.locals.db;

    if (!['waiting', 'live', 'completed', 'cancelled'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const result = await db.collection('contests').updateOne(
      { _id: contestId },
      { $set: { status: status } }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    // Emit status change event
    req.app.locals.io.emit('contestStatusChanged', { 
      contestId: req.params.id, 
      status 
    });

    res.json({ message: 'Contest status updated successfully' });
  } catch (error) {
    console.error('Error updating contest status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get contest statistics
router.get('/:id/stats', async (req, res) => {
  try {
    const contestId = req.params.id;
    const db = req.app.locals.db;

    const contest = await db.collection('contests').findOne({ 
      _id: new ObjectId(contestId) 
    });

    if (!contest) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    // Get submission statistics
    const pipeline = [
      { $match: { contestId: contestId } },
      {
        $group: {
          _id: null,
          totalSubmissions: { $sum: 1 },
          avgScore: { $avg: '$compositeScore' },
          maxScore: { $max: '$compositeScore' },
          minScore: { $min: '$compositeScore' },
          avgAccuracy: { $avg: '$accuracy' },
          avgSpeed: { $avg: '$speed' },
          avgEfficiency: { $avg: '$efficiency' }
        }
      }
    ];

    const stats = await db.collection('submissions')
      .aggregate(pipeline)
      .toArray();

    const contestStats = stats[0] || {
      totalSubmissions: 0,
      avgScore: 0,
      maxScore: 0,
      minScore: 0,
      avgAccuracy: 0,
      avgSpeed: 0,
      avgEfficiency: 0
    };

    res.json({
      contest,
      stats: contestStats
    });
  } catch (error) {
    console.error('Error fetching contest stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router; 