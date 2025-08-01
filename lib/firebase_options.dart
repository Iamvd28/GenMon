// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// IMPORTANT: To fix the Firebase configuration error:
/// 1. Go to Firebase Console (https://console.firebase.google.com/)
/// 2. Create a new project or select an existing one
/// 3. Add a web app to your project
/// 4. Copy the configuration from Firebase Console
/// 5. Replace the placeholder values below with your actual configuration
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyDX9jqaXTWWVCDCprEbCSEU_scYU08ur9o",
        authDomain: "genmon2-fb7ef.firebaseapp.com",
        projectId: "genmon2-fb7ef",
        storageBucket: "genmon2-fb7ef.appspot.com",
        messagingSenderId: "341726559399",
        appId: "1:341726559399:web:c6689a850a8a0da6346f82",
      );
    }
    // Android-specific configuration
    return const FirebaseOptions(
      apiKey: "AIzaSyDX9jqaXTWWVCDCprEbCSEU_scYU08ur9o",
      appId: "1:341726559399:android:3fc5edeba820331e346f82",
      messagingSenderId: "341726559399",
      projectId: "genmon2-fb7ef",
      storageBucket: "genmon2-fb7ef.appspot.com",
    );
  }
} 