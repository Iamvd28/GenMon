import 'package:flutter/material.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class QuizArenaScreen extends StatelessWidget {
  const QuizArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFF9B30FF)),
          DefaultTabController(
            length: 4,
            child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: const Text('Quiz Arena'),
                backgroundColor: Colors.redAccent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.science),
                      text: 'Science',
                    ),
                    Tab(
                      icon: Icon(Icons.calculate),
                      text: 'Math',
                    ),
                    Tab(
                      icon: Icon(Icons.history_edu),
                      text: 'History',
                    ),
                    Tab(
                      icon: Icon(Icons.sports_esports),
                      text: 'Gaming',
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildQuizScreen('Science'),
                  _buildQuizScreen('Math'),
                  _buildQuizScreen('History'),
                  _buildQuizScreen('Gaming'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen(String category) {
    final Map<String, List<Map<String, dynamic>>> quizzesByCategory = {
      'Science': [
        {'name': 'Physics Quiz', 'questions': 20, 'time': '30 min'},
        {'name': 'Chemistry Challenge', 'questions': 25, 'time': '35 min'},
        {'name': 'Biology Test', 'questions': 30, 'time': '40 min'},
      ],
      'Math': [
        {'name': 'Algebra Quiz', 'questions': 15, 'time': '25 min'},
        {'name': 'Geometry Challenge', 'questions': 20, 'time': '30 min'},
        {'name': 'Calculus Test', 'questions': 25, 'time': '35 min'},
      ],
      'History': [
        {'name': 'Ancient History', 'questions': 25, 'time': '35 min'},
        {'name': 'World Wars Quiz', 'questions': 30, 'time': '40 min'},
        {'name': 'Modern History', 'questions': 20, 'time': '30 min'},
      ],
      'Gaming': [
        {'name': 'Gaming Trivia', 'questions': 20, 'time': '25 min'},
        {'name': 'ESports Quiz', 'questions': 25, 'time': '30 min'},
        {'name': 'Gaming History', 'questions': 15, 'time': '20 min'},
      ],
    };

    return Container(
      color: Colors.black,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzesByCategory[category]!.length,
        itemBuilder: (context, index) {
          final quiz = quizzesByCategory[category]![index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                quiz['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${quiz['questions']} questions • ${quiz['time']}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle quiz selection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start Quiz'),
              ),
            ),
          );
        },
      ),
    );
  }
} 