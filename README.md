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