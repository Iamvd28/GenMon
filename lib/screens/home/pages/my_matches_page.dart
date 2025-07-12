import 'package:flutter/material.dart';
import 'package:genmon4/models/match.dart';
import 'package:genmon4/services/match_service.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:genmon4/screens/arenas/contest_waiting_room_screen.dart';
import 'package:genmon4/screens/arenas/contest_page.dart';

class MyMatchesPage extends StatefulWidget {
  const MyMatchesPage({super.key});

  @override
  State<MyMatchesPage> createState() => _MyMatchesPageState();
}

class _MyMatchesPageState extends State<MyMatchesPage> {
  List<Match> matches = [];
  String userId = "HluqKfSyt734wPozzG3W";

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    matches = await MatchService().fetchUserMatches(userId);
    print('Fetched matches: ${matches.map((m) => '${m.name} (${m.status})').toList()}');
    setState(() {});
  }

  Future<void> joinContest(Match match) async {
    await MatchService().joinContest(userId: userId, match: match);
    await fetchMatches();
  }

  Future<void> updateMatchStatus(String matchId, String status) async {
    await MatchService().updateMatchStatus(userId: userId, matchId: matchId, status: status);
    await fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = matches.where((m) => m.status == 'upcoming').toList();
    final live = matches.where((m) => m.status == 'live').toList();
    final completed = matches.where((m) => m.status == 'completed').toList();

    return Stack(
      children: [
        const AnimatedBlocksBackground(neonColor: Color(0xFF9B30FF)),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: const [
                  CircleAvatar(radius: 22, backgroundColor: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'My Matches',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SafeArea(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          tabs: const [
                            Tab(text: 'Upcoming'),
                            Tab(text: 'Live'),
                            Tab(text: 'Completed'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildMatchList(upcoming, 'Prepare', (match) => joinContest(match)),
                            _buildMatchList(live, 'Play', (match) => updateMatchStatus(match.id, 'completed')),
                            _buildMatchList(completed, 'Completed', null),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Floating action button to add a test match
        // Positioned(
        //   bottom: 24,
        //   right: 24,
        //   child: FloatingActionButton(
        //     backgroundColor: Colors.deepPurple,
        //     child: const Icon(Icons.add),
        //     onPressed: () async {
        //       final now = DateTime.now();
        //       final match = Match(
        //         id: 'test_  ${now.millisecondsSinceEpoch}',
        //         name: 'Test Contest',
        //         type: 'code',
        //         category: 'Python',
        //         startTime: now.add(const Duration(minutes: 10)),
        //         endTime: now.add(const Duration(hours: 2)),
        //         status: 'upcoming',
        //         score: null,
        //       );
        //       await MatchService().joinContest(userId: userId, match: match);
        //       await fetchMatches();
        //     },
        //     tooltip: 'Add Test Match',
        //   ),
        // ),
      ],
    );
  }

  Widget _buildMatchList(List<Match> matches, String buttonText, Function(Match)? onPressed) {
    if (matches.isEmpty) {
      return const Center(
        child: Text(
          'No matches found',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Text(
              match.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '${match.type.toUpperCase()} - ${match.category}',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 8),
                if (match.status != 'completed')
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to waiting room or contest page based on status
                      if (match.status == 'upcoming') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContestWaitingRoomScreen(
                              contestTitle: match.name,
                              startTime: match.startTime,
                            ),
                          ),
                        );
                      } else if (match.status == 'live') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContestPage(
                              contestTitle: match.name,
                              startTime: match.startTime,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00FF00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                Text(
                  _getMatchTimeText(match),
                  style: TextStyle(
                    color: _getStatusColor(match.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (match.status == 'completed' && match.score != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Score:  ${match.score}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            trailing: _buildMatchActionButton(match, buttonText, onPressed),
          ),
        );
      },
    );
  }

  String _getMatchTimeText(Match match) {
    switch (match.status) {
      case 'upcoming':
        final difference = match.startTime.difference(DateTime.now());
        if (difference.inHours > 24) {
          return 'Starts in  ${difference.inDays} days';
        } else if (difference.inHours > 1) {
          return 'Starts in  ${difference.inHours} hours';
        } else {
          return 'Starts in  ${difference.inMinutes} minutes';
        }
      case 'live':
        final duration = DateTime.now().difference(match.startTime);
        return 'Started  ${duration.inMinutes} minutes ago';
      case 'completed':
        return 'Completed  ${match.endTime?.difference(match.startTime).inMinutes ?? 0} minutes';
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.orangeAccent;
      case 'live':
        return Colors.greenAccent;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.white70;
    }
  }

  Widget _buildMatchActionButton(Match match, String buttonText, Function(Match)? onPressed) {
    if (onPressed != null && match.status != 'completed') {
      Color color = match.status == 'upcoming'
          ? Colors.redAccent
          : match.status == 'live'
              ? Colors.green
              : Colors.grey;
      return ElevatedButton(
        onPressed: () => onPressed(match),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        child: Text(buttonText),
      );
    } else if (match.status == 'completed') {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        child: const Text('Completed'),
      );
    }
    return const SizedBox.shrink();
  }
} 