import 'package:flutter/material.dart';
import 'package:genmon4/screens/arenas/code_arena_screen.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AnimatedBlocksBackground(neonColor: Color(0xFF00BFFF)),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: const [
                  CircleAvatar(radius: 22, backgroundColor: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Arenas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Code Arena Button (styled for coding fantasy)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CodeArenaScreen()),
                        );
                      },
                      icon: const Icon(Icons.code, color: Color(0xFF00FF00), size: 32),
                      label: const Text(
                        'Code Arena',
                        style: TextStyle(
                          fontFamily: 'FiraMono, monospace',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00FF00),
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Color(0xFF00FF00),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: const BorderSide(color: Color(0xFF00FF00), width: 2),
                        elevation: 10,
                        shadowColor: const Color(0xFF00FF00),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 