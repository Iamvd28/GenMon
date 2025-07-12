import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthStateProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthStateProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get currentUser => _user;

  bool get isAuthenticated => _user != null;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await _user?.updateDisplayName(displayName);
      await _user?.updatePhotoURL(photoURL);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await _user?.updateEmail(newEmail);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _user?.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _user?.delete();
    } catch (e) {
      rethrow;
    }
  }
} 