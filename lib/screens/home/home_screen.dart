import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'package:genmon4/screens/home/pages/home_page.dart';
import 'package:genmon4/screens/home/pages/my_matches_page.dart';
import 'package:genmon4/screens/drawer/wallet_screen.dart';
import 'package:genmon4/screens/drawer/notifications_screen.dart';
import '../../widgets/user_info_panel.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';
import 'package:genmon4/screens/chat_box_screen.dart';
import 'package:genmon4/screens/games/games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const MyMatchesPage(),
    Builder(
      builder: (context) {
        final user = FirebaseAuth.instance.currentUser;
        return ChatBoxScreen(
          chatId: 'global',
          senderId: user?.uid ?? 'anonymous',
        );
      },
    ),
    const GamesScreen(),
    const Center(child: Text('GenMon PLAY')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserInfoPanel(),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('My Balance ₹49'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalletScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Cash'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Add Cash screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Chat screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Refer & Win'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Refer & Win screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Winners'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Winners screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('My Info & Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.gamepad),
              title: const Text('How to Play'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to How to Play screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Responsible Play'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Responsible Play screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('24x7 Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Help & Support screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.black),
            ),
          ),
        ),
        title: const Text("GenMon", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              );
            },
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFFFF1744)),
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.g_mobiledata), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports), label: 'My Matches'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat Box'),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'Games'),
          BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow_rounded), label: 'GenMon PLAY'),
        ],
      ),
    );
  }
} 