import 'package:shared_preferences/shared_preferences.dart';

class QuizPreferences {
  static Future<int> getCoins(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_${userId}_coins') ?? 0;
  }

  static Future<void> saveCoins(String userId, int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_${userId}_coins', coins);
  }

  static Future<void> saveQuizProgress(
    String userId,
    String quizTitle,
    int correctAnswers,
    int totalQuestions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final percentage = ((correctAnswers / totalQuestions) * 100).round();
    await prefs.setInt('user_${userId}_${quizTitle}_progress', percentage);
    await prefs.setInt('user_${userId}_${quizTitle}_correct', correctAnswers);
  }

  static Future<Map<String, int>> getQuizProgress(
    String userId,
    String quizTitle,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'percentage': prefs.getInt('user_${userId}_${quizTitle}_progress') ?? 0,
      'correct': prefs.getInt('user_${userId}_${quizTitle}_correct') ?? 0,
    };
  }
}

class Preferences {
  // Constants for keys
  static String _purchasedLessonsKey(String userId) =>
      'user_${userId}_purchased_lessons';
  static String _coinsKey(String userId) => 'user_${userId}_coins';

  static Future<void> savePurchasedLesson(
    String userId,
    String lessonId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'purchased_lessons_$userId';
    final current = prefs.getStringList(key) ?? [];
    if (!current.contains(lessonId)) {
      current.add(lessonId);
      await prefs.setStringList(key, current);
    }
  }

  static Future<List<String>> getPurchasedLessons(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'purchased_lessons_$userId';
    return prefs.getStringList(key) ?? [];
  }

  static Future<void> removePurchasedLesson(
    String userId,
    String lessonId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final purchased = await getPurchasedLessons(userId);
    purchased.remove(lessonId);
    await prefs.setStringList(_purchasedLessonsKey(userId), purchased);
  }

  static Future<void> saveCoins(String userId, int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey(userId), coins);
  }

  static Future<int> getCoins(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey(userId)) ?? 0;
  }

  // Optional: Clear all user data (for testing/logout)
  static Future<void> clearUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_purchasedLessonsKey(userId));
    await prefs.remove(_coinsKey(userId));
    // Add any other user-specific keys here
  }
}
