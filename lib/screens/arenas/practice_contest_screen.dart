import 'package:flutter/material.dart';

class PracticeContestScreen extends StatefulWidget {
  const PracticeContestScreen({super.key});

  @override
  State<PracticeContestScreen> createState() => _PracticeContestScreenState();
}

class _PracticeContestScreenState extends State<PracticeContestScreen> {
  final List<Map<String, dynamic>> practiceContests = List.generate(10, (i) => {
    'id': i,
    'title': 'Practice Contest #${i + 1}',
    'maxPlayers': 10 + i * 5,
    'joinedPlayers': i * 2,
    'prizePool': 1000 * (i + 1),
    'firstPrize': 500 * (i + 1),
    'thirdPrize': 100 * (i + 1),
  });

  void _joinPracticeContest(Map<String, dynamic> contest) {
    setState(() {
      contest['joinedPlayers'] = (contest['joinedPlayers'] as int) + 1;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(contest['title'])),
          body: Center(child: Text('Contest Experience Placeholder')), // Replace with real contest experience
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice Contests')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: practiceContests.length,
        itemBuilder: (context, index) {
          final contest = practiceContests[index];
          final slotsLeft = (contest['maxPlayers'] as int) - (contest['joinedPlayers'] as int);
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contest['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Max Participants: ${contest['maxPlayers']}', style: const TextStyle(color: Colors.white70)),
                  Text('Joined: ${contest['joinedPlayers']}'),
                  Text('Slots Left: $slotsLeft', style: const TextStyle(color: Colors.orangeAccent)),
                  Text('Prize Pool: Rs ${contest['prizePool']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  Text('1st Prize: Rs ${contest['firstPrize']}', style: const TextStyle(color: Colors.greenAccent)),
                  Text('3rd Prize: Rs ${contest['thirdPrize']}', style: const TextStyle(color: Colors.lightBlueAccent)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: slotsLeft > 0 ? () => _joinPracticeContest(contest) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: const Color(0xFF00FF00),
                      side: const BorderSide(color: Color(0xFF00FF00), width: 2),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Join Practice Contest'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 