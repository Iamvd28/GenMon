import 'package:flutter/material.dart';

class AnimatedBlocksBackground extends StatefulWidget {
  final Color neonColor;
  final bool simple; // If true, use lightweight mode
  const AnimatedBlocksBackground({Key? key, required this.neonColor, this.simple = false}) : super(key: key);

  @override
  State<AnimatedBlocksBackground> createState() => _AnimatedBlocksBackgroundState();
}

class _AnimatedBlocksBackgroundState extends State<AnimatedBlocksBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _symbols = [
    ';', '{', '}', '(', ')', '<', '>', '=', '+', '-', '*', '/', '#', '@', '%', '[', ']', '|', ':', ',', '.', '?', '!', '^', '&', '~', '`', ' 24'
  ];

  @override
  void initState() {
    super.initState();
    if (!widget.simple) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (!widget.simple) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gridSize = widget.simple ? 6 : (size.width > 900 ? 16 : size.width > 600 ? 10 : 5);
    final spanSize = size.width / gridSize;
    final rows = widget.simple ? 6 : (size.height / spanSize).ceil();
    final cols = gridSize;
    Widget grid = SizedBox.expand(
      child: Stack(
        children: [
          // Static or animated background gradient
          Positioned.fill(
            child: widget.simple
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Color.lerp(Colors.black, widget.neonColor, 0.2)!,
                          Colors.black,
                        ],
                      ),
                    ),
                  )
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Color.lerp(Colors.black, widget.neonColor, 0.15 + 0.15 * (_controller.value))!,
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
          ),
          // Grid of blocks with symbols (no hover, no shadow in simple mode)
          ...[
            for (int y = 0; y < rows; y++)
              for (int x = 0; x < cols; x++)
                Positioned(
                  left: x * spanSize,
                  top: y * spanSize,
                  child: Container(
                    width: spanSize - 2,
                    height: spanSize - 2,
                    decoration: BoxDecoration(
                      color: widget.simple ? const Color(0xFF181818) : widget.neonColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        _symbols[(y * cols + x) % _symbols.length],
                        style: TextStyle(
                          fontFamily: 'FiraMono, monospace',
                          fontSize: spanSize * 0.5,
                          color: widget.neonColor.withOpacity(widget.simple ? 0.5 : 1.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
          // Neon overlay (static in simple mode)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      widget.neonColor.withOpacity(widget.simple ? 0.05 : 0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.simple) return grid;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => grid,
    );
  }
} 