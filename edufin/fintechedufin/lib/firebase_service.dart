import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────
  // 🔐 USER MANAGEMENT
  // ─────────────────────────────────────────────────────────────

  Future<void> createOrUpdateUser({
    required String userId,
    required String username,
    required String email,
    int coins = 0,
    int points = 0,
    int level = 1,
    double xpProgress = 0.0,
    String avatarId = 'flower_girl',
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.set({
      'username': username,
      'email': email,
      'coins': coins,
      'points': points,
      'level': level,
      'xpProgress': xpProgress,
      'avatarId': avatarId,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc.data() : null;
  }

  Future<void> updateUserField(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // ─────────────────────────────────────────────────────────────
  // 🧠 QUIZ PROGRESS
  // ─────────────────────────────────────────────────────────────

  Future<void> saveQuizProgress({
    required String userId,
    required String quizTitle,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final percentage = ((correctAnswers / totalQuestions) * 100).round();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('quizzes')
        .doc(quizTitle)
        .set({
      'correct': correctAnswers,
      'total': totalQuestions,
      'percentage': percentage,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getQuizProgress(String userId, String quizTitle) async {
    final doc = await _firestore.collection('users').doc(userId).collection('quizzes').doc(quizTitle).get();
    if (doc.exists) {
      return {
        'correct': doc.data()?['correct'] ?? 0,
        'percentage': doc.data()?['percentage'] ?? 0,
      };
    } else {
      return {
        'correct': 0,
        'percentage': 0,
      };
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 📘 LESSONS
  // ─────────────────────────────────────────────────────────────

  static Future<void> markLessonCompleted(String userId, String lessonId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lessons_completed')
        .doc(lessonId)
        .set({'completed': true});
  }

  static Future<bool> isLessonCompleted(String userId, String lessonId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lessons_completed')
        .doc(lessonId)
        .get();
    return doc.exists && doc.data()?['completed'] == true;
  }

  static Future<List<String>> getPurchasedLessons(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = doc.data();
    final List<dynamic> rawList = data?['purchased_lessons'] ?? [];
    return List<String>.from(rawList);
  }

  static Future<void> purchaseLesson(String userId, String lessonId, int price) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(userRef);
      final currentData = snap.data() ?? {};
      final currentCoins = currentData['coins'] ?? 0;
      if (currentCoins < price) throw Exception("Not enough coins");
      txn.update(userRef, {
        'coins': currentCoins - price,
        'purchased_lessons': FieldValue.arrayUnion([lessonId])
      });
    });
  }

  static Future<void> updateXP(String userId, double progressIncrement) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snap = await userRef.get();
    final data = snap.data() ?? {};
    double xp = (data['xpProgress'] ?? 0.0).toDouble();
    int level = (data['level'] ?? 1).toInt();
    xp += progressIncrement;
    if (xp >= 1.0) {
      xp = xp - 1.0;
      level += 1;
    }
    await userRef.update({
      'xpProgress': xp,
      'level': level,
    });
  }

  static Future<void> updatePoints(String userId, int pointsToAdd) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(userRef);
      final currentPoints = (snap.data()?['points'] ?? 0) as int;
      txn.update(userRef, {'points': currentPoints + pointsToAdd});
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 🏆 ACHIEVEMENTS
  // ─────────────────────────────────────────────────────────────

  static Future<void> unlockAchievement(String userId, String achievementId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .set({'unlocked': true}, SetOptions(merge: true));
  }

  static Future<void> markAchievementClaimed(String userId, String achievementId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .set({'claimed': true}, SetOptions(merge: true));
  }

  static Future<bool> isAchievementUnlocked(String userId, String achievementId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .get();
    return doc.exists && doc.data()?['unlocked'] == true;
  }

  static Future<bool> isAchievementClaimed(String userId, String achievementId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .get();
    return doc.exists && doc.data()?['claimed'] == true;
  }

  static Future<void> unlockAchievementsAfterLesson(String userId, String lessonId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final completedLessons = (doc.data()?['purchased_lessons'] ?? []).length;

    if (completedLessons >= 1) {
      await unlockAchievement(userId, 'lesson_learner');
    }
    if (completedLessons >= 3) {
      await unlockAchievement(userId, 'lesson_pro');
    }
    if (completedLessons >= 5) {
      await unlockAchievement(userId, 'lesson_master');
    }
  }
  static Future<void> updateCoins(String userId, int coinsToAdd) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(userRef);
      final currentCoins = (snap.data()?['coins'] ?? 0) as int;
      txn.update(userRef, {'coins': currentCoins + coinsToAdd});
    });
  }


}
