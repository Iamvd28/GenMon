import 'package:flutter/material.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class ResistanceTerminalChallengeScreen extends StatefulWidget {
  final String prompt;
  final String title;
  final int chapterIndex;
  final VoidCallback onNext;
  final bool isFinal;
  const ResistanceTerminalChallengeScreen({
    super.key,
    required this.prompt,
    required this.title,
    required this.chapterIndex,
    required this.onNext,
    required this.isFinal,
  });

  @override
  State<ResistanceTerminalChallengeScreen> createState() => _ResistanceTerminalChallengeScreenState();
}

class _ResistanceTerminalChallengeScreenState extends State<ResistanceTerminalChallengeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _feedback;
  bool _isCorrect = false;
  bool _ran = false;

  // Demo: expected code output for each challenge
  static const expectedOutputs = [
    'bcdfghjklmnpqrstvwxyz', // Chapter 1: string with vowels removed (demo)
    '[11, 42]', // Chapter 2: numbers > 10 (demo)
  ];

  // Mock code checker: just checks if the code contains the expected output string
  void _runCode() {
    final code = _controller.text.trim();
    final expected = expectedOutputs[widget.chapterIndex];
    final correct = code.contains(expected);
    setState(() {
      _ran = true;
      _isCorrect = correct;
      _feedback = correct ? 'Success! You may proceed.' : 'Oops, you lost! Go learn lil baby';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFFFF00FF)),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFFF00FF)),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Back',
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.terminal, color: Color(0xFFFF00FF), size: 60),
                    const SizedBox(height: 32),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFF00FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontFamily: 'FiraMono',
                        shadows: [Shadow(color: Color(0xFFFF00FF), blurRadius: 18)],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.prompt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'FiraMono',
                        shadows: [Shadow(color: Color(0xFFFF00FF), blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: TextField(
                        controller: _controller,
                        maxLines: 10,
                        minLines: 6,
                        style: const TextStyle(color: Color(0xFFFF00FF), fontFamily: 'FiraMono', fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Write your code here... (Python recommended)',
                          hintStyle: const TextStyle(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFFF00FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: Colors.black.withOpacity(0.7),
                          filled: true,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _runCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: const Color(0xFFFF00FF),
                            side: const BorderSide(color: Color(0xFFFF00FF), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Run', style: TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isCorrect ? widget.onNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: const Color(0xFFFF00FF),
                            side: const BorderSide(color: Color(0xFFFF00FF), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(widget.isFinal ? 'Finish' : 'Next', style: const TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (_ran && _feedback != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _feedback!,
                        style: TextStyle(
                          color: _isCorrect ? Colors.pinkAccent : Colors.redAccent,
                          fontFamily: 'FiraMono',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(color: _isCorrect ? Colors.pink : Colors.red, blurRadius: 8),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 