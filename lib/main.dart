import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:genmon4/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart' show AuthStateProvider;
import 'providers/contest_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/merchandise_page.dart';
import 'widgets/animated_blocks_background.dart';
import 'package:genmon4/screens/arenas/contest_waiting_room_screen.dart';
import 'package:genmon4/screens/arenas/contest_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? firebaseError;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Firebase already initialized or failed: $e');
    firebaseError = e;
  }
  print('main(): About to runApp');
  if (firebaseError != null) {
    runApp(ErrorApp(firebaseError));
  } else {
    runApp(const MyApp());
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  const ErrorApp(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize Firebase: $error',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthStateProvider()),
        ChangeNotifierProvider(create: (_) => ContestProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'GenMon',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: GoogleFonts.notoSansTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/wallet': (context) => const WalletScreen(),
              '/merchandise': (context) => MerchandisePage(),
            },
          );
        },
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchUserMatches(String userId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('matches')
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
} 