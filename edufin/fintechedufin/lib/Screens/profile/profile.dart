import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech/Screens/Dashboard/models/stat_row.dart';
import 'package:fintech/Screens/profile/widgets/progress_circle.dart';
import 'package:fintech/Screens/profile/widgets/achievements_insights.dart';
import 'package:fintech/Screens/profile/widgets/lesson_quizes_stat_row.dart';
import 'package:fintech/Screens/Achievements/achievements.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  int _level = 1;
  double _xpProgress = 0.0;
  int _lessonsCompleted = 0;
  int _quizzesCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  Future<void> _loadUserProfileData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      final lessonsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('lessons_completed')
          .get();
      final quizzesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('quiz_attempts')
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _level = data?['level'] ?? 1;
          _xpProgress = (data?['xpProgress'] ?? 0.0).toDouble();
          _lessonsCompleted = lessonsSnapshot.docs.length;
          _quizzesCompleted = quizzesSnapshot.docs.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 245, 228, 202),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 228, 202),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProgressCircle(progress: _xpProgress, level: _level),
                      const SizedBox(height: 30),
                      _buildSectionHeader('Points & Coins'),
                      const SizedBox(height: 8),
                      StatRow(userId: widget.userId),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Learning Progress'),
                      const SizedBox(height: 8),
                      StatRow2(
                        lessonsCompleted: _lessonsCompleted,
                        quizzesCompleted: _quizzesCompleted,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Achievements'),
                      const SizedBox(height: 8),
                      AchievementsInsights(
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AchievementsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
