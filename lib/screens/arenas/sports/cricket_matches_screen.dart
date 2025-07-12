import 'package:flutter/material.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class CricketMatchesScreen extends StatelessWidget {
  const CricketMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFFFFA500)),
          Center(
            child: Text(
              'Cricket Matches Coming Soon!',
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