import 'package:flutter/material.dart';
import 'dart:async';
import 'contest_page.dart';
import 'code_arena_screen.dart';
import 'contest_waiting_room_screen.dart';
import 'contest_screen.dart';

class ContestWaitingRoomScreen extends StatefulWidget {
  final String contestTitle;
  final DateTime startTime;
  final VoidCallback? onSubmit;
  const ContestWaitingRoomScreen({super.key, required this.contestTitle, required this.startTime, this.onSubmit});

  @override
  State<ContestWaitingRoomScreen> createState() => _ContestWaitingRoomScreenState();
}

class _ContestWaitingRoomScreenState extends State<ContestWaitingRoomScreen> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final diff = widget.startTime.difference(now);
    setState(() {
      _timeLeft = diff.isNegative ? Duration.zero : diff;
    });
    if (_timeLeft == Duration.zero) {
      _timer?.cancel();
      _timer = null;
      if (widget.onSubmit != null) widget.onSubmit!();
      // Use Future.delayed to ensure navigation happens after current frame
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ContestPage(contestTitle: widget.contestTitle, startTime: widget.startTime),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const CodeArenaScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Waiting for Contest to Start...', style: TextStyle(color: Colors.white70, fontSize: 24)),
            const SizedBox(height: 32),
            Text(
              _timeLeft == Duration.zero
                  ? 'Starting...'
                  : 'Contest starts in:',
              style: const TextStyle(fontSize: 32, color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
            if (_timeLeft > Duration.zero)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '${_timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 64, color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [Shadow(color: Colors.green, blurRadius: 16)]),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 