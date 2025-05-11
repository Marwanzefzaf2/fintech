import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech/firebase_service.dart';
import 'package:fintech/Screens/Achievements/widget/achievement_card.dart';

class AchievementsList extends StatefulWidget {
  const AchievementsList({super.key});

  @override
  State<AchievementsList> createState() => _AchievementsListState();
}

class _AchievementsListState extends State<AchievementsList> {
  final FirebaseService _firebaseService = FirebaseService();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  late Future<List<Map<String, dynamic>>> _achievementsFuture;
  Map<String, bool> _claimedMap = {};
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _achievementsFuture = _fetchAchievementsAndClaims();
  }

  Future<List<Map<String, dynamic>>> _fetchAchievementsAndClaims() async {
    if (userId == null) return [];

    // Fetch claimed achievements
    final claimsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('achievements_claimed')
        .get();

    for (var doc in claimsSnapshot.docs) {
      _claimedMap[doc.id] = doc.data()['claimed'] == true;
    }

    // Fetch user data for condition parsing
    final userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    _userData = userSnapshot.data() ?? {};

    // Fetch master achievements
    final masterSnapshot =
    await FirebaseFirestore.instance.collection('achievements').get();

    return masterSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'],
        'description': data['description'],
        'iconCode': data['iconCode'] ?? 0xe87c,
        'colorCode': data['colorCode'] ?? 0xFFBDBDBD,
        'rewardCoins': data['rewardCoins'] ?? 0,
        'rewardPoints': data['rewardPoints'] ?? 0,
        'condition': data['condition'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _achievementsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final achievements = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: achievements.map((achievement) {
              final String id = achievement['id'];
              final String condition = achievement['condition'];
              final bool isClaimed = _claimedMap[id] == true;

              int currentValue = 0;
              int requiredValue = 0;
              String field = '';

              AchievementState state = AchievementState.locked;
              double progress = 0;

              final match = RegExp(r'(\w+)\s*>=\s*(\d+)').firstMatch(condition);
              if (match != null) {
                field = match.group(1)!;
                requiredValue = int.parse(match.group(2)!);
                currentValue = (_userData[field] ?? 0) as int;
                progress = currentValue / requiredValue;
                if (progress >= 1.0) {
                  state = isClaimed ? AchievementState.claimed : AchievementState.toClaim;
                }
              }

              return Column(
                children: [
                  AchievementCard(
                    achievementId: id,
                    title: achievement['title'],
                    description: achievement['description'],
                    condition: achievement['condition'] ?? "quizzes>=1", // ✅ fallback to default if missing
                    icon: IconData(achievement['iconCode'], fontFamily: 'MaterialIcons'),
                    color: Color(achievement['colorCode']),
                    rewardCoins: achievement['rewardCoins'],
                    rewardPoints: achievement['rewardPoints'],
                    initialState: state,
                  ),

                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
