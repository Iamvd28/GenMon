import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration duration;
  final VoidCallback? onComplete;
  final bool glitch;
  final bool sound;

  const TypewriterText({
    super.key,
    required this.text,
    this.textStyle,
    this.duration = const Duration(milliseconds: 50),
    this.onComplete,
    this.glitch = false,
    this.sound = true,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _charCount;
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _lastChar = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.text.length * widget.duration.inMilliseconds),
    );
    _charCount = StepTween(begin: 0, end: widget.text.length).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.onComplete != null) {
          widget.onComplete!();
        }
      })
      ..addListener(_onCharChange);
    _controller.forward();
  }

  void _onCharChange() async {
    if (!widget.sound) return;
    if (_charCount.value > _lastChar) {
      _lastChar = _charCount.value;
      // Play a short click sound (asset: assets/sounds/type.wav)
      await _audioPlayer.play(AssetSource('sounds/type.wav'), volume: 0.2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _charCount,
      builder: (context, child) {
        final text = widget.text.substring(0, _charCount.value);
        if (!widget.glitch) {
          return Text(
            text,
            style: (widget.textStyle ?? const TextStyle()).copyWith(
              shadows: const [Shadow(color: Color(0xFF00FF00), blurRadius: 12)],
            ),
          );
        }
        // Glitch effect: randomly offset/color some chars
        List<InlineSpan> spans = [];
        for (int i = 0; i < text.length; i++) {
          if (_random.nextDouble() < 0.07) {
            // Glitch this char
            spans.add(WidgetSpan(
              child: Transform.translate(
                offset: Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
                child: Text(
                  text[i],
                  style: (widget.textStyle ?? const TextStyle()).copyWith(
                    color: _random.nextBool() ? Colors.greenAccent : Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    shadows: const [Shadow(color: Color(0xFF00FF00), blurRadius: 16)],
                  ),
                ),
              ),
            ));
          } else {
            spans.add(TextSpan(
              text: text[i],
              style: (widget.textStyle ?? const TextStyle()).copyWith(
                shadows: const [Shadow(color: Color(0xFF00FF00), blurRadius: 12)],
              ),
            ));
          }
        }
        return RichText(text: TextSpan(children: spans));
      },
    );
  }
} 