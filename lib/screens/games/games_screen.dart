import 'package:flutter/material.dart';
import 'stories/compiler_prophecy/intro.dart';
import 'stories/mindvault/intro.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      _GameData(
        title: "The Compiler's Prophecy",
        tagline: "Awaken the Source Code and battle the Bug Lords",
        introBuilder: (ctx) => const CompilerProphecyIntro(),
      ),
      _GameData(
        title: "MindVault",
        tagline: "Hack the vaults of your mind.",
        introBuilder: (ctx) => const MindVaultIntro(),
      ),
      _GameData(
        title: "Resistance Terminal",
        tagline: "Join the code resistance.",
        introBuilder: (ctx) => const Placeholder(),
      ),
      _GameData(
        title: "BugMine",
        tagline: "Dig deep, debug deeper.",
        introBuilder: (ctx) => const Placeholder(),
      ),
      _GameData(
        title: "GlitchGate",
        tagline: "Escape the infinite loop.",
        introBuilder: (ctx) => const Placeholder(),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Games', style: TextStyle(color: Colors.white)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.85,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return _GameCard(game: game);
        },
      ),
    );
  }
}

class _GameData {
  final String title;
  final String tagline;
  final WidgetBuilder introBuilder;
  const _GameData({required this.title, required this.tagline, required this.introBuilder});
}

class _GameCard extends StatelessWidget {
  final _GameData game;
  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: game.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => game.introBuilder(context),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00FF00), width: 2),
              color: Colors.black.withOpacity(0.85),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF00).withOpacity(0.2),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated thumbnail placeholder
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00FF00), width: 1),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF00FF00), size: 40),
                ),
                const SizedBox(height: 18),
                Text(
                  game.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF00FF00),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'FiraMono',
                    shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 12)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'FiraMono',
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => game.introBuilder(context),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: const Color(0xFF00FF00),
                    side: const BorderSide(color: Color(0xFF00FF00), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Play', style: TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 