import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LiveContestScreen extends StatefulWidget {
  final String language;
  final List<String> questions;
  const LiveContestScreen({required this.language, required this.questions, Key? key}) : super(key: key);

  @override
  State<LiveContestScreen> createState() => _LiveContestScreenState();
}

class _LiveContestScreenState extends State<LiveContestScreen> {
  late List<TextEditingController> _answerControllers;
  int _currentIndex = 0;
  late Duration _timeLeft;
  late final DateTime _endTime;
  late final Ticker _ticker;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _answerControllers = List.generate(widget.questions.length, (_) => TextEditingController());
    _timeLeft = const Duration(hours: 2, minutes: 30);
    _endTime = DateTime.now().add(_timeLeft);
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final left = _endTime.difference(DateTime.now());
    if (left.isNegative) {
      _ticker.stop();
      setState(() => _timeLeft = Duration.zero);
    } else {
      setState(() => _timeLeft = left);
    }
  }

  @override
  void dispose() {
    for (final c in _answerControllers) {
      c.dispose();
    }
    _ticker.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  void _submitAll() {
    setState(() {
      _submitted = true;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Submitted!', style: TextStyle(color: Color(0xFF00FF00), fontFamily: 'FiraMono', fontWeight: FontWeight.bold)),
        content: const Text('Your answers have been submitted.', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00FF00))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${widget.language} Live Contest', style: const TextStyle(color: Color(0xFF00FF00), fontFamily: 'FiraMono', fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF00FF00)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time Left: ${_formatDuration(_timeLeft)}', style: const TextStyle(color: Color(0xFF00FF00), fontFamily: 'FiraMono', fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: List.generate(widget.questions.length, (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('Q${i+1}', style: TextStyle(color: _currentIndex == i ? Colors.black : Color(0xFF00FF00), fontFamily: 'FiraMono', fontWeight: FontWeight.bold)),
                      selected: _currentIndex == i,
                      selectedColor: Color(0xFF00FF00),
                      backgroundColor: Colors.black,
                      onSelected: (selected) {
                        setState(() => _currentIndex = i);
                      },
                    ),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Q${_currentIndex+1}:', style: const TextStyle(color: Color(0xFF00FF00), fontFamily: 'FiraMono', fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text(widget.questions[_currentIndex], style: const TextStyle(color: Colors.white, fontFamily: 'FiraMono', fontSize: 18)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF00FF00), width: 1.5),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('ANSWER', style: TextStyle(color: Color(0xFF00FF00), fontFamily: 'FiraMono', fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_downward, color: Color(0xFF00FF00)),
                    ],
                  ),
                  TextField(
                    controller: _answerControllers[_currentIndex],
                    maxLines: null,
                    enabled: !_submitted && _timeLeft > Duration.zero,
                    style: const TextStyle(color: Color(0xFF00FF00), fontFamily: 'FiraMono', fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your answer here...',
                      hintStyle: TextStyle(color: Colors.white54, fontFamily: 'FiraMono'),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: (!_submitted && _timeLeft > Duration.zero) ? _submitAll : null,
                icon: const Icon(Icons.send, color: Color(0xFF00FF00)),
                label: const Text('Submit All Answers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Color(0xFF00FF00),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  side: const BorderSide(color: Color(0xFF00FF00), width: 2),
                  textStyle: const TextStyle(
                    fontFamily: 'FiraMono',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Color(0xFF00FF00),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 