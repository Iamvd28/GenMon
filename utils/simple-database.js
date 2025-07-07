const logger = require('./logger');

// In-memory storage for development when MongoDB is not available
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

// Initialize sample data on module load
initializeSampleData();

function getCollection(collectionName) {
  return {
    find: (query = {}) => {
      const data = Array.from(inMemoryStorage[collectionName]?.values() || []);
      return {
        toArray: () => Promise.resolve(data.filter(item => {
          // Simple query matching for in-memory
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
    deleteOne: (filter) => {
      const data = Array.from(inMemoryStorage[collectionName]?.values() || []);
      const index = data.findIndex(item => {
        for (const [key, value] of Object.entries(filter)) {
          if (item[key] !== value) return false;
        }
        return true;
      });
      
      if (index !== -1) {
        const id = data[index]._id;
        inMemoryStorage[collectionName].delete(id);
        return Promise.resolve({ deletedCount: 1 });
      }
      return Promise.resolve({ deletedCount: 0 });
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
}

function getDatabase() {
  return {
    collection: getCollection
  };
}

function isInMemoryMode() {
  return true;
}

module.exports = {
  getCollection,
  getDatabase,
  isInMemoryMode
}; 