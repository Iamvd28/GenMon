import 'package:flutter/material.dart';
import 'dart:async';
import 'live_contest_screen.dart';

class LiveContestWaitingScreen extends StatefulWidget {
  final String language;
  final List<String> questions;
  final Duration timeToStart;
  const LiveContestWaitingScreen({required this.language, required this.questions, required this.timeToStart, Key? key}) : super(key: key);

  @override
  State<LiveContestWaitingScreen> createState() => _LiveContestWaitingScreenState();
}

class _LiveContestWaitingScreenState extends State<LiveContestWaitingScreen> {
  late Duration _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timeToStart;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > Duration.zero) {
          _timeLeft -= const Duration(seconds: 1);
        }
        if (_timeLeft <= Duration.zero) {
          _timer?.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LiveContestScreen(
                  language: widget.language,
                  questions: widget.questions,
                ),
              ),
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: Color(0xFF00FF00), size: 60),
            const SizedBox(height: 24),
            Text(
              'Waiting for the contest to start...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'FiraMono',
                shadows: [
                  Shadow(color: Color(0xFF00FF00), blurRadius: 10),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Contest will start in:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'FiraMono',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatDuration(_timeLeft),
              style: const TextStyle(
                color: Color(0xFF00FF00),
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'FiraMono',
                shadows: [
                  Shadow(color: Color(0xFF00FF00), blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFF00FF00)),
            const SizedBox(height: 32),
            Text(
              'You will be taken to the contest automatically when it starts.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'FiraMono',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 