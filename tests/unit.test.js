// unit.test.js - Unit tests for GenMon4 backend components
const { ScoringEngine } = require('../utils/scoring');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const jwt = require('jsonwebtoken');

describe('ScoringEngine Unit Tests', () => {
  describe('calculateAccuracyScore', () => {
    test('should return 1.0 for perfect accuracy', () => {
      const score = ScoringEngine.calculateAccuracyScore(5, 5);
      expect(score).toBe(1.0);
    });

    test('should return 0.0 for no correct answers', () => {
      const score = ScoringEngine.calculateAccuracyScore(0, 5);
      expect(score).toBe(0.0);
    });

    test('should return correct fraction for partial accuracy', () => {
      const score = ScoringEngine.calculateAccuracyScore(3, 5);
      expect(score).toBe(0.6);
    });

    test('should handle edge case of zero total test cases', () => {
      const score = ScoringEngine.calculateAccuracyScore(0, 0);
      expect(score).toBe(0.0);
    });

    test('should handle negative test cases passed', () => {
      const score = ScoringEngine.calculateAccuracyScore(-1, 5);
      expect(score).toBe(0.0);
    });
  });

  describe('calculateSpeedScore', () => {
    test('should return 1.0 for submission at contest start', () => {
      const startTime = new Date('2024-01-01T10:00:00Z');
      const endTime = new Date('2024-01-01T11:00:00Z');
      const submissionTime = new Date('2024-01-01T10:00:00Z');
      
      const score = ScoringEngine.calculateSpeedScore(submissionTime, startTime, endTime);
      expect(score).toBe(1.0);
    });

    test('should return 0.0 for submission at contest end', () => {
      const startTime = new Date('2024-01-01T10:00:00Z');
      const endTime = new Date('2024-01-01T11:00:00Z');
      const submissionTime = new Date('2024-01-01T11:00:00Z');
      
      const score = ScoringEngine.calculateSpeedScore(submissionTime, startTime, endTime);
      expect(score).toBe(0.0);
    });

    test('should return 0.5 for submission at halfway point', () => {
      const startTime = new Date('2024-01-01T10:00:00Z');
      const endTime = new Date('2024-01-01T11:00:00Z');
      const submissionTime = new Date('2024-01-01T10:30:00Z');
      
      const score = ScoringEngine.calculateSpeedScore(submissionTime, startTime, endTime);
      expect(score).toBe(0.5);
    });

    test('should return 1.0 for submission before contest starts', () => {
      const startTime = new Date('2024-01-01T10:00:00Z');
      const endTime = new Date('2024-01-01T11:00:00Z');
      const submissionTime = new Date('2024-01-01T09:30:00Z');
      
      const score = ScoringEngine.calculateSpeedScore(submissionTime, startTime, endTime);
      expect(score).toBe(1.0);
    });

    test('should handle zero duration contest', () => {
      const startTime = new Date('2024-01-01T10:00:00Z');
      const endTime = new Date('2024-01-01T10:00:00Z');
      const submissionTime = new Date('2024-01-01T10:00:00Z');
      
      const score = ScoringEngine.calculateSpeedScore(submissionTime, startTime, endTime);
      expect(score).toBe(1.0);
    });
  });

  describe('calculateEfficiencyScore', () => {
    test('should return 1.0 for optimal execution', () => {
      const score = ScoringEngine.calculateEfficiencyScore(0, 0, 1000, 1024);
      expect(score).toBe(1.0);
    });

    test('should return 0.0 for very poor execution', () => {
      const score = ScoringEngine.calculateEfficiencyScore(2000, 2048, 1000, 1024);
      expect(score).toBe(0.0);
    });

    test('should return correct weighted score', () => {
      const score = ScoringEngine.calculateEfficiencyScore(500, 512, 1000, 1024);
      // Time score: 1 - (500/1000) = 0.5
      // Memory score: 1 - (512/1024) = 0.5
      // Weighted: (0.5 * 0.6) + (0.5 * 0.4) = 0.5
      expect(score).toBe(0.5);
    });

    test('should handle custom baseline values', () => {
      const score = ScoringEngine.calculateEfficiencyScore(100, 200, 200, 400);
      expect(score).toBe(0.5);
    });

    test('should handle negative execution values', () => {
      const score = ScoringEngine.calculateEfficiencyScore(-100, -200, 1000, 1024);
      expect(score).toBe(1.0);
    });
  });

  describe('calculateCompositeScore', () => {
    test('should return 100 for perfect scores', () => {
      const score = ScoringEngine.calculateCompositeScore(1.0, 1.0, 1.0);
      expect(score).toBe(100.0);
    });

    test('should return 0 for zero scores', () => {
      const score = ScoringEngine.calculateCompositeScore(0.0, 0.0, 0.0);
      expect(score).toBe(0.0);
    });

    test('should apply correct weights', () => {
      const score = ScoringEngine.calculateCompositeScore(1.0, 0.5, 0.0);
      // Accuracy: 1.0 * 0.4 * 100 = 40
      // Speed: 0.5 * 0.35 * 100 = 17.5
      // Efficiency: 0.0 * 0.25 * 100 = 0
      // Total: 40 + 17.5 + 0 = 57.5
      expect(score).toBe(57.5);
    });

    test('should round to 2 decimal places', () => {
      const score = ScoringEngine.calculateCompositeScore(0.333333, 0.666666, 0.999999);
      expect(score).toBe(66.67);
    });
  });

  describe('calculateEarlySubmissionBonus', () => {
    test('should return max bonus for very early submission', () => {
      const startTime = new Date('2024-01-01T10:00:00Z');
      const submissionTime = new Date('2024-01-01T10:05:00Z'); // 5 minutes after start
      
      const bonus = ScoringEngine.calculateEarlySubmissionBonus(submissionTime, startTime, 10);
      expect(bonus).toBe(10);
    });

    test('should return 0 for late submission', () => {
      const startTime = new Date('2024-01-01T10:00:00Z');
      const submissionTime = new Date('2024-01-01T10:55:00Z'); // 55 minutes after start
      
      const bonus = ScoringEngine.calculateEarlySubmissionBonus(submissionTime, startTime, 10);
      expect(bonus).toBe(0);
    });

    test('should return 0 for submission before contest starts', () => {
      const startTime = new Date('2024-01-01T10:00:00Z');
      const submissionTime = new Date('2024-01-01T09:30:00Z'); // 30 minutes before start
      
      const bonus = ScoringEngine.calculateEarlySubmissionBonus(submissionTime, startTime, 10);
      expect(bonus).toBe(0);
    });
  });

  describe('calculateMultipleSubmissionPenalty', () => {
    test('should return 0 for submissions within limit', () => {
      const penalty = ScoringEngine.calculateMultipleSubmissionPenalty(2, 3);
      expect(penalty).toBe(0);
    });

    test('should return correct penalty for extra submissions', () => {
      const penalty = ScoringEngine.calculateMultipleSubmissionPenalty(5, 3, 5);
      // 2 extra submissions * 5 penalty = 10
      expect(penalty).toBe(10);
    });

    test('should handle custom penalty values', () => {
      const penalty = ScoringEngine.calculateMultipleSubmissionPenalty(10, 3, 2);
      // 7 extra submissions * 2 penalty = 14
      expect(penalty).toBe(14);
    });
  });

  describe('calculateFinalScore', () => {
    test('should calculate final score with bonuses and penalties', () => {
      const submission = {
        testCasesPassed: 5,
        totalTestCases: 5,
        submittedAt: new Date('2024-01-01T10:05:00Z'),
        executionTime: 500,
        memoryUsage: 512
      };

      const contest = {
        startTime: new Date('2024-01-01T10:00:00Z'),
        endTime: new Date('2024-01-01T11:00:00Z')
      };

      const result = ScoringEngine.calculateFinalScore(submission, contest, 1);

      expect(result.accuracy).toBe(1.0);
      expect(result.speed).toBeGreaterThan(0.9);
      expect(result.efficiency).toBeGreaterThan(0.5);
      expect(result.finalScore).toBeGreaterThan(0);
      expect(result.earlyBonus).toBe(10);
      expect(result.penalty).toBe(0);
    });
  });

  describe('validateScoringParams', () => {
    test('should validate correct parameters', () => {
      const params = {
        testCasesPassed: 3,
        totalTestCases: 5,
        executionTime: 100,
        memoryUsage: 512
      };

      const result = ScoringEngine.validateScoringParams(params);
      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    test('should detect negative test cases passed', () => {
      const params = {
        testCasesPassed: -1,
        totalTestCases: 5,
        executionTime: 100,
        memoryUsage: 512
      };

      const result = ScoringEngine.validateScoringParams(params);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('testCasesPassed cannot be negative');
    });

    test('should detect invalid total test cases', () => {
      const params = {
        testCasesPassed: 3,
        totalTestCases: 0,
        executionTime: 100,
        memoryUsage: 512
      };

      const result = ScoringEngine.validateScoringParams(params);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('totalTestCases must be positive');
    });

    test('should detect test cases passed exceeding total', () => {
      const params = {
        testCasesPassed: 6,
        totalTestCases: 5,
        executionTime: 100,
        memoryUsage: 512
      };

      const result = ScoringEngine.validateScoringParams(params);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('testCasesPassed cannot exceed totalTestCases');
    });
  });

  describe('getScoringWeights', () => {
    test('should return coding weights by default', () => {
      const weights = ScoringEngine.getScoringWeights();
      expect(weights.accuracy).toBe(0.4);
      expect(weights.speed).toBe(0.35);
      expect(weights.efficiency).toBe(0.25);
    });

    test('should return quiz weights for quiz contests', () => {
      const weights = ScoringEngine.getScoringWeights('quiz');
      expect(weights.accuracy).toBe(0.7);
      expect(weights.speed).toBe(0.3);
      expect(weights.efficiency).toBe(0.0);
    });

    test('should return sports weights for sports contests', () => {
      const weights = ScoringEngine.getScoringWeights('sports');
      expect(weights.accuracy).toBe(0.5);
      expect(weights.speed).toBe(0.5);
      expect(weights.efficiency).toBe(0.0);
    });

    test('should return coding weights for invalid contest type', () => {
      const weights = ScoringEngine.getScoringWeights('invalid');
      expect(weights.accuracy).toBe(0.4);
      expect(weights.speed).toBe(0.35);
      expect(weights.efficiency).toBe(0.25);
    });
  });

  describe('calculateRankingScore', () => {
    test('should calculate ranking score for coding contest', () => {
      const submission = {
        accuracy: 1.0,
        speed: 0.8,
        efficiency: 0.9
      };

      const score = ScoringEngine.calculateRankingScore(submission, 'coding');
      // Accuracy: 1.0 * 0.4 * 100 = 40
      // Speed: 0.8 * 0.35 * 100 = 28
      // Efficiency: 0.9 * 0.25 * 100 = 22.5
      // Total: 40 + 28 + 22.5 = 90.5
      expect(score).toBe(90.5);
    });

    test('should calculate ranking score for quiz contest', () => {
      const submission = {
        accuracy: 0.9,
        speed: 0.7,
        efficiency: 0.5
      };

      const score = ScoringEngine.calculateRankingScore(submission, 'quiz');
      // Accuracy: 0.9 * 0.7 * 100 = 63
      // Speed: 0.7 * 0.3 * 100 = 21
      // Efficiency: 0.5 * 0.0 * 100 = 0
      // Total: 63 + 21 + 0 = 84
      expect(score).toBe(84);
    });
  });
});

describe('Authentication Middleware Unit Tests', () => {
  let mockReq, mockRes, mockNext;

  beforeEach(() => {
    mockReq = {
      headers: {},
      user: null
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    mockNext = jest.fn();
  });

  describe('authenticateToken', () => {
    test('should call next() for valid token', () => {
      const token = jwt.sign({ userId: 'test123' }, 'test-secret');
      mockReq.headers.authorization = `Bearer ${token}`;

      authenticateToken(mockReq, mockRes, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockReq.user).toBeDefined();
      expect(mockReq.user.userId).toBe('test123');
    });

    test('should return 401 for missing token', () => {
      authenticateToken(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({ error: 'Access token required' });
      expect(mockNext).not.toHaveBeenCalled();
    });

    test('should return 403 for invalid token', () => {
      mockReq.headers.authorization = 'Bearer invalid-token';

      authenticateToken(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({ error: 'Invalid token' });
      expect(mockNext).not.toHaveBeenCalled();
    });

    test('should return 401 for expired token', () => {
      const token = jwt.sign({ userId: 'test123' }, 'test-secret', { expiresIn: '0s' });
      mockReq.headers.authorization = `Bearer ${token}`;

      // Wait for token to expire
      setTimeout(() => {
        authenticateToken(mockReq, mockRes, mockNext);
        expect(mockRes.status).toHaveBeenCalledWith(403);
        expect(mockRes.json).toHaveBeenCalledWith({ error: 'Invalid token' });
      }, 100);
    });
  });
}); 