import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Match {
  final String id;
  final String name;
  final String type; // 'sports', 'code', 'quiz'
  final String category; // specific sport/language/subject
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'upcoming', 'live', 'completed'
  final int? score;

  Match({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.startTime,
    this.endTime,
    required this.status,
    this.score,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      status: json['status'] ?? '',
      score: json['score'],
    );
  }
}

Future<void> saveLeaderboardEntry({
  required String name,
  required int score,
  required double accuracy,
  required int speed,
}) async {
  await FirebaseFirestore.instance.collection('leaderboard').add({
    'name': name,
    'score': score,
    'accuracy': accuracy,
    'speed': speed,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

class LeaderboardScreen extends StatelessWidget {
  final String currentUser;

  const LeaderboardScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation of the LeaderboardScreen widget
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      body: Center(child: Text('Leaderboard screen content')),
    );
  }
}

class MatchCard extends StatelessWidget {
  final Match match;

  const MatchCard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation of the MatchCard widget
    return Card(
      // Implementation of the card content
    );
  }
}

class MatchScreen extends StatelessWidget {
  final Match match;

  const MatchScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation of the MatchScreen widget
    return Scaffold(
      appBar: AppBar(title: Text(match.name)),
      body: Center(child: Text('Match screen content')),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implementation of the HomeScreen widget
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(child: Text('Home screen content')),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add your providers here
      ],
      child: MaterialApp(
        title: 'Match App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

void main() => runApp(App()); 