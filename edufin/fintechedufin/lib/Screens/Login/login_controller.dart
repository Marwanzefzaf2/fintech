import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech/Screens/Dashboard/dashboard.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> login(
      BuildContext context,
      String email,
      String password,
      ) async {
    try {
      // Basic input validation
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email and password cannot be empty')),
        );
        return false;
      }

      // Attempt login
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final user = _auth.currentUser;
      if (user == null) return false;

      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data() ?? {};

      final String username = data['username'] ?? 'User';
      final int coins = data['coins'] ?? 0;
      final int points = data['points'] ?? 0;
      final int level = data['level'] ?? 1;
      final double xpProgress = (data['xpProgress'] ?? 0.0).toDouble();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),

          ),
        );
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found' => 'No user found for this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-email' => 'Invalid email format.',
        _ => e.message ?? 'Login failed',
      };

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      return false;
    } catch (e) {
      print('Unexpected login error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unknown error occurred')),
        );
      }
      return false;
    }
  }
}
