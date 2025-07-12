import 'package:flutter/material.dart';
import 'challenge_screen.dart';
import 'package:genmon4/widgets/typewriter_text.dart';
import 'data.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class CompilerProphecyStoryFlow extends StatefulWidget {
  const CompilerProphecyStoryFlow({super.key});

  @override
  State<CompilerProphecyStoryFlow> createState() => _CompilerProphecyStoryFlowState();
}

class _StoryPageData {
  final String storyText;
  final Color background;
  final String challengePrompt;
  final String challengeTitle;
  final int chapterIndex;
  const _StoryPageData({
    required this.storyText,
    required this.background,
    required this.challengePrompt,
    required this.challengeTitle,
    required this.chapterIndex,
  });
}

class _CompilerProphecyStoryFlowState extends State<CompilerProphecyStoryFlow> {
  final PageController _controller = PageController();
  int _page = 0;

  late final List<_StoryPageData> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List.generate(
      compilerProphecyChapters.length,
      (i) => _StoryPageData(
        storyText: compilerProphecyChapters[i].story,
        background: Colors.black,
        challengePrompt: compilerProphecyChapters[i].challengePrompt,
        challengeTitle: compilerProphecyChapters[i].challengeTitle,
        chapterIndex: i,
      ),
    );
  }

  int get _currentChapter => (_page ~/ 2) + 1;
  int get _totalChapters => _pages.length;
  double get _progress => _currentChapter / _totalChapters;

  void _nextPage() {
    if (_page < _pages.length * 2 - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFF00FF00)),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF00)),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Back',
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white12,
                          color: const Color(0xFF00FF00),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Chapter $_currentChapter/$_totalChapters',
                        style: const TextStyle(
                          color: Color(0xFF00FF00),
                          fontFamily: 'FiraMono',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pages.length * 2,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final isStory = index % 2 == 0;
                    final chapter = _pages[index ~/ 2];
                    if (isStory) {
                      return _StoryPage(
                        text: chapter.storyText,
                        background: chapter.background,
                        onNext: _nextPage,
                        isLast: false,
                        chapterIndex: chapter.chapterIndex,
                      );
                    } else {
                      return CompilerProphecyChallengeScreen(
                        prompt: chapter.challengePrompt,
                        title: chapter.challengeTitle,
                        chapterIndex: chapter.chapterIndex,
                        onNext: _nextPage,
                        isFinal: chapter.chapterIndex == _pages.length - 1,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  final String text;
  final Color background;
  final VoidCallback onNext;
  final bool isLast;
  final int chapterIndex;
  const _StoryPage({required this.text, required this.background, required this.onNext, required this.isLast, required this.chapterIndex});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chapter ${chapterIndex + 1}',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'FiraMono',
                  shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 12)],
                ),
              ),
              const SizedBox(height: 16),
              TypewriterText(
                text: text,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'FiraMono',
                  shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 8)],
                ),
                duration: const Duration(milliseconds: 45),
                glitch: true,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color(0xFF00FF00),
                  side: const BorderSide(color: Color(0xFF00FF00), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Next', style: TextStyle(fontFamily: 'FiraMono', fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 