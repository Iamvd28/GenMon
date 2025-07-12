<<<<<<< HEAD
# GenMon

A Flutter gaming platform application that combines sports, coding, and quiz challenges.

## Getting Started

This project is a Flutter application that requires the following setup:

1. Install Flutter SDK (version 3.0.0 or higher)
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Create a new Firebase project
   - Add your Firebase configuration to `lib/firebase_options.dart`
   - Enable Authentication in Firebase Console

## Features

- Authentication system with email/password and social logins
- Sports Arena with multiple sports categories
- Code Arena with programming challenges
- Quiz Arena with various subjects
- Wallet system for managing in-app currency
- Match tracking and history
- Real-time notifications

## Development

To run the project in development mode:

```bash
flutter run
```

## Project Structure

- `lib/`
  - `main.dart` - Main application entry point
  - `firebase_options.dart` - Firebase configuration
  - Screens for different arenas and features

## Dependencies

- firebase_core: ^2.24.2
- firebase_auth: ^4.15.3
- font_awesome_flutter: ^10.6.0

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests. 
=======
# GenMon4 Backend Server

A comprehensive backend service for the GenMon4 Contest Platform, providing real-time contest management, code execution, and leaderboard functionality.

## Features

- **Contest Management**: Create, join, and manage coding contests
- **Real-time Updates**: WebSocket-based real-time leaderboard and contest updates
- **Code Execution**: Integration with Judge0 API for secure code execution
- **Scoring System**: Multi-factor scoring based on accuracy, speed, and efficiency
- **Leaderboard**: Real-time leaderboard updates with ranking algorithms
- **Authentication**: JWT-based authentication and authorization
- **Rate Limiting**: Protection against abuse with configurable rate limits
- **Logging**: Comprehensive logging with Winston
- **Security**: Helmet.js security headers and input validation

## Prerequisites

- Node.js >= 16.0.0
- MongoDB >= 4.4
- RapidAPI account for Judge0 API access

## Installation

1. Clone the repository and navigate to the backend directory:
```bash
cd coding-game-platform/backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp env.example .env
# Edit .env with your actual values
```

4. Start MongoDB service (if running locally):
```bash
# On Windows
net start MongoDB

# On macOS/Linux
sudo systemctl start mongod
```

5. Start the development server:
```bash
npm run dev
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 3000 |
| `MONGODB_URI` | MongoDB connection string | mongodb://localhost:27017/genmon4 |
| `JWT_SECRET` | JWT signing secret | your-secret-key |
| `JUDGE0_API_KEY` | RapidAPI key for Judge0 | your-rapidapi-key |
| `NODE_ENV` | Environment mode | development |

## API Endpoints

### Contest Management

- `POST /api/contests` - Create a new contest
- `GET /api/contests` - List all contests
- `GET /api/contests/:id` - Get contest details
- `POST /api/contests/:id/join` - Join a contest

### Submissions

- `POST /api/submissions` - Submit code/answer
- `GET /api/submissions/:contestId` - Get contest submissions

### Leaderboard

- `GET /api/leaderboard/contest/:contestId` - Contest-specific leaderboard
- `GET /api/leaderboard/overall` - Overall leaderboard
- `GET /api/users/:userId/stats` - User statistics

### Health Check

- `GET /api/health` - Server health status

## WebSocket Events

### Client to Server
- `joinContest` - Join a contest room
- `leaveContest` - Leave a contest room

### Server to Client
- `newContest` - New contest created
- `participantJoined` - User joined contest
- `newSubmission` - New submission received
- `leaderboardUpdate` - Leaderboard updated
- `contestEnded` - Contest completed

## Scoring Algorithm

The system uses a composite scoring algorithm with three components:

1. **Accuracy Score (40%)**: Based on test case pass rate
2. **Speed Score (35%)**: Based on submission time relative to contest duration
3. **Efficiency Score (25%)**: Based on execution time and memory usage

### Formula
```
Composite Score = (Accuracy × 0.4 + Speed × 0.35 + Efficiency × 0.25) × 100
```

## Database Schema

### Collections

#### contests
```javascript
{
  _id: ObjectId,
  title: String,
  type: String, // 'coding', 'quiz', 'sports'
  category: String,
  question: String,
  testCases: Array,
  maxParticipants: Number,
  duration: Number,
  createdBy: String,
  participants: Array,
  status: String, // 'waiting', 'live', 'completed'
  startTime: Date,
  endTime: Date,
  createdAt: Date
}
```

#### submissions
```javascript
{
  _id: ObjectId,
  contestId: ObjectId,
  userId: String,
  username: String,
  code: String,
  language: String,
  submittedAt: Date,
  executionTime: Number,
  memoryUsage: Number,
  testCasesPassed: Number,
  totalTestCases: Number,
  accuracy: Number,
  speed: Number,
  efficiency: Number,
  compositeScore: Number,
  testResults: Array
}
```

#### leaderboards
```javascript
{
  _id: ObjectId,
  contestId: ObjectId,
  entries: Array,
  lastUpdated: Date
}
```

## Code Execution

The backend integrates with Judge0 API for secure code execution:

- Supports multiple programming languages
- Secure sandboxed execution
- Time and memory limits
- Input/output validation

### Supported Languages
- Python (71)
- JavaScript (63)
- Java (62)
- C++ (54)
- C# (51)

## Security Features

- **Input Validation**: Joi schema validation for all inputs
- **Rate Limiting**: Configurable rate limits for API endpoints
- **Authentication**: JWT-based authentication
- **Security Headers**: Helmet.js for security headers
- **CORS**: Configurable CORS settings
- **Request Size Limits**: 10MB limit for JSON payloads

## Monitoring and Logging

- **Winston Logger**: Structured logging with multiple transports
- **Error Tracking**: Comprehensive error logging
- **Performance Monitoring**: Request timing and resource usage
- **Health Checks**: Built-in health check endpoint

## Development

### Running Tests
```bash
npm test
npm run test:watch
```

### Code Style
The project follows standard Node.js/Express.js conventions.

### Debugging
```bash
# Enable debug logging
DEBUG=* npm run dev
```

## Deployment

### Production Setup
1. Set `NODE_ENV=production`
2. Configure production MongoDB instance
3. Set secure JWT secret
4. Configure proper CORS origins
5. Set up reverse proxy (nginx recommended)
6. Configure SSL certificates

### Docker Deployment
```bash
# Build image
docker build -t genmon4-backend .

# Run container
docker run -p 3000:3000 --env-file .env genmon4-backend
```

## Integration with Flutter App

The backend is designed to work seamlessly with the GenMon4 Flutter app:

1. **API Integration**: Replace Firebase calls with REST API calls
2. **WebSocket Client**: Implement Socket.IO client in Flutter
3. **Authentication**: Use JWT tokens for API authentication
4. **Real-time Updates**: Subscribe to WebSocket events for live updates

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

ISC License - see LICENSE file for details.

## Support

For support and questions, please open an issue in the repository. 
>>>>>>> 0df6b5ffd0a73ba47ae7921ccf86e80e012f120e
