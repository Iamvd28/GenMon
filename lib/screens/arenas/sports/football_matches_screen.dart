import 'package:flutter/material.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class FootballMatchesScreen extends StatelessWidget {
  const FootballMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFFFF1744)),
          Center(
            child: Text(
              'Football Matches Coming Soon!',
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