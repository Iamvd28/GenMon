const { MongoClient } = require('mongodb');
const Redis = require('redis');
const logger = require('./logger');

/**
 * Database utility class for GenMon4 Backend
 * Handles MongoDB and Redis connections and operations
 */
class DatabaseManager {
  constructor() {
    this.mongoClient = null;
    this.db = null;
    this.redisClient = null;
    this.isConnected = false;
  }

  /**
   * Initialize database connections
   * @param {Object} config - Configuration object
   */
  async initialize(config) {
    try {
      // Initialize MongoDB connection
      await this.connectMongoDB(config.MONGODB_URI);
      
      // Initialize Redis connection if configured
      if (config.REDIS_URL) {
        await this.connectRedis(config.REDIS_URL);
      }
      
      this.isConnected = true;
      console.log('Database connections established successfully');
    } catch (error) {
      console.error('Database initialization error:', error);
      throw error;
    }
  }

  /**
   * Connect to MongoDB
   * @param {string} mongoUri - MongoDB connection string
   */
  async connectMongoDB(mongoUri) {
    try {
      this.mongoClient = new MongoClient(mongoUri, {
        useUnifiedTopology: true,
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 45000,
      });

      await this.mongoClient.connect();
      this.db = this.mongoClient.db();
      
      console.log('MongoDB connected successfully');
      
      // Test the connection
      await this.db.admin().ping();
      console.log('MongoDB ping successful');
      
    } catch (error) {
      console.error('MongoDB connection error:', error);
      throw error;
    }
  }

  /**
   * Connect to Redis
   * @param {string} redisUrl - Redis connection URL
   */
  async connectRedis(redisUrl) {
    try {
      this.redisClient = Redis.createClient({
        url: redisUrl,
        retry_strategy: (options) => {
          if (options.error && options.error.code === 'ECONNREFUSED') {
            console.error('Redis server refused connection');
            return new Error('Redis server refused connection');
          }
          if (options.total_retry_time > 1000 * 60 * 60) {
            console.error('Redis retry time exhausted');
            return new Error('Redis retry time exhausted');
          }
          if (options.attempt > 10) {
            console.error('Redis max retry attempts reached');
            return new Error('Redis max retry attempts reached');
          }
          return Math.min(options.attempt * 100, 3000);
        }
      });

      this.redisClient.on('error', (err) => {
        console.error('Redis client error:', err);
      });

      this.redisClient.on('connect', () => {
        console.log('Redis connected successfully');
      });

      this.redisClient.on('ready', () => {
        console.log('Redis client ready');
      });

      await this.redisClient.connect();
      
    } catch (error) {
      console.error('Redis connection error:', error);
      // Don't throw error for Redis - it's optional
      this.redisClient = null;
    }
  }

  /**
   * Get MongoDB database instance
   * @returns {Object} MongoDB database instance
   */
  getDatabase() {
    if (!this.db) {
      throw new Error('Database not connected');
    }
    return this.db;
  }

  /**
   * Get Redis client
   * @returns {Object|null} Redis client or null if not connected
   */
  getRedisClient() {
    return this.redisClient;
  }

  /**
   * Create database indexes for optimal performance
   */
  async createIndexes() {
    try {
      const db = this.getDatabase();
      
      // Contests collection indexes
      await db.collection('contests').createIndexes([
        { key: { status: 1 } },
        { key: { type: 1 } },
        { key: { category: 1 } },
        { key: { createdAt: -1 } },
        { key: { startTime: 1 } },
        { key: { endTime: 1 } },
        { key: { participants: 1 } },
        { key: { createdBy: 1 } }
      ]);

      // Submissions collection indexes
      await db.collection('submissions').createIndexes([
        { key: { contestId: 1 } },
        { key: { userId: 1 } },
        { key: { submittedAt: -1 } },
        { key: { compositeScore: -1 } },
        { key: { contestId: 1, userId: 1 } },
        { key: { contestId: 1, compositeScore: -1 } },
        { key: { userId: 1, submittedAt: -1 } }
      ]);

      // Leaderboards collection indexes
      await db.collection('leaderboards').createIndexes([
        { key: { contestId: 1 }, unique: true },
        { key: { lastUpdated: -1 } }
      ]);

      // Users collection indexes
      await db.collection('users').createIndexes([
        { key: { email: 1 }, unique: true },
        { key: { username: 1 }, unique: true },
        { key: { createdAt: -1 } }
      ]);

      console.log('Database indexes created successfully');
    } catch (error) {
      console.error('Error creating indexes:', error);
      throw error;
    }
  }

  /**
   * Initialize database with sample data (for development)
   */
  async initializeSampleData() {
    try {
      const db = this.getDatabase();
      
      // Check if sample data already exists
      const existingContests = await db.collection('contests').countDocuments();
      if (existingContests > 0) {
        console.log('Sample data already exists, skipping initialization');
        return;
      }

      // Sample contests
      const sampleContests = [
        {
          title: 'Python String Reversal',
          type: 'coding',
          category: 'algorithms',
          question: 'Write a function to reverse a string in Python.',
          testCases: [
            { input: 'hello', expectedOutput: 'olleh' },
            { input: 'world', expectedOutput: 'dlrow' },
            { input: 'python', expectedOutput: 'nohtyp' }
          ],
          maxParticipants: 10,
          duration: 1800, // 30 minutes
          createdBy: 'system',
          participants: [],
          status: 'waiting',
          createdAt: new Date(),
          startTime: new Date(Date.now() + 300000), // Start in 5 minutes
          endTime: new Date(Date.now() + 300000 + 1800000)
        },
        {
          title: 'JavaScript Array Sorting',
          type: 'coding',
          category: 'algorithms',
          question: 'Write a function to sort an array of numbers in ascending order.',
          testCases: [
            { input: '[3, 1, 4, 1, 5]', expectedOutput: '[1, 1, 3, 4, 5]' },
            { input: '[9, 8, 7, 6]', expectedOutput: '[6, 7, 8, 9]' }
          ],
          maxParticipants: 8,
          duration: 1200, // 20 minutes
          createdBy: 'system',
          participants: [],
          status: 'waiting',
          createdAt: new Date(),
          startTime: new Date(Date.now() + 600000), // Start in 10 minutes
          endTime: new Date(Date.now() + 600000 + 1200000)
        }
      ];

      await db.collection('contests').insertMany(sampleContests);
      console.log('Sample contests created successfully');

    } catch (error) {
      console.error('Error initializing sample data:', error);
      throw error;
    }
  }

  /**
   * Health check for database connections
   * @returns {Object} Health status
   */
  async healthCheck() {
    const status = {
      mongodb: false,
      redis: false,
      overall: false
    };

    try {
      // Check MongoDB
      if (this.db) {
        await this.db.admin().ping();
        status.mongodb = true;
      }

      // Check Redis
      if (this.redisClient) {
        await this.redisClient.ping();
        status.redis = true;
      }

      status.overall = status.mongodb; // MongoDB is required, Redis is optional
      
    } catch (error) {
      console.error('Database health check failed:', error);
    }

    return status;
  }

  /**
   * Close database connections
   */
  async close() {
    try {
      if (this.mongoClient) {
        await this.mongoClient.close();
        console.log('MongoDB connection closed');
      }

      if (this.redisClient) {
        await this.redisClient.quit();
        console.log('Redis connection closed');
      }

      this.isConnected = false;
      console.log('All database connections closed');
    } catch (error) {
      console.error('Error closing database connections:', error);
      throw error;
    }
  }

  /**
   * Get database statistics
   * @returns {Object} Database statistics
   */
  async getStats() {
    try {
      const db = this.getDatabase();
      
      const stats = {
        contests: await db.collection('contests').countDocuments(),
        submissions: await db.collection('submissions').countDocuments(),
        users: await db.collection('users').countDocuments(),
        leaderboards: await db.collection('leaderboards').countDocuments()
      };

      return stats;
    } catch (error) {
      console.error('Error getting database stats:', error);
      throw error;
    }
  }
}

// Create singleton instance
const databaseManager = new DatabaseManager();

module.exports = databaseManager; 