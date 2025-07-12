import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dart:async';

class LeaderboardScreen extends StatefulWidget {
  final String? currentUser;
  const LeaderboardScreen({super.key, this.currentUser});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedLeaderboard = 'overall';
  final ApiService _apiService = ApiService();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    print('LeaderboardScreen: initState called');
    fetchLeaderboard();
    
    // Set up real-time refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        fetchLeaderboard();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchLeaderboard() async {
    print('LeaderboardScreen: fetchLeaderboard called');
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('LeaderboardScreen: Making API call...');
      Map<String, dynamic> data;
      
      if (selectedLeaderboard == 'overall') {
        data = await _apiService.getOverallLeaderboard();
      } else if (selectedLeaderboard == 'category') {
        data = await _apiService.getCategoryLeaderboard('algorithms');
      } else {
        data = await _apiService.getOverallLeaderboard();
      }

      print('LeaderboardScreen: API response received: $data');

      if (mounted) {
        setState(() {
          leaderboardData = List<Map<String, dynamic>>.from(data['entries'] ?? []);
          isLoading = false;
        });
      }
      
      print('LeaderboardScreen: Data loaded, entries: ${leaderboardData.length}');
    } catch (e) {
      print('LeaderboardScreen: Error occurred: $e');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('LeaderboardScreen: build called, isLoading: $isLoading, errorMessage: $errorMessage, dataLength: ${leaderboardData.length}');
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '🏆 LIVE LEADERBOARD',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'FiraMono',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Real-time indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF00).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00FF00)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF00),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FiraMono',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and refresh section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                bottom: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Filter dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00FF00)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLeaderboard,
                        dropdownColor: Colors.black,
                        style: const TextStyle(
                          color: Color(0xFF00FF00),
                          fontFamily: 'FiraMono',
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedLeaderboard = value;
                            });
                            fetchLeaderboard();
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'overall',
                            child: Text('Overall Rankings'),
                          ),
                          DropdownMenuItem(
                            value: 'category',
                            child: Text('By Category'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Refresh button
                ElevatedButton.icon(
                  onPressed: fetchLeaderboard,
                  icon: const Icon(Icons.refresh, color: Color(0xFF00FF00)),
                  label: const Text('Refresh', style: TextStyle(color: Color(0xFF00FF00))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Color(0xFF00FF00)),
                  ),
                ),
              ],
            ),
          ),
          
          // Debug info (temporary)
          if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red.withOpacity(0.2),
              child: Text(
                'Debug: $errorMessage',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          
          // Leaderboard content
          Expanded(
            child: _buildLeaderboardContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00FF00)),
            SizedBox(height: 16),
            Text(
              'Loading Live Leaderboard...',
              style: TextStyle(
                color: Color(0xFF00FF00),
                fontFamily: 'FiraMono',
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fetching real-time data...',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'FiraMono',
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'FiraMono',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'FiraMono',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchLeaderboard,
              child: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF00),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (leaderboardData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              color: Colors.grey,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No Leaderboard Data',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'FiraMono',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Participate in contests to see your ranking!',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'FiraMono',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboardData.length,
      itemBuilder: (context, index) {
        final data = leaderboardData[index];
        final isUser = widget.currentUser != null && data['username'] == widget.currentUser;
        final isTop3 = index < 3;
        
        Icon? medal;
        if (index == 0) {
          medal = const Icon(Icons.emoji_events, color: Colors.amber, size: 32);
        } else if (index == 1) {
          medal = const Icon(Icons.emoji_events, color: Colors.grey, size: 28);
        } else if (index == 2) {
          medal = const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 24);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isUser 
                  ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                  : isTop3 
                      ? [Colors.amber.withOpacity(0.1), Colors.amber.withOpacity(0.05)]
                      : [Colors.grey[900]!, Colors.grey[850]!],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: index == 0 
                  ? Colors.amber 
                  : isUser 
                      ? const Color(0xFF00FF00)
                      : isTop3 
                          ? Colors.cyanAccent 
                          : Colors.white24,
              width: 2,
            ),
            boxShadow: [
              if (isUser)
                BoxShadow(
                  color: const Color(0xFF00FF00).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: index == 0 
                        ? Colors.amber 
                        : isUser 
                            ? const Color(0xFF00FF00)
                            : isTop3 
                                ? Colors.cyanAccent 
                                : Colors.cyanAccent.withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (index == 0 
                            ? Colors.amber 
                            : isUser 
                                ? const Color(0xFF00FF00)
                                : isTop3 
                                    ? Colors.cyanAccent 
                                    : Colors.cyanAccent.withOpacity(0.5)).withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${data['rank'] ?? index + 1}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'FiraMono'
                      ),
                    ),
                  ),
                ),
                if (medal != null) 
                  Positioned(right: -8, top: -8, child: medal),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    data['username'] ?? 'Unknown User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'FiraMono',
                      shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 8)],
                    ),
                  ),
                ),
                if (isUser) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'FiraMono',
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: Text(
                          'Score: ${data['compositeScore']?.toStringAsFixed(1) ?? data['totalScore']?.toStringAsFixed(1) ?? 'N/A'}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'FiraMono',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (data['accuracy'] != null)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.5)),
                          ),
                          child: Text(
                            'Accuracy: ${(data['accuracy'] * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontFamily: 'FiraMono',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (data['contestsParticipated'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Contests: ${data['contestsParticipated']}',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontFamily: 'FiraMono',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
} 