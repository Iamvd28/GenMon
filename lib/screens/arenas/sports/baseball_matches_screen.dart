import 'package:flutter/material.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class BaseballMatchesScreen extends StatelessWidget {
  const BaseballMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFF00BFFF)),
          // ... existing content ...
        ],
      ),
    );
  }
} 