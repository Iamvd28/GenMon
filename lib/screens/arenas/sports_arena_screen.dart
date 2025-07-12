import 'package:flutter/material.dart';
import 'package:genmon4/screens/arenas/sports/cricket_matches_screen.dart';
import 'package:genmon4/screens/arenas/sports/football_matches_screen.dart';
import 'package:genmon4/screens/arenas/sports/basketball_matches_screen.dart';
import 'package:genmon4/screens/arenas/sports/baseball_matches_screen.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class SportsArenaScreen extends StatelessWidget {
  const SportsArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFF00BFFF)),
          DefaultTabController(
            length: 4,
            child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: const Text('Sports Arena'),
                backgroundColor: Colors.redAccent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.sports_cricket),
                      text: 'Cricket',
                    ),
                    Tab(
                      icon: Icon(Icons.sports_soccer),
                      text: 'Football',
                    ),
                    Tab(
                      icon: Icon(Icons.sports_basketball),
                      text: 'Basketball',
                    ),
                    Tab(
                      icon: Icon(Icons.sports_baseball),
                      text: 'Baseball',
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildSportScreen(
                    sportName: 'Cricket',
                    icon: Icons.sports_cricket,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CricketMatchesScreen()),
                      );
                    },
                  ),
                  _buildSportScreen(
                    sportName: 'Football',
                    icon: Icons.sports_soccer,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FootballMatchesScreen()),
                      );
                    },
                  ),
                  _buildSportScreen(
                    sportName: 'Basketball',
                    icon: Icons.sports_basketball,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BasketballMatchesScreen()),
                      );
                    },
                  ),
                  _buildSportScreen(
                    sportName: 'Baseball',
                    icon: Icons.sports_baseball,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BaseballMatchesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportScreen({
    required String sportName,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              '$sportName Matches',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Join $sportName Match', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
} 