import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fintech/firebase_service.dart';

class LessonProgress {
  static const Map<String, int> _lessonRequirements = {
    'Blockchain Basics': 100, // 80 (lesson) + 20 (quiz)
    'Digital Payments': 100,
    'Crypto Investing': 100,
    'RegTech': 100,
    'AI in Finance': 100,
  };

  /// Marks a lesson as completed and updates XP, points, and achievements
  static Future<void> completeLesson({
    required String userId,
    required String lessonId,
    int rewardPoints = 50,
    double rewardXP = 0.25,
  }) async {
    await FirebaseService.markLessonCompleted(userId, lessonId);
    await FirebaseService.updateXP(userId, rewardXP);
    await FirebaseService.updatePoints(userId, rewardPoints);
    await FirebaseService.unlockAchievementsAfterLesson(userId, lessonId);
  }

  /// Checks if a lesson is unlocked based on previous lesson completion
  static Future<bool> isLessonUnlocked(String userId, String lessonTitle) async {
    if (lessonTitle == 'Blockchain Basics') return true;

    final previousLesson = _getPreviousLesson(lessonTitle);
    if (previousLesson == null) return true;

    final previousLessonId = _convertTitleToId(previousLesson);
    return await FirebaseService.isLessonCompleted(userId, previousLessonId);
  }

  static String? _getPreviousLesson(String currentLesson) {
    final lessons = _lessonRequirements.keys.toList();
    final currentIndex = lessons.indexOf(currentLesson);
    return currentIndex > 0 ? lessons[currentIndex - 1] : null;
  }

  static String _convertTitleToId(String title) {
    return title.toLowerCase().replaceAll(' ', '_');
  }
}
