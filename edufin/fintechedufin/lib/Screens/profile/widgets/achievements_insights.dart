// achievements_insights.dart
import 'package:flutter/material.dart';
import 'achievement_pill.dart';

class AchievementsInsights extends StatelessWidget {
  final VoidCallback onViewAll;

  const AchievementsInsights({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              AchievementPill(
                title: "Fast Learner",
                color: Colors.orange,
              ),
              AchievementPill(
                title: "Quiz Master",
                color: Colors.purple,
              ),
              AchievementPill(
                title: "5-Day Streak",
                color: Colors.red,
                isLocked: true,
              ),
              AchievementPill(
                title: "Bookworm",
                color: Colors.green,
              ),
              AchievementPill(
                title: "Early Bird",
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}