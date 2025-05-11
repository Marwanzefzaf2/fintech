import 'package:fintech/Screens/Store/Avatar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/progress_circle.dart';
import 'models/section_grid.dart';
import 'models/stat_row.dart';
import 'package:fintech/Screens/profile/profile.dart';
import 'package:fintech/Screens/Login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _userName;
  int _currentLevel = 1;
  double _levelProgress = 0.0;
  int _coins = 0;
  int _points = 0;
  String? _currentAvatarPath;
  bool _isLoading = true;
  bool _isDisposed = false;

  final avatarPaths = {
    'flower_girl': 'Assets/Images/avatar.png',
    'mystic_elf': 'Assets/Images/avatar1.png',
    'techie tina': 'Assets/Images/avatar2.png',
    'bun girl': 'Assets/Images/avatar3.png',
    'arcane master': 'Assets/Images/avatar4.png',
    'sunny boy': 'Assets/Images/avatar5.png',
    'cool boy': 'Assets/Images/avatar6.png',
    'beard bro': 'Assets/Images/avatar7.png',
    'sharp jack': 'Assets/Images/avatar8.png',
  };

  @override
  void initState() {
    super.initState();
    _loadAllUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadAllUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final data = doc.data();
        final avatarId = data?['avatarId'] ?? 'flower_girl';

        if (!mounted) return;
        setState(() {
          _userName = data?['username'] ?? 'User';
          _currentLevel = data?['level'] ?? 1;
          _levelProgress = (data?['xpProgress'] ?? 0.0).toDouble();
          _coins = data?['coins'] ?? 0;
          _points = data?['points'] ?? 0;
          _currentAvatarPath = avatarPaths[avatarId];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load user data'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _handleAvatarChanged(String avatarId) {
    if (!mounted) return;
    if (avatarPaths.containsKey(avatarId)) {
      setState(() {
        _currentAvatarPath = avatarPaths[avatarId];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 245, 228, 202),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 228, 202),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 228, 202),
        title: Text(
          "Welcome, $_userName!",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
              _currentAvatarPath != null
                  ? CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(_currentAvatarPath!),
                    backgroundColor: Colors.transparent,
                  )
                  : const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: userId),
              ),
            ).then((_) => _loadAllUserData());
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logout failed: ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                StatRow(userId: userId),
                const SizedBox(height: 30),
                ProgressCircle(
                  levelProgress: _levelProgress,
                  currentLevel: _currentLevel,
                ),
                const SizedBox(height: 30),
                SectionGrid(
                  onAvatarChanged: _handleAvatarChanged,
                  userId: userId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
