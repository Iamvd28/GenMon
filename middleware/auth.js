const jwt = require('jsonwebtoken');
const { ObjectId } = require('mongodb');

// JWT Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ error: 'Token expired' });
      }
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

// Optional authentication middleware (doesn't fail if no token)
const optionalAuth = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token) {
    jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
      if (!err) {
        req.user = user;
      }
    });
  }
  next();
};

// Admin authorization middleware
const requireAdmin = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const db = req.app.locals.db;
    const user = await db.collection('users').findOne(
      { _id: new ObjectId(req.user.userId) }
    );

    if (!user || !user.isAdmin) {
      return res.status(403).json({ error: 'Admin access required' });
    }

    next();
  } catch (error) {
    console.error('Admin auth error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Contest participant authorization middleware
const requireContestParticipant = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const contestId = req.params.contestId || req.body.contestId;
    if (!contestId) {
      return res.status(400).json({ error: 'Contest ID required' });
    }

    const db = req.app.locals.db;
    const contest = await db.collection('contests').findOne({
      _id: new ObjectId(contestId)
    });

    if (!contest) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    if (!contest.participants.includes(req.user.userId)) {
      return res.status(403).json({ error: 'Must be a contest participant' });
    }

    req.contest = contest;
    next();
  } catch (error) {
    console.error('Contest participant auth error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Contest owner authorization middleware
const requireContestOwner = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const contestId = req.params.contestId || req.params.id;
    if (!contestId) {
      return res.status(400).json({ error: 'Contest ID required' });
    }

    const db = req.app.locals.db;
    const contest = await db.collection('contests').findOne({
      _id: new ObjectId(contestId)
    });

    if (!contest) {
      return res.status(404).json({ error: 'Contest not found' });
    }

    if (contest.createdBy !== req.user.userId) {
      return res.status(403).json({ error: 'Must be contest owner' });
    }

    req.contest = contest;
    next();
  } catch (error) {
    console.error('Contest owner auth error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Rate limiting middleware for submissions
const submissionRateLimit = (req, res, next) => {
  const userId = req.user?.userId;
  if (!userId) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  const db = req.app.locals.db;
  const redis = req.app.locals.redis;

  if (redis) {
    // Use Redis for rate limiting
    const key = `submission_rate_limit:${userId}`;
    const limit = 5; // 5 submissions per minute
    const windowMs = 60 * 1000; // 1 minute

    redis.get(key, (err, count) => {
      if (err) {
        console.error('Redis rate limit error:', err);
        return next(); // Continue without rate limiting if Redis fails
      }

      const currentCount = parseInt(count) || 0;

      if (currentCount >= limit) {
        return res.status(429).json({ 
          error: 'Too many submissions, please try again later.',
          retryAfter: Math.ceil(windowMs / 1000)
        });
      }

      redis.multi()
        .incr(key)
        .expire(key, Math.ceil(windowMs / 1000))
        .exec((err) => {
          if (err) {
            console.error('Redis rate limit increment error:', err);
          }
          next();
        });
    });
  } else {
    // Fallback to in-memory rate limiting
    const key = `submission_rate_limit:${userId}`;
    const limit = 5;
    const windowMs = 60 * 1000;

    if (!req.app.locals.rateLimitStore) {
      req.app.locals.rateLimitStore = new Map();
    }

    const now = Date.now();
    const userLimits = req.app.locals.rateLimitStore.get(key) || { count: 0, resetTime: now + windowMs };

    if (now > userLimits.resetTime) {
      userLimits.count = 0;
      userLimits.resetTime = now + windowMs;
    }

    if (userLimits.count >= limit) {
      return res.status(429).json({ 
        error: 'Too many submissions, please try again later.',
        retryAfter: Math.ceil((userLimits.resetTime - now) / 1000)
      });
    }

    userLimits.count++;
    req.app.locals.rateLimitStore.set(key, userLimits);

    // Clean up old entries
    setTimeout(() => {
      req.app.locals.rateLimitStore.delete(key);
    }, windowMs);

    next();
  }
};

module.exports = {
  authenticateToken,
  optionalAuth,
  requireAdmin,
  requireContestParticipant,
  requireContestOwner,
  submissionRateLimit
}; 