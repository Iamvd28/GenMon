import 'package:flutter/material.dart';
import '../models/contest.dart';
import 'dart:math';

class ContestProvider extends ChangeNotifier {
  Contest? _currentContest;
  String? _userId;
  bool _submitted = false;
  final List<String> _questions = [
    'Write a function to reverse a string in Python.',
    'Implement a function to check if a number is prime.',
    'Write a function to find the factorial of a number.',
    'Implement a function to check if a string is a palindrome.',
    'Write a function to return the nth Fibonacci number.',
  ];

  Contest? get currentContest => _currentContest;
  bool get submitted => _submitted;
  int get joinedCount => _currentContest?.participants.length ?? 0;
  int get maxParticipants => _currentContest?.maxParticipants ?? 5;
  String? get userId => _userId;

  void setUser(String userId) {
    _userId = userId;
  }

  void createDemoContest() {
    final random = Random();
    final question = _questions[random.nextInt(_questions.length)];
    _currentContest = Contest(
      id: '1',
      title: 'Code Arena Contest',
      question: question,
      participants: [],
      maxParticipants: 5,
      status: 'waiting',
      startTime: null,
    );
    _submitted = false;
    notifyListeners();
  }

  void joinContest() {
    if (_userId == null || _currentContest == null) return;
    if (!_currentContest!.participants.contains(_userId!)) {
      _currentContest!.participants.add(_userId!);
      notifyListeners();
    }
  }

  void startContest() {
    if (_currentContest == null) return;
    _currentContest = Contest(
      id: _currentContest!.id,
      title: _currentContest!.title,
      question: _currentContest!.question,
      participants: _currentContest!.participants,
      maxParticipants: _currentContest!.maxParticipants,
      status: 'live',
      startTime: DateTime.now(),
    );
    _submitted = false;
    notifyListeners();
  }

  void submitCode() {
    _submitted = true;
    notifyListeners();
  }

  // For backend integration, add methods to sync/join/start/submit via API

  // For My Matches: get a summary of the contest for the current user
  Map<String, dynamic>? getMyContestSummary() {
    if (_currentContest == null || _userId == null) return null;
    if (!_currentContest!.participants.contains(_userId!)) return null;
    return {
      'title': _currentContest!.title,
      'question': _currentContest!.question,
      'status': _currentContest!.status,
      'submitted': _submitted,
      'startTime': _currentContest!.startTime,
    };
  }
} 