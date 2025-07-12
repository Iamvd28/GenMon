const express = require('express');
const router = express.Router();
const logger = require('../utils/logger');

/**
 * @route GET /api/leaderboard/overall
 * @desc Get overall leaderboard
 * @access Public
 */
router.get('/overall', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;
    
    // Get overall leaderboard from in-memory storage
    const leaderboardCollection = global.getCollection('leaderboards');
    const leaderboard = await leaderboardCollection.findOne({ contestId: 'overall' });
    
    if (!leaderboard) {
      return res.status(404).json({
        error: 'Leaderboard not found',
        message: 'Overall leaderboard not available'
      });
    }
    
    const entries = leaderboard.entries || [];
    const paginatedEntries = entries.slice(offset, offset + limit);
    
    res.json({
      success: true,
      contestId: 'overall',
      entries: paginatedEntries,
      total: entries.length,
      limit,
      offset,
      lastUpdated: leaderboard.lastUpdated
    });
  } catch (error) {
    logger.error('Error fetching overall leaderboard:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to fetch overall leaderboard'
    });
  }
});

/**
 * @route GET /api/leaderboard/contest/:contestId
 * @desc Get contest-specific leaderboard
 * @access Public
 */
router.get('/contest/:contestId', async (req, res) => {
  try {
    const { contestId } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;
    
    // Get contest leaderboard from in-memory storage
    const leaderboardCollection = global.getCollection('leaderboards');
    const leaderboard = await leaderboardCollection.findOne({ contestId });
    
    if (!leaderboard) {
      return res.status(404).json({
        error: 'Leaderboard not found',
        message: `Leaderboard for contest ${contestId} not found`
      });
    }
    
    const entries = leaderboard.entries || [];
    const paginatedEntries = entries.slice(offset, offset + limit);
    
    res.json({
      success: true,
      contestId,
      entries: paginatedEntries,
      total: entries.length,
      limit,
      offset,
      lastUpdated: leaderboard.lastUpdated
    });
  } catch (error) {
    logger.error('Error fetching contest leaderboard:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to fetch contest leaderboard'
    });
  }
});

/**
 * @route GET /api/leaderboard/category/:category
 * @desc Get category-specific leaderboard
 * @access Public
 */
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;
    
    // For now, return overall leaderboard for any category
    // In a full implementation, you would filter by category
    const leaderboardCollection = global.getCollection('leaderboards');
    const leaderboard = await leaderboardCollection.findOne({ contestId: 'overall' });
    
    if (!leaderboard) {
      return res.status(404).json({
        error: 'Leaderboard not found',
        message: `Leaderboard for category ${category} not found`
      });
    }
    
    const entries = leaderboard.entries || [];
    const paginatedEntries = entries.slice(offset, offset + limit);
    
    res.json({
      success: true,
      category,
      entries: paginatedEntries,
      total: entries.length,
      limit,
      offset,
      lastUpdated: leaderboard.lastUpdated
    });
  } catch (error) {
    logger.error('Error fetching category leaderboard:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to fetch category leaderboard'
    });
  }
});

/**
 * @route GET /api/leaderboard/user/:userId
 * @desc Get user's leaderboard position and stats
 * @access Public
 */
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Get user from in-memory storage
    const userCollection = global.getCollection('users');
    const user = await userCollection.findOne({ _id: userId });
    
    if (!user) {
      return res.status(404).json({
        error: 'User not found',
        message: 'User not found in leaderboard'
      });
    }
    
    // Get overall leaderboard to find user's position
    const leaderboardCollection = global.getCollection('leaderboards');
    const leaderboard = await leaderboardCollection.findOne({ contestId: 'overall' });
    
    if (!leaderboard) {
      return res.status(404).json({
        error: 'Leaderboard not found',
        message: 'Overall leaderboard not available'
      });
    }
    
    const userEntry = leaderboard.entries.find(entry => entry.username === user.username);
    
    if (!userEntry) {
      return res.status(404).json({
        error: 'User not found in leaderboard',
        message: 'User not found in leaderboard rankings'
      });
    }
    
    res.json({
      success: true,
      user: {
        _id: user._id,
        username: user.username,
        rank: userEntry.rank,
        compositeScore: userEntry.compositeScore,
        totalScore: userEntry.totalScore,
        accuracy: userEntry.accuracy,
        speed: userEntry.speed,
        contestsParticipated: userEntry.contestsParticipated
      },
      leaderboard: {
        contestId: 'overall',
        totalParticipants: leaderboard.entries.length,
        lastUpdated: leaderboard.lastUpdated
      }
    });
  } catch (error) {
    logger.error('Error fetching user leaderboard position:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to fetch user leaderboard position'
    });
  }
});

module.exports = router; 