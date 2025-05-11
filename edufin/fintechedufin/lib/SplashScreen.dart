import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Screens/login/login_screen.dart';
import 'Screens/dashboard/dashboard.dart';
import 'Screens/admin/AdminPanelPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String adminEmail = 'admin@edufin.com';
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          navigateToNext();
        }
      });

    Timer(const Duration(seconds: 2), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateToNext() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase();

    if (user != null && email == adminEmail.toLowerCase()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelPage()),
      );
    } else if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 250, 217),
      body: Stack(
        children: [
          // Decorative Images
          Positioned(
            top: 40,
            left: 20,
            child: Image.asset('Assets/Images/fig(1).png', width: 50),
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: Image.asset('Assets/Images/fig.png', width: 70),
          ),
          Positioned(
            bottom: 20,
            right: 160,
            child: Image.asset('Assets/Images/fig.png', width: 90),
          ),
          Positioned(
            top: 200,
            right: 600,
            child: Image.asset('Assets/Images/fig(1).png', width: 1155),
          ),
          Positioned(
            bottom: 150,
            left: 50,
            child: Image.asset('Assets/Images/fig(1).png', width: 55),
          ),
          Positioned(
            top: 250,
            left: 50,
            child: Image.asset('Assets/Images/fig(3).png', width: 55),
          ),
          Positioned(
            top: 250,
            right: 50,
            child: Image.asset('Assets/Images/fig(1).png', width: 55),
          ),
          Positioned(
            top: 100,
            left: 100,
            child: Image.asset('Assets/Images/fig(1).png', width: 70),
          ),
          Positioned(
            top: 70,
            right: 100,
            child: Image.asset('Assets/Images/fig(3).png', width: 35),
          ),
          Positioned(
            top: 200,
            right: 170,
            child: Image.asset('Assets/Images/fig(2).png', width: 70),
          ),
          Positioned(
            bottom: 200,
            right: 100,
            child: Image.asset('Assets/Images/fig(2).png', width: 80),
          ),
          Positioned(
            bottom: 300,
            right: 190,
            child: Image.asset('Assets/Images/fig(3).png', width: 50),
          ),
          // Fading Logo/Text
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: const Text(
                'EduFin',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 233, 126, 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
