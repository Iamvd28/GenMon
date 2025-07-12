import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Color> _colors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
  ];
  int _currentColorIndex = 0;
  int _nextColorIndex = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value >= 0.99) {
          _currentColorIndex = _nextColorIndex;
          _nextColorIndex = (_nextColorIndex + 1) % _colors.length;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  _colors[_currentColorIndex],
                  _colors[_nextColorIndex],
                  _controller.value,
                )!,
                Color.lerp(
                  _colors[_currentColorIndex].withOpacity(0.5),
                  _colors[_nextColorIndex].withOpacity(0.5),
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: CustomPaint(
            painter: _AnimatedBackgroundPainter(
              animation: _controller,
              colors: _colors,
              currentIndex: _currentColorIndex,
              nextIndex: _nextColorIndex,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;
  final int currentIndex;
  final int nextIndex;

  _AnimatedBackgroundPainter({
    required this.animation,
    required this.colors,
    required this.currentIndex,
    required this.nextIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.1);

    final random = Random(42);
    final numberOfCircles = 20;

    for (var i = 0; i < numberOfCircles; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 100 + 50;

      canvas.drawCircle(
        Offset(x, y),
        radius * (0.5 + 0.5 * sin(animation.value * 2 * pi + i)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 