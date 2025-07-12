import 'package:flutter/material.dart';
import 'dart:async';
import 'package:genmon4/screens/arenas/leaderboard_screen.dart';
import 'package:genmon4/screens/arenas/contest_result_screen.dart';
import 'package:provider/provider.dart';
import 'package:genmon4/providers/auth_provider.dart';
import 'package:genmon4/screens/home/home_screen.dart';

class ContestPage extends StatefulWidget {
  final String contestTitle;
  final DateTime? startTime;
  const ContestPage({super.key, required this.contestTitle, this.startTime});

  @override
  State<ContestPage> createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage> {
  late Timer _timer;
  Duration _timeLeft = const Duration(hours: 2, minutes: 30);
  int _currentQuestion = 0;
  final List<String> _questions = [
    'Implement a binary search algorithm.',
    'Write a function to detect cycles in a graph.',
    'Design a thread-safe queue.',
    'Find the longest palindromic substring.',
    'Optimize a dynamic programming solution for knapsack.',
  ];
  final List<String> _answers = List.filled(5, '');
  bool _isSubmitting = false;
  bool _submitted = false;
  DateTime? _startTime;
  int _totalTyped = 0;
  int _totalCorrect = 0;
  String _output = '';
  final TextEditingController _codeController = TextEditingController();
  DateTime? _lastNavigationTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_timeLeft > Duration.zero) {
          _timeLeft -= const Duration(seconds: 1);
        } else {
          _timer.cancel();
        }
      });
    });
    _codeController.text = _answers[_currentQuestion];
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _runCode() async {
    setState(() {
      _output = 'Running...';
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _output = 'Output: (simulated)\nYour code ran for: \n${_questions[_currentQuestion]}';
    });
  }

  void _submit() async {
    setState(() { _isSubmitting = true; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSubmitting = false;
      _submitted = true;
      _totalTyped = _answers.fold(0, (sum, ans) => sum + ans.length);
      _totalCorrect = _answers.where((ans) => ans.isNotEmpty).length;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _onCodeChanged(String val) {
    _answers[_currentQuestion] = val;
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentQuestion = index;
      _codeController.text = _answers[index];
      _output = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.contestTitle, style: const TextStyle(fontFamily: 'FiraMono', color: Color(0xFF00FF00))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _submitted
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 64),
                    const SizedBox(height: 16),
                    const Text('Your code is submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00FF00), fontFamily: 'FiraMono', shadows: [Shadow(color: Colors.greenAccent, blurRadius: 12)])),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leaderboard Button - Big and Prominent
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('Big Leaderboard button pressed');
                        
                        // Debounce navigation to prevent multiple rapid clicks
                        final now = DateTime.now();
                        if (_lastNavigationTime != null && 
                            now.difference(_lastNavigationTime!) < const Duration(milliseconds: 500)) {
                          print('Navigation debounced - too soon since last navigation');
                          return;
                        }
                        _lastNavigationTime = now;
                        
                        try {
                          final authProvider = Provider.of<AuthStateProvider>(context, listen: false);
                          String userName = authProvider.currentUser?.displayName ?? authProvider.currentUser?.email ?? 'Guest';
                          print('Navigating to LeaderboardScreen with user: $userName');
                          
                          // Use Future.delayed to ensure navigation happens after current frame
                          Future.delayed(Duration.zero, () {
                            if (mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => LeaderboardScreen(currentUser: userName)),
                              );
                            }
                          });
                        } catch (e) {
                          print('Error navigating to leaderboard: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error opening leaderboard: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.leaderboard, color: Colors.black, size: 32),
                      label: const Text(
                        'LEADERBOARD',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FiraMono',
                          letterSpacing: 2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF00),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF00FF00).withOpacity(0.5),
                      ),
                    ),
                  ),
                  
                  Text('Time Left: ${_timeLeft.inHours.toString().padLeft(2, '0')}:${(_timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 22, color: Colors.redAccent, fontFamily: 'FiraMono', fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.red, blurRadius: 8)])),
                  const SizedBox(height: 16),
                  Text('Question ${_currentQuestion + 1}/5:', style: const TextStyle(color: Color(0xFF00FF00), fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'FiraMono', shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 8)])),
                  Text(_questions[_currentQuestion], style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'FiraMono')),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00FF00), width: 2),
                      boxShadow: [BoxShadow(color: Color(0xFF00FF00).withOpacity(0.3), blurRadius: 16)],
                    ),
                    child: TextField(
                      controller: _codeController,
                      maxLines: 12,
                      minLines: 8,
                      style: const TextStyle(fontFamily: 'FiraMono', color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Write your code here...',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      onChanged: _onCodeChanged,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _runCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF00),
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Run'),
                      ),
                      const SizedBox(width: 16),
                      if (_output.isNotEmpty)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(_output, style: const TextStyle(color: Colors.white, fontFamily: 'FiraMono')),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentQuestion > 0)
                        ElevatedButton(
                          onPressed: () => _goToQuestion(_currentQuestion - 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: const Color(0xFF00FF00),
                            textStyle: const TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Previous'),
                        ),
                      if (_currentQuestion < 4)
                        ElevatedButton(
                          onPressed: () => _goToQuestion(_currentQuestion + 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: const Color(0xFF00FF00),
                            textStyle: const TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Next'),
                        ),
                      if (_currentQuestion == 4)
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF00),
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold),
                          ),
                          child: _isSubmitting ? const CircularProgressIndicator() : const Text('Submit'),
                        ),
                    ],
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print('FAB Leaderboard button pressed');
          
          // Debounce navigation to prevent multiple rapid clicks
          final now = DateTime.now();
          if (_lastNavigationTime != null && 
              now.difference(_lastNavigationTime!) < const Duration(milliseconds: 500)) {
            print('Navigation debounced - too soon since last navigation');
            return;
          }
          _lastNavigationTime = now;
          
          try {
            final authProvider = Provider.of<AuthStateProvider>(context, listen: false);
            String userName = authProvider.currentUser?.displayName ?? authProvider.currentUser?.email ?? 'Guest';
            print('Navigating to LeaderboardScreen with user: $userName');
            
            // Use Future.delayed to ensure navigation happens after current frame
            Future.delayed(Duration.zero, () {
              if (mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LeaderboardScreen(currentUser: userName)),
                );
              }
            });
          } catch (e) {
            print('Error navigating to leaderboard: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error opening leaderboard: $e')),
            );
          }
        },
        icon: const Icon(Icons.leaderboard, color: Colors.black),
        label: const Text(
          'LEADERBOARD',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'FiraMono',
          ),
        ),
        backgroundColor: const Color(0xFF00FF00),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
} 