import 'package:flutter/material.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFFFF1744)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: 'Back',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildNotificationItem(
                        context,
                        icon: FontAwesomeIcons.plus,
                        color: Colors.green,
                        title: 'Money Added',
                        subtitle: '₹500 has been added to your wallet.',
                        date: 'Just now',
                      ),
                      _buildNotificationItem(
                        context,
                        icon: FontAwesomeIcons.arrowRight,
                        color: Colors.red,
                        title: 'Money Withdrawn',
                        subtitle: '₹200 has been withdrawn from your wallet.',
                        date: '5 min ago',
                      ),
                      _buildNotificationItem(
                        context,
                        icon: FontAwesomeIcons.trophy,
                        color: Colors.blue,
                        title: 'Match Joined',
                        subtitle: 'You have joined the Cricket Match.',
                        date: '10 min ago',
                      ),
                      _buildNotificationItem(
                        context,
                        icon: FontAwesomeIcons.clock,
                        color: Colors.orange,
                        title: 'Match Starting Soon',
                        subtitle: 'Football Match will start in 15 minutes.',
                        date: '30 min ago',
                      ),
                      _buildNotificationItem(
                        context,
                        icon: FontAwesomeIcons.gift,
                        color: Colors.purple,
                        title: 'Reward Received',
                        subtitle: 'You received a bonus for daily login.',
                        date: 'Today',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 