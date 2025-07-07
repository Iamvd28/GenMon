const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const compression = require('compression');
const WebSocket = require('ws');
const http = require('http');
const path = require('path');
const logger = require('./utils/logger');

// Import routes
const authRoutes = require('./routes/auth');
const contestRoutes = require('./routes/contests');
const submissionRoutes = require('./routes/submissions');
const leaderboardRoutes = require('./routes/leaderboard');

// Import utilities
const { calculateCompositeScore } = require('./utils/scoring');

// In-memory storage for development
const inMemoryStorage = {
  users: new Map(),
  contests: new Map(),
  submissions: new Map(),
  leaderboards: new Map(),
  nextId: {
    users: 1,
    contests: 1,
    submissions: 1,
    leaderboards: 1,
  }
};

// Sample data for testing
const sampleData = {
  users: [
    {
      _id: '1',
      username: 'coder_pro',
      email: 'pro@example.com',
      password: '$2b$10$hashedpassword',
      rating: 1850,
      contestsParticipated: 15,
      totalScore: 2850,
      accuracy: 0.92,
      speed: 85,
      createdAt: new Date(),
      updatedAt: new Date()
    },
    {
      _id: '2',
      username: 'algo_master',
      email: 'master@example.com',
      password: '$2b$10$hashedpassword',
      rating: 2100,
      contestsParticipated: 22,
      totalScore: 3200,
      accuracy: 0.95,
      speed: 92,
      createdAt: new Date(),
      updatedAt: new Date()
    },
    {
      _id: '3',
      username: 'code_ninja',
      email: 'ninja@example.com',
      password: '$2b$10$hashedpassword',
      rating: 1750,
      contestsParticipated: 12,
      totalScore: 2400,
      accuracy: 0.88,
      speed: 78,
      createdAt: new Date(),
      updatedAt: new Date()
    }
  ],
  leaderboards: [
    {
      _id: '1',
      contestId: 'overall',
      entries: [
        {
          username: 'algo_master',
          compositeScore: 3200,
          totalScore: 3200,
          accuracy: 0.95,
          speed: 92,
          contestsParticipated: 22,
          rank: 1,
          category: 'overall',
          updatedAt: new Date()
        },
        {
          username: 'coder_pro',
          compositeScore: 2850,
          totalScore: 2850,
          accuracy: 0.92,
          speed: 85,
          contestsParticipated: 15,
          rank: 2,
          category: 'overall',
          updatedAt: new Date()
        },
        {
          username: 'code_ninja',
          compositeScore: 2400,
          totalScore: 2400,
          accuracy: 0.88,
          speed: 78,
          contestsParticipated: 12,
          rank: 3,
          category: 'overall',
          updatedAt: new Date()
        }
      ],
      lastUpdated: new Date()
    }
  ]
};

// Initialize sample data
function initializeSampleData() {
  sampleData.users.forEach(user => {
    inMemoryStorage.users.set(user._id, user);
  });

  sampleData.leaderboards.forEach(leaderboard => {
    inMemoryStorage.leaderboards.set(leaderboard._id, leaderboard);
  });

  logger.info('Sample data initialized for in-memory database');
}

// Initialize sample data
initializeSampleData();

// Create Express app
const app = express();
const server = http.createServer(app);

// Create WebSocket server
const wss = new WebSocket.Server({ server });

// WebSocket connection handling
wss.on('connection', (ws) => {
  logger.info('New WebSocket connection established');

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      logger.info('WebSocket message received:', data);
      
      // Handle different message types
      switch (data.type) {
        case 'join_contest':
          // Handle contest join
          break;
        case 'submit_solution':
          // Handle solution submission
          break;
        default:
          logger.warn('Unknown WebSocket message type:', data.type);
      }
    } catch (error) {
      logger.error('Error parsing WebSocket message:', error);
    }
  });

  ws.on('close', () => {
    logger.info('WebSocket connection closed');
  });
});

// Middleware
app.use(helmet());
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// CORS configuration
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:8080',
      'http://10.0.2.2:3000',
      'http://10.0.2.2:8080',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:8080'
    ];
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(null, true); // Allow all origins for development
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: Math.ceil((parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000) / 1000)
  },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);

// Submission-specific rate limiting
const submissionLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: parseInt(process.env.SUBMISSION_RATE_LIMIT_MAX) || 5, // limit each IP to 5 submissions per minute
  message: {
    error: 'Too many submissions from this IP, please try again later.',
    retryAfter: 60
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/contests', contestRoutes);
app.use('/api/submissions', submissionLimiter, submissionRoutes);
app.use('/api/leaderboard', leaderboardRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error('Unhandled error:', err);
  
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: 'Validation Error',
      message: err.message,
      details: err.details
    });
  }
  
  if (err.name === 'UnauthorizedError') {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Invalid or missing authentication token'
    });
  }
  
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'production' ? 'Something went wrong' : err.message
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  });
});

// Global database helper functions
global.getCollection = (collectionName) => {
  return {
    find: (query = {}) => {
      const data = Array.from(inMemoryStorage[collectionName]?.values() || []);
      return {
        toArray: () => Promise.resolve(data.filter(item => {
          for (const [key, value] of Object.entries(query)) {
            if (item[key] !== value) return false;
          }
          return true;
        })),
        sort: (sortObj) => {
          const data = Array.from(inMemoryStorage[collectionName]?.values() || []);
          const sorted = data.sort((a, b) => {
            for (const [key, direction] of Object.entries(sortObj)) {
              if (direction === 1) {
                return a[key] > b[key] ? 1 : -1;
              } else {
                return a[key] < b[key] ? 1 : -1;
              }
            }
            return 0;
          });
          return {
            toArray: () => Promise.resolve(sorted),
            limit: (num) => Promise.resolve(sorted.slice(0, num))
          };
        },
        limit: (num) => {
          const data = Array.from(inMemoryStorage[collectionName]?.values() || []);
          return Promise.resolve(data.slice(0, num));
        }
      };
    },
    findOne: (query = {}) => {
      const data = Array.from(inMemoryStorage[collectionName]?.values() || []);
      const result = data.find(item => {
        for (const [key, value] of Object.entries(query)) {
          if (item[key] !== value) return false;
        }
        return true;
      });
      return Promise.resolve(result);
    },
    insertOne: (doc) => {
      const id = (inMemoryStorage.nextId[collectionName] || 1).toString();
      const newDoc = { ...doc, _id: id };
      inMemoryStorage[collectionName].set(id, newDoc);
      inMemoryStorage.nextId[collectionName] = (inMemoryStorage.nextId[collectionName] || 1) + 1;
      return Promise.resolve({ insertedId: id, ...newDoc });
    },
    updateOne: (filter, update) => {
      const data = Array.from(inMemoryStorage[collectionName]?.values() || []);
      const index = data.findIndex(item => {
        for (const [key, value] of Object.entries(filter)) {
          if (item[key] !== value) return false;
        }
        return true;
      });
      
      if (index !== -1) {
        const id = data[index]._id;
        const updatedDoc = { ...data[index], ...update.$set };
        inMemoryStorage[collectionName].set(id, updatedDoc);
        return Promise.resolve({ modifiedCount: 1 });
      }
      return Promise.resolve({ modifiedCount: 0 });
    },
    countDocuments: (query = {}) => {
      const data = Array.from(inMemoryStorage[collectionName]?.values() || []);
      const count = data.filter(item => {
        for (const [key, value] of Object.entries(query)) {
          if (item[key] !== value) return false;
        }
        return true;
      }).length;
      return Promise.resolve(count);
    }
  };
};

// Start server
const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  logger.info(`GenMon4 Backend Server running on port ${PORT}`);
  logger.info('Using in-memory database (no MongoDB required)');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

module.exports = { app, server, wss };