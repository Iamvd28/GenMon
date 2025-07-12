import 'package:flutter/material.dart';
import 'leaderboard_screen.dart';
import 'package:genmon4/screens/home/home_screen.dart';

class ContestResultScreen extends StatefulWidget {
  final int userRank;
  final int previousRank;
  final int totalPlayers;
  final String userName;
  const ContestResultScreen({
    super.key,
    required this.userRank,
    required this.previousRank,
    required this.totalPlayers,
    required this.userName,
  });

  @override
  State<ContestResultScreen> createState() => _ContestResultScreenState();
}

class _ContestResultScreenState extends State<ContestResultScreen> {
  int get winningAmount {
    final r = widget.userRank;
    if (r == 1) return 500000;
    if (r == 2 || r == 3) return 100000;
    if (r >= 4 && r <= 10) return 50000;
    if (r >= 11 && r <= 100) return 5000;
    if (r >= 101 && r <= 1000) return 500;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isUp = widget.userRank < widget.previousRank;
    final isDown = widget.userRank > widget.previousRank;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        elevation: 0,
      ),
      body: PageView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your Live Rank', style: TextStyle(color: Colors.white70, fontSize: 20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('#${widget.userRank}', style: const TextStyle(color: Color(0xFF00FF00), fontSize: 48, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.greenAccent, blurRadius: 16)])),
                      if (isUp)
                        const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 36),
                      if (isDown)
                        const Icon(Icons.arrow_downward, color: Colors.redAccent, size: 36),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Winning Amount', style: TextStyle(color: Colors.white70, fontSize: 20)),
                  Text('Rs $winningAmount', style: const TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.amber, blurRadius: 16)])),
                  const SizedBox(height: 32),
                  Text('Total Players: ${widget.totalPlayers}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 18)),
                  const SizedBox(height: 32),
                  const Text('Swipe left to see the full leaderboard', style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            ),
          ),
          LeaderboardScreen(currentUser: widget.userName),
        ],
      ),
    );
  }
} 