import 'package:flutter/material.dart';
import 'package:genmon4/screens/auth/login_screen.dart';
import 'package:genmon4/widgets/neon_grid_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainTextController;
  late AnimationController _subTextController;
  late Animation<double> _mainTextScale;
  late Animation<double> _mainTextFade;
  late Animation<double> _subTextFade;
  late Animation<Offset> _subTextSlide;

  @override
  void initState() {
    super.initState();

    _mainTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _mainTextScale = CurvedAnimation(
      parent: _mainTextController,
      curve: Curves.easeInOutCubic,
    );
    _mainTextFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainTextController, curve: Curves.easeIn),
    );

    _subTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _subTextFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _subTextController, curve: Curves.easeInOutCubic),
    );
    _subTextSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _subTextController, curve: Curves.easeOutCubic));

    _mainTextController.forward();

    Future.delayed(const Duration(milliseconds: 900), () {
      _subTextController.forward();
    });

    print('SplashScreen: Timer started');
    Future.delayed(const Duration(seconds: 3), () {
      print('SplashScreen: Timer done, navigating to LoginScreen');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainTextController.dispose();
    _subTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Colors.cyanAccent),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _mainTextController,
                  builder: (context, child) => Opacity(
                    opacity: _mainTextFade.value,
                    child: Transform.scale(
                      scale: _mainTextScale.value,
                      child: child,
                    ),
                  ),
                  child: const Text(
                    'GENMON',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _subTextController,
                  builder: (context, child) => Opacity(
                    opacity: _subTextFade.value,
                    child: SlideTransition(
                      position: _subTextSlide,
                      child: child,
                    ),
                  ),
                  child: const Text(
                    'WHERE MIND CONNECTS MONEY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 