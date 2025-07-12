import 'package:flutter/material.dart';
import 'story_flow.dart';
import 'package:genmon4/widgets/typewriter_text.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class MindVaultIntro extends StatefulWidget {
  const MindVaultIntro({super.key});

  @override
  State<MindVaultIntro> createState() => _MindVaultIntroState();
}

class _MindVaultIntroState extends State<MindVaultIntro> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Neon grid animated background
            const AnimatedBlocksBackground(neonColor: Color(0xFF00FFFF)),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Back',
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, const Color(0xFF00FF00).withOpacity(0.2), Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: "MindVault",
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          "MindVault",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF00FF00),
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            fontFamily: 'FiraMono',
                            letterSpacing: 1.5,
                            shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 18)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const TypewriterText(
                      text: "Deep within the digital subconscious, the MindVault holds secrets lost to time. Only the cleverest coders can unlock its gates...",
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'FiraMono',
                        shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 8)],
                      ),
                      duration: Duration(milliseconds: 60),
                      glitch: true,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const MindVaultStoryFlow(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Begin Quest', style: TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 