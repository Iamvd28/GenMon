/**
 * Scoring Engine for GenMon4 Contest Platform
 * Handles all scoring calculations for contest submissions
 */

class ScoringEngine {
  /**
   * Calculate accuracy score based on test case pass rate
   * @param {number} testCasesPassed - Number of test cases passed
   * @param {number} totalTestCases - Total number of test cases
   * @returns {number} Accuracy score between 0 and 1
   */
  static calculateAccuracyScore(testCasesPassed, totalTestCases) {
    if (totalTestCases <= 0) return 0;
    return Math.min(1, testCasesPassed / totalTestCases);
  }

  /**
   * Calculate speed score based on submission time relative to contest duration
   * @param {Date} submissionTime - When the submission was made
   * @param {Date} contestStartTime - When the contest started
   * @param {Date} contestEndTime - When the contest ends
   * @returns {number} Speed score between 0 and 1
   */
  static calculateSpeedScore(submissionTime, contestStartTime, contestEndTime) {
    const totalDuration = contestEndTime.getTime() - contestStartTime.getTime();
    const submissionDelay = submissionTime.getTime() - contestStartTime.getTime();
    
    if (totalDuration <= 0) return 1;
    
    // If submission is before contest starts, give full points
    if (submissionDelay < 0) return 1;
    
    // If submission is after contest ends, give no points
    if (submissionDelay > totalDuration) return 0;
    
    const normalizedDelay = submissionDelay / totalDuration;
    return Math.max(0, 1 - normalizedDelay);
  }

  /**
   * Calculate efficiency score based on execution time and memory usage
   * @param {number} executionTime - Execution time in milliseconds
   * @param {number} memoryUsage - Memory usage in KB
   * @param {number} baselineTime - Baseline execution time (default: 1000ms)
   * @param {number} baselineMemory - Baseline memory usage (default: 1024KB)
   * @returns {number} Efficiency score between 0 and 1
   */
  static calculateEfficiencyScore(executionTime, memoryUsage, baselineTime = 1000, baselineMemory = 1024) {
    // Time score: better score for faster execution
    const timeScore = Math.max(0, 1 - (executionTime / baselineTime));
    
    // Memory score: better score for lower memory usage
    const memoryScore = Math.max(0, 1 - (memoryUsage / baselineMemory));
    
    // Weighted combination (60% time, 40% memory)
    return (timeScore * 0.6) + (memoryScore * 0.4);
  }

  /**
   * Calculate composite score from individual component scores
   * @param {number} accuracy - Accuracy score (0-1)
   * @param {number} speed - Speed score (0-1)
   * @param {number} efficiency - Efficiency score (0-1)
   * @returns {number} Composite score (0-100)
   */
  static calculateCompositeScore(accuracy, speed, efficiency) {
    const accuracyWeight = 0.4;   // 40% weight
    const speedWeight = 0.35;     // 35% weight
    const efficiencyWeight = 0.25; // 25% weight
    
    const compositeScore = (accuracy * accuracyWeight * 100) + 
                          (speed * speedWeight * 100) + 
                          (efficiency * efficiencyWeight * 100);
    
    return Math.round(compositeScore * 100) / 100; // Round to 2 decimal places
  }

  /**
   * Calculate bonus points for early submission
   * @param {Date} submissionTime - When the submission was made
   * @param {Date} contestStartTime - When the contest started
   * @param {number} maxBonus - Maximum bonus points (default: 10)
   * @returns {number} Bonus points
   */
  static calculateEarlySubmissionBonus(submissionTime, contestStartTime, maxBonus = 10) {
    const submissionDelay = submissionTime.getTime() - contestStartTime.getTime();
    
    // No bonus for submissions before contest starts
    if (submissionDelay < 0) return 0;
    
    // Maximum bonus for submissions within first 10% of contest time
    const earlyThreshold = 600000; // 10 minutes in milliseconds
    
    if (submissionDelay <= earlyThreshold) {
      return maxBonus;
    }
    
    // Linear decrease in bonus after early threshold
    const lateThreshold = 3000000; // 50 minutes in milliseconds
    if (submissionDelay >= lateThreshold) {
      return 0;
    }
    
    const bonusRange = lateThreshold - earlyThreshold;
    const remainingTime = lateThreshold - submissionDelay;
    return Math.round((remainingTime / bonusRange) * maxBonus);
  }

  /**
   * Calculate penalty for multiple submissions
   * @param {number} submissionCount - Number of submissions by user
   * @param {number} maxSubmissions - Maximum allowed submissions (default: 3)
   * @param {number} penaltyPerExtra - Penalty per extra submission (default: 5)
   * @returns {number} Penalty points
   */
  static calculateMultipleSubmissionPenalty(submissionCount, maxSubmissions = 3, penaltyPerExtra = 5) {
    if (submissionCount <= maxSubmissions) return 0;
    
    const extraSubmissions = submissionCount - maxSubmissions;
    return extraSubmissions * penaltyPerExtra;
  }

  /**
   * Calculate final score with bonuses and penalties
   * @param {Object} submission - Submission object
   * @param {Object} contest - Contest object
   * @param {number} submissionCount - Number of user's submissions
   * @returns {Object} Final scoring results
   */
  static calculateFinalScore(submission, contest, submissionCount = 1) {
    const accuracy = this.calculateAccuracyScore(
      submission.testCasesPassed,
      submission.totalTestCases
    );
    
    const speed = this.calculateSpeedScore(
      submission.submittedAt,
      contest.startTime,
      contest.endTime
    );
    
    const efficiency = this.calculateEfficiencyScore(
      submission.executionTime,
      submission.memoryUsage
    );
    
    const compositeScore = this.calculateCompositeScore(accuracy, speed, efficiency);
    
    const earlyBonus = this.calculateEarlySubmissionBonus(
      submission.submittedAt,
      contest.startTime
    );
    
    const penalty = this.calculateMultipleSubmissionPenalty(submissionCount);
    
    const finalScore = Math.max(0, compositeScore + earlyBonus - penalty);
    
    return {
      accuracy,
      speed,
      efficiency,
      compositeScore,
      earlyBonus,
      penalty,
      finalScore: Math.round(finalScore * 100) / 100,
      breakdown: {
        accuracyPoints: Math.round(accuracy * 40),
        speedPoints: Math.round(speed * 35),
        efficiencyPoints: Math.round(efficiency * 25),
        earlyBonus,
        penalty
      }
    };
  }

  /**
   * Validate scoring parameters
   * @param {Object} params - Scoring parameters
   * @returns {Object} Validation result
   */
  static validateScoringParams(params) {
    const errors = [];
    
    if (params.testCasesPassed < 0) {
      errors.push('testCasesPassed cannot be negative');
    }
    
    if (params.totalTestCases <= 0) {
      errors.push('totalTestCases must be positive');
    }
    
    if (params.testCasesPassed > params.totalTestCases) {
      errors.push('testCasesPassed cannot exceed totalTestCases');
    }
    
    if (params.executionTime < 0) {
      errors.push('executionTime cannot be negative');
    }
    
    if (params.memoryUsage < 0) {
      errors.push('memoryUsage cannot be negative');
    }
    
    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * Get scoring weights for different contest types
   * @param {string} contestType - Type of contest
   * @returns {Object} Scoring weights
   */
  static getScoringWeights(contestType = 'coding') {
    const weights = {
      coding: {
        accuracy: 0.4,
        speed: 0.35,
        efficiency: 0.25
      },
      quiz: {
        accuracy: 0.7,
        speed: 0.3,
        efficiency: 0.0
      },
      sports: {
        accuracy: 0.5,
        speed: 0.5,
        efficiency: 0.0
      }
    };
    
    return weights[contestType] || weights.coding;
  }

  /**
   * Calculate ranking score for leaderboard sorting
   * @param {Object} submission - Submission object
   * @param {string} contestType - Type of contest
   * @returns {number} Ranking score
   */
  static calculateRankingScore(submission, contestType = 'coding') {
    const weights = this.getScoringWeights(contestType);
    
    const accuracyScore = submission.accuracy * weights.accuracy * 100;
    const speedScore = submission.speed * weights.speed * 100;
    const efficiencyScore = submission.efficiency * weights.efficiency * 100;
    
    return accuracyScore + speedScore + efficiencyScore;
  }
}

module.exports = ScoringEngine; 