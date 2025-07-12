import 'package:flutter/material.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';
import 'package:genmon4/providers/contest_provider.dart';
import 'package:provider/provider.dart';
import 'package:genmon4/screens/arenas/contest_waiting_room_screen.dart';
import 'dart:async';
import 'package:genmon4/screens/arenas/live_contest_screen.dart';
import 'package:genmon4/screens/arenas/live_contest_waiting_screen.dart';
import 'package:genmon4/screens/arenas/practice_contest_screen.dart';
import 'package:genmon4/screens/arenas/payment_screen.dart';
import 'package:genmon4/screens/arenas/contest_page.dart';
import 'package:genmon4/services/match_service.dart';
import 'package:genmon4/models/match.dart';

class CodeArenaScreen extends StatefulWidget {
  const CodeArenaScreen({super.key});

  @override
  State<CodeArenaScreen> createState() => _CodeArenaScreenState();
}

class _CodeArenaScreenState extends State<CodeArenaScreen> {
  int _selectedTab = 0; // 0: Live Matches, 1: Practice
  int userBalance = 100000; // Simulated user balance

  final Set<String> _paidContests = {}; // Track paid contests for this session
  final Set<String> _submittedContests = {}; // Track submitted contests for this session
  String userId = "HluqKfSyt734wPozzG3W";

  final List<Map<String, dynamic>> contests = [
    { 'price': 19, 'maxParticipants': 10000000, 'prizePool': 10000000, 'firstPrize': 500000, 'thirdPrize': 100000 },
    { 'price': 49, 'maxParticipants': 10000000, 'prizePool': 10000000, 'firstPrize': 500000, 'thirdPrize': 100000 },
    { 'price': 59, 'maxParticipants': 50000, 'prizePool': 50000, 'firstPrize': 25000, 'thirdPrize': 5000 },
    { 'price': 39, 'maxParticipants': 10000000, 'prizePool': 10000000, 'firstPrize': 500000, 'thirdPrize': 100000 },
    { 'price': 25000, 'maxParticipants': 5, 'prizePool': 125000, 'firstPrize': 100000, 'thirdPrize': 25000 },
    { 'price': 50000, 'maxParticipants': 3, 'prizePool': 150000, 'firstPrize': 100000, 'thirdPrize': 50000 },
  ];

  void _showPaymentDialog(BuildContext context, Map<String, dynamic> contest) async {
    final DateTime now = DateTime.now();
    final DateTime startTime = contest['startTime'] ?? now.add(const Duration(minutes: 2));
    final String contestId = contest['id'].toString();
    if (_paidContests.contains(contestId)) {
      // Already paid, go directly to waiting room
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContestWaitingRoomScreen(
            contestTitle: contest['title'],
            startTime: startTime,
          ),
        ),
      );
      return;
    }
    if (startTime.difference(now).inMinutes < 5 && startTime.difference(now) > Duration.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hurry! Contest is starting soon. Join up before time runs out!'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(contest: contest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Code Arena', style: TextStyle(color: Color(0xFF00FF00), fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFFFFA500)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Code Arena',
                        style: TextStyle(
                          fontFamily: 'FiraMono',
                          color: Color(0xFF00FF00),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Color(0xFF00FF00),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TabButton(
                      label: 'Live Matches',
                      selected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                    const SizedBox(width: 16),
                    _TabButton(
                      label: 'Practice',
                      selected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ],
                ),
                Expanded(
                  child: _selectedTab == 0
                      ? _LiveMatchesTab(
                          userBalance: userBalance,
                          onJoinContest: (contest) => _showPaymentDialog(context, contest),
                          paidContests: _paidContests,
                          submittedContests: _submittedContests,
                        )
                      : _PracticeTab(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00FF00) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF00FF00), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : const Color(0xFF00FF00),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _LiveMatchesTab extends StatefulWidget {
  final int userBalance;
  final Function(Map<String, dynamic>) onJoinContest;
  final Set<String> paidContests;
  final Set<String> submittedContests;
  const _LiveMatchesTab({required this.userBalance, required this.onJoinContest, required this.paidContests, required this.submittedContests});

  @override
  State<_LiveMatchesTab> createState() => _LiveMatchesTabState();
}

class _LiveMatchesTabState extends State<_LiveMatchesTab> {
  late final List<Map<String, dynamic>> contests;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    contests = List.generate(24, (i) {
      // Set startTime to the next i-th hour (e.g., 23:00, 00:00, 01:00, ...)
      final base = now.minute > 0 || now.second > 0 || now.millisecond > 0
          ? now.add(Duration(hours: 1)).subtract(Duration(minutes: now.minute, seconds: now.second, milliseconds: now.millisecond))
          : now;
      final startTime = base.add(Duration(hours: i));
      final endTime = startTime.add(const Duration(hours: 1));
      final windowStart = startTime.subtract(const Duration(hours: 1));
      final joinedPlayers = (i * 3) % 10;
      final maxPlayers = 10;
      return {
        'id': i,
        'title': 'Hourly Contest - ${startTime.hour.toString().padLeft(2, '0')}:00',
        'startTime': startTime,
        'endTime': endTime,
        'windowStart': windowStart,
        'listingTime': now.add(Duration(milliseconds: i)),
        'maxPlayers': maxPlayers,
        'joinedPlayers': joinedPlayers,
        'slotsLeft': maxPlayers - joinedPlayers,
        'prizePool': 1000000,
        'firstPrize': 500000,
        'thirdPrize': 100000,
        'price': 19 + (i % 5) * 10,
      };
    });
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:00';
  }

  String _countdownTo(DateTime startTime) {
    final now = DateTime.now();
    final diff = startTime.difference(now);
    if (diff.isNegative) return 'Started';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Live Match',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: contests.length,
              itemBuilder: (context, index) {
                final contest = contests[index];
                final contestId = contest['id'].toString();
                final isPaid = widget.paidContests.contains(contestId);
                final isSubmitted = widget.submittedContests.contains(contestId);
                return LiveContestCard(
                  title: contest['title'],
                  startTime: contest['startTime'],
                  endTime: contest['endTime'],
                  maxPlayers: contest['maxPlayers'],
                  joinedPlayers: contest['joinedPlayers'],
                  slotsLeft: contest['slotsLeft'],
                  prizePool: contest['prizePool'],
                  firstPrize: contest['firstPrize'],
                  thirdPrize: contest['thirdPrize'],
                  price: contest['price'],
                  onJoin: !isPaid && contest['slotsLeft'] > 0 ? () => widget.onJoinContest(contest) : null,
                  onResume: isPaid && !isSubmitted ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContestWaitingRoomScreen(
                          contestTitle: contest['title'],
                          startTime: contest['startTime'],
                          onSubmit: () {
                            widget.submittedContests.add(contestId);
                          },
                        ),
                      ),
                    );
                  } : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LiveContestCard extends StatefulWidget {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int maxPlayers;
  final int joinedPlayers;
  final int slotsLeft;
  final int prizePool;
  final int firstPrize;
  final int thirdPrize;
  final int price;
  final VoidCallback? onJoin;
  final VoidCallback? onResume;

  const LiveContestCard({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.maxPlayers,
    required this.joinedPlayers,
    required this.slotsLeft,
    required this.prizePool,
    required this.firstPrize,
    required this.thirdPrize,
    required this.price,
    this.onJoin,
    this.onResume,
  });

  @override
  State<LiveContestCard> createState() => _LiveContestCardState();
}

class _LiveContestCardState extends State<LiveContestCard> {
  late Timer _timer;
  late Duration _timeLeft;
  late bool _isLive;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      if (now.isBefore(widget.startTime)) {
        _isLive = false;
        _timeLeft = widget.startTime.difference(now);
      } else if (now.isAfter(widget.endTime)) {
        _isLive = false;
        _timeLeft = Duration.zero;
      } else {
        _isLive = true;
        _timeLeft = widget.endTime.difference(now);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    double percent;
    Color countdownColor;
    String timerText;
    final totalWindow = const Duration(hours: 24);
    if (!_isLive) {
      // Before contest starts
      final timeLeft = widget.startTime.difference(now);
      _timeLeft = timeLeft;
      percent = 1 - (timeLeft.inSeconds / totalWindow.inSeconds).clamp(0.0, 1.0);
      if (timeLeft > totalWindow) percent = 0.0;
      timerText = '${timeLeft.inHours.toString().padLeft(2, '0')}:${(timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}';
      if (timeLeft.inMinutes > 5) {
        countdownColor = Colors.greenAccent;
      } else if (timeLeft.inMinutes > 1) {
        countdownColor = Colors.orangeAccent;
      } else {
        countdownColor = Colors.redAccent;
      }
    } else {
      // Contest is live
      percent = 1.0;
      timerText = 'LIVE';
      countdownColor = Colors.redAccent;
    }

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Circular countdown
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation(countdownColor),
                    backgroundColor: Colors.grey[800],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerText,
                      style: TextStyle(
                        color: countdownColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        fontFamily: 'FiraMono',
                      ),
                    ),
                    if (_isLive)
                      const Icon(Icons.flash_on, color: Colors.redAccent, size: 18),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Contest details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.cyanAccent, size: 16),
                      const SizedBox(width: 4),
                      Text('Start: ${widget.startTime.hour.toString().padLeft(2, '0')}:${widget.startTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 12),
                      const Icon(Icons.people, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${widget.joinedPlayers}/${widget.maxPlayers}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text('Pool: Rs ${widget.prizePool}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Icon(Icons.attach_money, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 4),
                      Text('1st: Rs ${widget.firstPrize}', style: const TextStyle(color: Colors.cyanAccent)),
                      const SizedBox(width: 8),
                      Text('3rd: Rs ${widget.thirdPrize}', style: const TextStyle(color: Colors.lightBlueAccent)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Entry: Rs ${widget.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onJoin != null)
                        ElevatedButton.icon(
                          onPressed: widget.slotsLeft > 0 && !_isLive ? widget.onJoin : null,
                          icon: const Icon(Icons.play_arrow, color: Colors.black),
                          label: const Text('Join Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF00FF00).withOpacity(0.3),
                          ),
                        ),
                      const Spacer(),
                      if (widget.onResume != null)
                        ElevatedButton.icon(
                          onPressed: widget.onResume,
                          icon: const Icon(Icons.play_arrow, color: Colors.black),
                          label: const Text('Resume', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00FF00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF00FF00).withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeTab extends StatefulWidget {
  @override
  State<_PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<_PracticeTab> {
  String _selectedLanguage = 'Python';
  String _selectedLevel = 'Easy';
  String? _selectedQuestion;
  final Map<String, Map<String, List<String>>> _practiceData = {
    'Python': {
      'Easy': [
        'Print Hello World',
        'Sum of Two Numbers',
      ],
      'Intermediate': [
        'List Comprehensions',
        'Dictionary Manipulation',
      ],
      'Advanced': [
        'Decorators',
        'Generators',
      ],
      'Expert': [
        'Metaclasses',
        'Asyncio Advanced',
      ],
    },
    'JavaScript': {
      'Easy': [
        'Basic DOM Manipulation',
        'Array Methods',
      ],
      'Intermediate': [
        'Promises',
        'Fetch API',
      ],
      'Advanced': [
        'Closures',
        'Event Loop',
      ],
      'Expert': [
        'Web Workers',
        'Service Workers',
      ],
    },
    'Java': {
      'Easy': [
        'Hello World',
        'For Loop Practice',
      ],
      'Intermediate': [
        'Collections',
        'Exception Handling',
      ],
      'Advanced': [
        'Streams API',
        'Concurrency',
      ],
      'Expert': [
        'JVM Internals',
        'Custom ClassLoaders',
      ],
    },
    'C++': {
      'Easy': [
        'Input/Output Basics',
        'Simple Functions',
      ],
      'Intermediate': [
        'STL Vectors',
        'File Handling',
      ],
      'Advanced': [
        'Templates',
        'Smart Pointers',
      ],
      'Expert': [
        'Move Semantics',
        'Custom Allocators',
      ],
    },
  };

  final Map<String, String> _defaultCode = {
    'Python': 'print("Hello World")',
    'JavaScript': 'console.log("Hello World");',
    'Java': 'public class Main { public static void main(String[] args) { System.out.println("Hello World"); } }',
    'C++': '#include <iostream>\nint main() { std::cout << "Hello World" << std::endl; return 0; }',
  };

  String _userCode = '';
  String _output = '';
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _userCode = _defaultCode[_selectedLanguage]!;
  }

  void _onLanguageChanged(String lang) {
    setState(() {
      _selectedLanguage = lang;
      _selectedLevel = 'Easy';
      _selectedQuestion = null;
      _userCode = _defaultCode[lang]!;
      _output = '';
    });
  }

  void _onLevelChanged(String level) {
    setState(() {
      _selectedLevel = level;
      _selectedQuestion = null;
      _output = '';
    });
  }

  void _onQuestionSelected(String question) {
    setState(() {
      _selectedQuestion = question;
      _output = '';
    });
  }

  Future<void> _runCode() async {
    setState(() { _isRunning = true; _output = 'Running...'; });
    await Future.delayed(const Duration(seconds: 1)); // Simulate code run
    setState(() {
      _output = 'Output for: $_selectedQuestion\n(Your code ran successfully!)';
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PracticeContestScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            child: const Text('Practice Contests'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedLanguage,
                items: _practiceData.keys.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                onChanged: (val) => _onLanguageChanged(val!),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedLevel,
                items: _practiceData[_selectedLanguage]!.keys.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                onChanged: (val) => _onLevelChanged(val!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: _practiceData[_selectedLanguage]![_selectedLevel]!
                .map((q) => ChoiceChip(
                      label: Text(q),
                      selected: _selectedQuestion == q,
                      onSelected: (_) => _onQuestionSelected(q),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          if (_selectedQuestion != null) ...[
            Text('Question: $_selectedQuestion', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              maxLines: 10,
              minLines: 6,
              style: const TextStyle(fontFamily: 'FiraMono', color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Write your code here...',
                hintStyle: const TextStyle(color: Colors.white54),
              ),
              controller: TextEditingController(text: _userCode),
              onChanged: (val) => _userCode = val,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isRunning ? null : _runCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: _isRunning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Run'),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(_output, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }
} 