import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../firebase_service.dart';

/// Enum to represent specific signup result types or errors.
enum SignupResult {
  success,
  passwordMismatch,
  weakPassword,
  emailInUse,
  unknownError,
}

/// Handles the business logic for the User Sign Up process.
class SignupController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  /// Attempts to register a new user.
  Future<SignupResult> signup({
    required String username,
    required BuildContext context,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      return SignupResult.passwordMismatch;
    }

    if (password.length < 6) {
      return SignupResult.weakPassword;
    }

    try {
      // Register the user with Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the user's UID
      String uid = userCredential.user!.uid;

      // Save user data using FirebaseService
      await _firebaseService.createOrUpdateUser(
        userId: uid,
        username: username,
        email: email,
        coins: 0,
        points: 0,
        level: 1,
        xpProgress: 0.0,
        avatarId: 'flower_girl',
      );

      return SignupResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return SignupResult.emailInUse;
      } else if (e.code == 'weak-password') {
        return SignupResult.weakPassword;
      } else {
        return SignupResult.unknownError;
      }
    } catch (e) {
      return SignupResult.unknownError;
    }
  }
}
