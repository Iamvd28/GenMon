// integration.test.js - Integration tests for GenMon4 backend
const request = require('supertest');
const { MongoMemoryServer } = require('mongodb-memory-server');
const { MongoClient } = require('mongodb');
const jwt = require('jsonwebtoken');
const io = require('socket.io-client');

// Import your server
const app = require('../server');

describe('GenMon4 Backend Integration Tests', () => {
  let mongoServer;
  let mongoUri;
  let client;
  let db;
  let authToken;
  let contestId;

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
      { userId: 'integrationuser', username: 'integrationuser' },
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
    await db.collection('users').deleteMany({});
  });

  describe('End-to-End Contest Flow', () => {
    test('Complete contest lifecycle: create → join → submit → leaderboard', async () => {
      // Step 1: Create a contest
      const contestData = {
        title: 'Integration Test Contest',
        type: 'coding',
        category: 'algorithms',
        question: 'Write a function to find the maximum element in an array',
        testCases: [
          { input: '[1, 2, 3, 4, 5]', expectedOutput: '5' },
          { input: '[10, 5, 8, 12, 3]', expectedOutput: '12' }
        ],
        maxParticipants: 5,
        duration: 1800
      };

      const createResponse = await request(app)
        .post('/api/contests')
        .set('Authorization', `Bearer ${authToken}`)
        .send(contestData)
        .expect(201);

      contestId = createResponse.body._id;
      expect(createResponse.body.status).toBe('waiting');

      // Step 2: Join the contest
      const joinResponse = await request(app)
        .post(`/api/contests/${contestId}/join`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(joinResponse.body.message).toBe('Successfully joined contest');

      // Step 3: Update contest status to live (simulate contest start)
      await db.collection('contests').updateOne(
        { _id: contestId },
        { 
          $set: { 
            status: 'live',
            startTime: new Date(Date.now() - 60000), // Started 1 minute ago
            endTime: new Date(Date.now() + 1800000)  // Ends in 30 minutes
          }
        }
      );

      // Step 4: Submit code
      const submissionData = {
        contestId: contestId,
        code: 'def solution(arr): return max(arr)',
        language: 'Python',
        languageId: 71
      };

      // Mock Judge0 API responses
      const mockAxios = require('axios');
      jest.mock('axios');
      
      mockAxios.post.mockResolvedValue({
        data: { token: 'test-token-123' }
      });
      
      mockAxios.get.mockResolvedValue({
        data: {
          status: { id: 3 }, // Accepted
          stdout: Buffer.from('5').toString('base64'),
          time: '0.002',
          memory: 1024
        }
      });

      const submitResponse = await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(submissionData)
        .expect(201);

      expect(submitResponse.body.compositeScore).toBeGreaterThan(0);
      expect(submitResponse.body.testCasesPassed).toBe(1);

      // Step 5: Check leaderboard
      const leaderboardResponse = await request(app)
        .get(`/api/leaderboard/contest/${contestId}`)
        .expect(200);

      expect(leaderboardResponse.body.entries).toHaveLength(1);
      expect(leaderboardResponse.body.entries[0].userId).toBe('integrationuser');
      expect(leaderboardResponse.body.entries[0].rank).toBe(1);

      // Step 6: Complete contest
      await db.collection('contests').updateOne(
        { _id: contestId },
        { $set: { status: 'completed' } }
      );

      const finalContestResponse = await request(app)
        .get(`/api/contests/${contestId}`)
        .expect(200);

      expect(finalContestResponse.body.status).toBe('completed');
    });
  });

  describe('Multi-User Contest Simulation', () => {
    let contestId;
    let user1Token, user2Token, user3Token;

    beforeEach(async () => {
      // Create multiple user tokens
      user1Token = jwt.sign(
        { userId: 'user1', username: 'user1' },
        process.env.JWT_SECRET || 'test-secret',
        { expiresIn: '1h' }
      );
      user2Token = jwt.sign(
        { userId: 'user2', username: 'user2' },
        process.env.JWT_SECRET || 'test-secret',
        { expiresIn: '1h' }
      );
      user3Token = jwt.sign(
        { userId: 'user3', username: 'user3' },
        process.env.JWT_SECRET || 'test-secret',
        { expiresIn: '1h' }
      );

      // Create contest
      const contest = await db.collection('contests').insertOne({
        title: 'Multi-User Contest',
        type: 'coding',
        category: 'algorithms',
        status: 'live',
        participants: ['user1', 'user2', 'user3'],
        testCases: [
          { input: 'hello', expectedOutput: 'olleh' }
        ],
        startTime: new Date(Date.now() - 300000), // Started 5 minutes ago
        endTime: new Date(Date.now() + 1800000)   // Ends in 30 minutes
      });
      contestId = contest.insertedId.toString();
    });

    test('Multiple users submitting and leaderboard ranking', async () => {
      // Mock Judge0 API
      const mockAxios = require('axios');
      jest.mock('axios');
      
      mockAxios.post.mockResolvedValue({
        data: { token: 'test-token' }
      });

      // User 1 submits first (fastest)
      mockAxios.get.mockResolvedValueOnce({
        data: {
          status: { id: 3 },
          stdout: Buffer.from('olleh').toString('base64'),
          time: '0.001',
          memory: 512
        }
      });

      await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          contestId: contestId,
          code: 'def solution(s): return s[::-1]',
          language: 'Python',
          languageId: 71
        })
        .expect(201);

      // User 2 submits second (medium speed)
      mockAxios.get.mockResolvedValueOnce({
        data: {
          status: { id: 3 },
          stdout: Buffer.from('olleh').toString('base64'),
          time: '0.002',
          memory: 1024
        }
      });

      await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${user2Token}`)
        .send({
          contestId: contestId,
          code: 'def solution(s): return "".join(reversed(s))',
          language: 'Python',
          languageId: 71
        })
        .expect(201);

      // User 3 submits last (slowest)
      mockAxios.get.mockResolvedValueOnce({
        data: {
          status: { id: 3 },
          stdout: Buffer.from('olleh').toString('base64'),
          time: '0.003',
          memory: 2048
        }
      });

      await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${user3Token}`)
        .send({
          contestId: contestId,
          code: 'def solution(s): result = ""; for i in range(len(s)-1, -1, -1): result += s[i]; return result',
          language: 'Python',
          languageId: 71
        })
        .expect(201);

      // Check leaderboard ranking
      const leaderboardResponse = await request(app)
        .get(`/api/leaderboard/contest/${contestId}`)
        .expect(200);

      expect(leaderboardResponse.body.entries).toHaveLength(3);
      
      // User 1 should be first (fastest submission)
      expect(leaderboardResponse.body.entries[0].userId).toBe('user1');
      expect(leaderboardResponse.body.entries[0].rank).toBe(1);
      
      // User 2 should be second
      expect(leaderboardResponse.body.entries[1].userId).toBe('user2');
      expect(leaderboardResponse.body.entries[1].rank).toBe(2);
      
      // User 3 should be third
      expect(leaderboardResponse.body.entries[2].userId).toBe('user3');
      expect(leaderboardResponse.body.entries[2].rank).toBe(3);

      // Verify scores are in descending order
      expect(leaderboardResponse.body.entries[0].compositeScore)
        .toBeGreaterThan(leaderboardResponse.body.entries[1].compositeScore);
      expect(leaderboardResponse.body.entries[1].compositeScore)
        .toBeGreaterThan(leaderboardResponse.body.entries[2].compositeScore);
    });
  });

  describe('Real-time Updates via WebSocket', () => {
    let clientSocket;
    let server;

    beforeAll((done) => {
      // Start test server
      server = require('http').createServer();
      const ioServer = require('socket.io')(server);
      
      server.listen(() => {
        const port = server.address().port;
        clientSocket = io(`http://localhost:${port}`);
        
        clientSocket.on('connect', done);
      });
    });

    afterAll(() => {
      if (clientSocket) clientSocket.close();
      if (server) server.close();
    });

    test('Real-time contest updates', (done) => {
      const testContest = {
        _id: 'test-contest-id',
        title: 'WebSocket Test Contest',
        type: 'coding',
        status: 'waiting'
      };

      clientSocket.on('newContest', (contest) => {
        expect(contest.title).toBe(testContest.title);
        expect(contest.type).toBe(testContest.type);
        done();
      });

      // Simulate server emitting new contest
      clientSocket.emit('newContest', testContest);
    });

    test('Real-time submission updates', (done) => {
      const testSubmission = {
        contestId: 'test-contest',
        userId: 'testuser',
        username: 'testuser',
        compositeScore: 95.5
      };

      clientSocket.on('newSubmission', (data) => {
        expect(data.contestId).toBe(testSubmission.contestId);
        expect(data.submission.userId).toBe(testSubmission.userId);
        expect(data.submission.compositeScore).toBe(testSubmission.compositeScore);
        done();
      });

      // Simulate server emitting new submission
      clientSocket.emit('newSubmission', { contestId: 'test-contest', submission: testSubmission });
    });

    test('Real-time leaderboard updates', (done) => {
      const testLeaderboard = {
        contestId: 'test-contest',
        leaderboard: [
          { userId: 'user1', rank: 1, compositeScore: 95.5 },
          { userId: 'user2', rank: 2, compositeScore: 87.2 }
        ]
      };

      clientSocket.on('leaderboardUpdate', (data) => {
        expect(data.contestId).toBe(testLeaderboard.contestId);
        expect(data.leaderboard).toHaveLength(2);
        expect(data.leaderboard[0].rank).toBe(1);
        expect(data.leaderboard[1].rank).toBe(2);
        done();
      });

      // Simulate server emitting leaderboard update
      clientSocket.emit('leaderboardUpdate', testLeaderboard);
    });
  });

  describe('Performance and Load Testing', () => {
    test('Handle multiple concurrent submissions', async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Load Test Contest',
        type: 'coding',
        status: 'live',
        participants: ['user1', 'user2', 'user3', 'user4', 'user5'],
        testCases: [{ input: 'test', expectedOutput: 'test' }],
        startTime: new Date(Date.now() - 60000),
        endTime: new Date(Date.now() + 1800000)
      });

      const submissionData = {
        contestId: contest.insertedId.toString(),
        code: 'print("test")',
        language: 'Python',
        languageId: 71
      };

      // Mock Judge0 API
      const mockAxios = require('axios');
      jest.mock('axios');
      
      mockAxios.post.mockResolvedValue({
        data: { token: 'test-token' }
      });
      
      mockAxios.get.mockResolvedValue({
        data: {
          status: { id: 3 },
          stdout: Buffer.from('test').toString('base64'),
          time: '0.001',
          memory: 512
        }
      });

      // Create multiple concurrent submissions
      const startTime = Date.now();
      const promises = Array(5).fill().map((_, index) => {
        const token = jwt.sign(
          { userId: `user${index + 1}`, username: `user${index + 1}` },
          process.env.JWT_SECRET || 'test-secret',
          { expiresIn: '1h' }
        );

        return request(app)
          .post('/api/submissions')
          .set('Authorization', `Bearer ${token}`)
          .send(submissionData);
      });

      const responses = await Promise.all(promises);
      const endTime = Date.now();

      // All submissions should succeed
      responses.forEach(response => {
        expect(response.status).toBe(201);
      });

      // Performance check: should complete within reasonable time
      expect(endTime - startTime).toBeLessThan(10000); // 10 seconds

      // Check leaderboard has all submissions
      const leaderboardResponse = await request(app)
        .get(`/api/leaderboard/contest/${contest.insertedId}`)
        .expect(200);

      expect(leaderboardResponse.body.entries).toHaveLength(5);
    });
  });

  describe('Error Handling and Edge Cases', () => {
    test('Handle network failures gracefully', async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Network Test Contest',
        type: 'coding',
        status: 'live',
        participants: ['testuser'],
        testCases: [{ input: 'test', expectedOutput: 'test' }],
        startTime: new Date(Date.now() - 60000),
        endTime: new Date(Date.now() + 1800000)
      });

      const submissionData = {
        contestId: contest.insertedId.toString(),
        code: 'print("test")',
        language: 'Python',
        languageId: 71
      };

      // Mock Judge0 API to simulate network failure
      const mockAxios = require('axios');
      jest.mock('axios');
      
      mockAxios.post.mockRejectedValue(new Error('Network error'));

      const response = await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(submissionData)
        .expect(500);

      expect(response.body.error).toBe('Internal server error');
    });

    test('Handle invalid code submissions', async () => {
      const contest = await db.collection('contests').insertOne({
        title: 'Invalid Code Test Contest',
        type: 'coding',
        status: 'live',
        participants: ['testuser'],
        testCases: [{ input: 'test', expectedOutput: 'test' }],
        startTime: new Date(Date.now() - 60000),
        endTime: new Date(Date.now() + 1800000)
      });

      const submissionData = {
        contestId: contest.insertedId.toString(),
        code: 'invalid python code with syntax error',
        language: 'Python',
        languageId: 71
      };

      // Mock Judge0 API to return compilation error
      const mockAxios = require('axios');
      jest.mock('axios');
      
      mockAxios.post.mockResolvedValue({
        data: { token: 'test-token' }
      });
      
      mockAxios.get.mockResolvedValue({
        data: {
          status: { id: 4 }, // Compilation error
          stderr: Buffer.from('SyntaxError: invalid syntax').toString('base64'),
          time: '0.001',
          memory: 512
        }
      });

      const response = await request(app)
        .post('/api/submissions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(submissionData)
        .expect(201);

      // Should still create submission but with 0 accuracy
      expect(response.body.testCasesPassed).toBe(0);
      expect(response.body.accuracy).toBe(0);
    });
  });
}); 