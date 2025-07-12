import 'package:flutter/material.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class BasketballMatchesScreen extends StatelessWidget {
  const BasketballMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFF9B30FF)),
          Center(
            child: Text(
              'Basketball Matches Coming Soon!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 