// achievement_pill.dart
import 'package:flutter/material.dart';

class AchievementPill extends StatelessWidget {
  final String title;
  final Color color;
  final bool isLocked;

  const AchievementPill({
    super.key,
    required this.title,
    required this.color,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isLocked ? 0.2 : 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLocked ? Colors.grey : color,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocked ? Icons.lock_outline : Icons.star,
            size: 14,
            color: isLocked ? Colors.grey : color,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isLocked ? Colors.grey : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}