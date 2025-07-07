const request = require('supertest');
const { MongoMemoryServer } = require('mongodb-memory-server');
const { MongoClient } = require('mongodb');
const jwt = require('jsonwebtoken');

// Import your server (you'll need to modify server.js to export the app)
const app = require('../server');

describe('GenMon4 Backend API', () => {
  let mongoServer;
  let mongoUri;
  let client;
  let db;
  let authToken;

  beforeAll(async () => {
    // Start in-memory MongoDB instance
    mongoServer = await MongoMemoryServer.create();
    mongoUri = mongoServer.getUri();
    
    // Connect to test database
    client = new MongoClient(mongoUri);
    await client.connect();
    db = client.db();
    
    // Create auth token for testing
    authToken = jwt.sign(
      { userId: 'testuser123', username: 'testuser' },
      process.env.JWT_SECRET || 'test-secret',
      { expiresIn: '1h' }
    );
  });

  afterAll(async () => {
    await client.close();
    await mongoServer.stop();
  });

  beforeEach(async () => {
    // Clear collections before each test
    await db.collection('contests').deleteMany({});
    await db.collection('submissions').deleteMany({});
    await db.collection('leaderboards').deleteMany({});
  });

  describe('Contest Management', () => {
    test('POST /api/contests - Create new contest', async () => {
      const contestData = {
        title: 'Test Algorithm Challenge',
        type: 'coding',
        category: 'algorithms',
        question: 'Write a function to reverse a string',
        testCases: [
          { input: 'hello', expectedOutput: 'olleh' },
          { input: 'world', expectedOutput: 'dlrow' }
        ],
        maxParticipants: 10,
        duration: 3600
      };

      const response = await request(app)
        .post('/api/contests')
        .set('Authorization', `Bearer ${authToken}`)
        .send(contestData)
        .expect(201);

      expect(response.body).toMatchObject({
        title: contestData.title,
        type: contestData.type,
        category: contestData.category,
        status: 'waiting',
        participants: []
      });
      expect(response.body._id).toBeDefined();
    });

    test('POST /api/contests - Validation error for invalid data', async () => {
      const invalidData = {
        title: 'A', // Too short
        type: 'invalid-type',
        category: '',
        question: ''
      };

      const response = await request(app)
        .post('/api/contests')
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidData)
        .expect(400);

      expect(response.body.error).toBeDefined();
    });

    test('GET /api/contests - Fetch contests', async () => {
      // Create test contest
      await db.collection('contests').insertOne({
        title: 'Test Contest',
        type: 'coding',
        category: 'algorithms',
        status: 'waiting',
        participants: [],
        createdAt: new Date()
      });

      const response = await request(app)
        .get('/api/contests')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBe(1);
      expect(response.body[0].title).toBe('Test Contest');
    });

    test('GET /api/contests/:id - Fetch specific contest', async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Specific Contest',
        type: 'coding',
        category: 'algorithms',
        status: 'waiting',
        participants: []
      });

      const response = await request(app)
        .get(`/api/contests/${contest.insertedId}`)
        .expect(200);

      expect(response.body.title).toBe('Specific Contest');
      expect(response.body._id).toBe(contest.insertedId.toString());
    });

    test('POST /api/contests/:id/join - Join contest', async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Join Contest Test',
        type: 'coding',
        status: 'waiting',
        participants: [],
        maxParticipants: 10
      });

      const response = await request(app)
        .post(`/api/contests/${contest.insertedId}/join`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.message).toBe('Successfully joined contest');

      // Verify user was added to participants
      const updatedContest = await db.collection('contests').findOne({
        _id: contest.insertedId
      });
      expect(updatedContest.participants).toContain('testuser123');
    });

    test('POST /api/contests/:id/join - Cannot join twice', async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Duplicate Join Test',
        type: 'coding',
        status: 'waiting',
        participants: ['testuser123'],
        maxParticipants: 10
      });

      const response = await request(app)
        .post(`/api/contests/${contest.insertedId}/join`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(400);

      expect(response.body.error).toBe('Already joined this contest');
    });
  });

  describe('Submission Processing', () => {
    let contestId;

    beforeEach(async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Submission Test Contest',
        type: 'coding',
        status: 'live',
        participants: ['testuser123'],
        testCases: [
          { input: 'hello', expectedOutput: 'olleh' },
          { input: 'world', expectedOutput: 'dlrow' }
        ],
        startTime: new Date(Date.now() - 60000), // Started 1 minute ago
        endTime: new Date(Date.now() + 3600000)  // Ends in 1 hour
      });
      contestId = contest.insertedId.toString();
    });

    test('POST /api/submissions - Valid submission', async () => {
      const submissionData = {
        contestId: contestId,
        code: 'def solution(s): return s[::-1]',
        language: 'Python',
        languageId: 71
      };

      // Mock the Judge0 API calls
      const mockAxios = require('axios');
      jest.mock('axios');
      
      mockAxios.post.mockResolvedValue({
        data: { token: 'test-token-123' }
      });
      
      mockAxios.get.mockResolvedValue({
        data: {
          status: { id: 3 }, // Accepted
          stdout: Buffer.from('olleh').toString('base64'),
          time: '0.001',
          memory: 1024
        }
      });

      const response = await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(submissionData)
        .expect(201);

      expect(response.body).toMatchObject({
        contestId: contestId,
        userId: 'testuser123',
        username: 'testuser',
        code: submissionData.code,
        language: submissionData.language
      });
      expect(response.body.compositeScore).toBeGreaterThan(0);
    });

    test('POST /api/submissions - Invalid contest', async () => {
      const submissionData = {
        contestId: '507f1f77bcf86cd799439011', // Non-existent ID
        code: 'print("hello")',
        language: 'Python',
        languageId: 71
      };

      const response = await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(submissionData)
        .expect(404);

      expect(response.body.error).toBe('Contest not found');
    });

    test('POST /api/submissions - Not a participant', async () => {
      // Create contest without the test user as participant
      const contest = await db.collection('contests').insertOne({
        title: 'Non-participant Contest',
        type: 'coding',
        status: 'live',
        participants: ['otheruser'],
        testCases: [{ input: 'test', expectedOutput: 'test' }]
      });

      const submissionData = {
        contestId: contest.insertedId.toString(),
        code: 'print("hello")',
        language: 'Python',
        languageId: 71
      };

      const response = await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(submissionData)
        .expect(403);

      expect(response.body.error).toBe('Not a participant in this contest');
    });
  });

  describe('Leaderboard System', () => {
    let contestId;

    beforeEach(async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Leaderboard Test Contest',
        type: 'coding',
        status: 'live',
        participants: ['user1', 'user2', 'user3']
      });
      contestId = contest.insertedId.toString();

      // Insert test submissions
      await db.collection('submissions').insertMany([
        {
          contestId: contestId,
          userId: 'user1',
          username: 'user1',
          compositeScore: 95.5,
          accuracy: 1.0,
          speed: 0.9,
          efficiency: 0.95,
          submittedAt: new Date('2024-01-01T10:15:00Z')
        },
        {
          contestId: contestId,
          userId: 'user2',
          username: 'user2',
          compositeScore: 87.2,
          accuracy: 0.8,
          speed: 0.95,
          efficiency: 0.88,
          submittedAt: new Date('2024-01-01T10:10:00Z')
        },
        {
          contestId: contestId,
          userId: 'user3',
          username: 'user3',
          compositeScore: 92.1,
          accuracy: 0.9,
          speed: 0.85,
          efficiency: 0.92,
          submittedAt: new Date('2024-01-01T10:20:00Z')
        }
      ]);

      // Update leaderboard
      await db.collection('leaderboards').insertOne({
        contestId: contestId,
        entries: [
          {
            userId: 'user1',
            username: 'user1',
            compositeScore: 95.5,
            rank: 1
          },
          {
            userId: 'user3',
            username: 'user3',
            compositeScore: 92.1,
            rank: 2
          },
          {
            userId: 'user2',
            username: 'user2',
            compositeScore: 87.2,
            rank: 3
          }
        ],
        lastUpdated: new Date()
      });
    });

    test('GET /api/leaderboard/contest/:contestId - Fetch contest leaderboard', async () => {
      const response = await request(app)
        .get(`/api/leaderboard/contest/${contestId}`)
        .expect(200);

      expect(response.body.entries).toHaveLength(3);
      expect(response.body.entries[0].username).toBe('user1');
      expect(response.body.entries[0].rank).toBe(1);
      expect(response.body.entries[0].compositeScore).toBe(95.5);
    });

    test('GET /api/leaderboard/overall - Fetch overall leaderboard', async () => {
      const response = await request(app)
        .get('/api/leaderboard/overall')
        .expect(200);

      expect(Array.isArray(response.body.entries)).toBe(true);
      // Should be sorted by total score in descending order
      if (response.body.entries.length > 1) {
        expect(response.body.entries[0].totalScore)
          .toBeGreaterThanOrEqual(response.body.entries[1].totalScore);
      }
    });
  });

  describe('User Statistics', () => {
    beforeEach(async () => {
      // Insert test submissions for user stats
      await db.collection('submissions').insertMany([
        {
          userId: 'testuser123',
          compositeScore: 85.0,
          accuracy: 0.8,
          speed: 0.9,
          efficiency: 0.85
        },
        {
          userId: 'testuser123',
          compositeScore: 92.5,
          accuracy: 0.95,
          speed: 0.85,
          efficiency: 0.9
        },
        {
          userId: 'testuser123',
          compositeScore: 78.2,
          accuracy: 0.7,
          speed: 0.95,
          efficiency: 0.8
        }
      ]);

      await db.collection('contests').insertOne({
        participants: ['testuser123', 'otheruser']
      });
    });

    test('GET /api/users/:userId/stats - Fetch user statistics', async () => {
      const response = await request(app)
        .get('/api/users/testuser123/stats')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toMatchObject({
        totalSubmissions: 3,
        contestsParticipated: 1,
        bestScore: 92.5
      });
      expect(response.body.avgCompositeScore).toBeCloseTo(85.23, 1);
      expect(response.body.avgAccuracy).toBeCloseTo(0.82, 2);
    });
  });

  describe('Authentication', () => {
    test('Protected routes require authentication', async () => {
      const response = await request(app)
        .post('/api/contests')
        .send({
          title: 'Test Contest',
          type: 'coding',
          category: 'algorithms',
          question: 'Test question',
          testCases: [],
          maxParticipants: 10,
          duration: 3600
        })
        .expect(401);

      expect(response.body.error).toBe('Access token required');
    });

    test('Invalid token returns 403', async () => {
      const response = await request(app)
        .post('/api/contests')
        .set('Authorization', 'Bearer invalid-token')
        .send({
          title: 'Test Contest',
          type: 'coding',
          category: 'algorithms',
          question: 'Test question',
          testCases: [],
          maxParticipants: 10,
          duration: 3600
        })
        .expect(403);

      expect(response.body.error).toBe('Invalid token');
    });
  });

  describe('Health Check', () => {
    test('GET /api/health - Health check endpoint', async () => {
      const response = await request(app)
        .get('/api/health')
        .expect(200);

      expect(response.body).toMatchObject({
        status: 'OK'
      });
      expect(response.body.timestamp).toBeDefined();
      expect(response.body.uptime).toBeGreaterThan(0);
    });
  });

  describe('Scoring Engine', () => {
    // Import the ScoringEngine class from your server file
    const ScoringEngine = require('../server').ScoringEngine;

    test('calculateAccuracyScore - Perfect accuracy', () => {
      const score = ScoringEngine.calculateAccuracyScore(5, 5);
      expect(score).toBe(1.0);
    });

    test('calculateAccuracyScore - Partial accuracy', () => {
      const score = ScoringEngine.calculateAccuracyScore(3, 5);
      expect(score).toBe(0.6);
    });

    test('calculateSpeedScore - Early submission', () => {
      const contestStart = new Date('2024-01-01T10:00:00Z');
      const contestEnd = new Date('2024-01-01T11:00:00Z');
      const submissionTime = new Date('2024-01-01T10:15:00Z');
      
      const score = ScoringEngine.calculateSpeedScore(
        submissionTime, contestStart, contestEnd
      );
      expect(score).toBeCloseTo(0.75, 2);
    });

    test('calculateEfficiencyScore - Efficient execution', () => {
      const score = ScoringEngine.calculateEfficiencyScore(
        500, 512, 1000, 1024
      );
      expect(score).toBeGreaterThan(0.5);
    });

    test('calculateCompositeScore - Weighted combination', () => {
      const score = ScoringEngine.calculateCompositeScore(1.0, 0.8, 0.9);
      expect(score).toBeCloseTo(90.0, 1);
    });
  });

  describe('Rate Limiting', () => {
    test('Submission rate limiting', async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Rate Limit Test',
        type: 'coding',
        status: 'live',
        participants: ['testuser123'],
        testCases: [{ input: 'test', expectedOutput: 'test' }]
      });

      const submissionData = {
        contestId: contest.insertedId.toString(),
        code: 'print("test")',
        language: 'Python',
        languageId: 71
      };

      // Make multiple rapid submissions (should hit rate limit)
      const promises = Array(10).fill().map(() =>
        request(app)
          .post('/api/submissions')
          .set('Authorization', `Bearer ${authToken}`)
          .send(submissionData)
      );

      const responses = await Promise.all(promises);
      
      // Some requests should be rate limited (429 status)
      const rateLimitedResponses = responses.filter(r => r.status === 429);
      expect(rateLimitedResponses.length).toBeGreaterThan(0);
    });
  });
});

// Integration tests for WebSocket functionality
describe('WebSocket Integration', () => {
  const io = require('socket.io-client');
  let clientSocket;
  let serverSocket;

  beforeAll((done) => {
    // Start server and create client connection
    const server = require('http').createServer();
    const ioServer = require('socket.io')(server);
    
    server.listen(() => {
      const port = server.address().port;
      clientSocket = io(`http://localhost:${port}`);
      
      ioServer.on('connection', (socket) => {
        serverSocket = socket;
      });
      
      clientSocket.on('connect', done);
    });
  });

  afterAll(() => {
    if (clientSocket) clientSocket.close();
  });

  test('Socket can join and leave contest rooms', (done) => {
    const contestId = 'test-contest-123';
    
    clientSocket.emit('joinContest', contestId);
    
    setTimeout(() => {
      clientSocket.emit('leaveContest', contestId);
      done();
    }, 100);
  });

  test('Real-time leaderboard updates', (done) => {
    const testLeaderboard = {
      contestId: 'test-contest',
      leaderboard: [
        { userId: 'user1', username: 'user1', rank: 1, compositeScore: 95.5 }
      ]
    };

    clientSocket.on('leaderboardUpdate', (data) => {
      expect(data.contestId).toBe(testLeaderboard.contestId);
      expect(data.leaderboard).toEqual(testLeaderboard.leaderboard);
      done();
    });

    // Simulate server emitting leaderboard update
    serverSocket.emit('leaderboardUpdate', testLeaderboard);
  });
}); 