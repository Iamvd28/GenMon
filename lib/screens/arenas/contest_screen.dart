import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contest_provider.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  late TextEditingController _codeController;
  int _secondsLeft = 120;
  bool _timerActive = true;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_timerActive || _secondsLeft <= 0) return false;
      setState(() => _secondsLeft--);
      if (_secondsLeft == 0) {
        _submitCode();
        return false;
      }
      return true;
    });
  }

  void _submitCode() {
    if (!Provider.of<ContestProvider>(context, listen: false).submitted) {
      Provider.of<ContestProvider>(context, listen: false).submitCode();
      setState(() => _timerActive = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContestProvider>(context);
    final submitted = provider.submitted;
    final question = provider.currentContest?.question ?? '';
    return WillPopScope(
      onWillPop: () async => submitted, // Prevent exit until submitted
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Contest: Code Arena',
                          style: TextStyle(
                            fontFamily: 'FiraMono',
                            color: Color(0xFF00FF00),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Color(0xFF00FF00), blurRadius: 10),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Color(0xFF00FF00), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer, color: Color(0xFF00FF00)),
                              const SizedBox(width: 8),
                              Text(
                                '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontFamily: 'FiraMono',
                                  color: Color(0xFF00FF00),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      question,
                      style: const TextStyle(
                        fontFamily: 'FiraMono',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF00FF00), width: 1.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _codeController,
                          enabled: !submitted,
                          maxLines: null,
                          style: const TextStyle(
                            fontFamily: 'FiraMono',
                            color: Color(0xFF00FF00),
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Write your code here...',
                            hintStyle: TextStyle(color: Colors.white54, fontFamily: 'FiraMono'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!submitted)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _submitCode,
                          icon: const Icon(Icons.send, color: Color(0xFF00FF00)),
                          label: const Text('Submit Code'),
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
                    if (submitted)
                      Center(
                        child: Column(
                          children: const [
                            Icon(Icons.check_circle, color: Color(0xFF00FF00), size: 48),
                            SizedBox(height: 12),
                            Text(
                              'Submitted',
                              style: TextStyle(
                                fontFamily: 'FiraMono',
                                color: Color(0xFF00FF00),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                shadows: [
                                  Shadow(color: Color(0xFF00FF00), blurRadius: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (submitted)
                Positioned(
                  bottom: 32,
                  right: 32,
                  child: FloatingActionButton.extended(
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.black,
                    foregroundColor: const Color(0xFF00FF00),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 