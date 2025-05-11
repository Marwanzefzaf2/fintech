import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech/Screens/Dashboard/dashboard.dart';
import 'package:fintech/Screens/Quiz/model/quiz_model.dart';
import 'package:fintech/Screens/Quiz/widget/quiz_card.dart';
import 'package:fintech/firebase_service.dart';
import 'package:flutter/material.dart';
import 'Constants/quiz_colors.dart';
import 'fintech_quiz_screen.dart';

class QuizListScreen extends StatefulWidget {
  final String userId;
  final String? autoStartQuizId;

  const QuizListScreen({
    Key? key,
    this.autoStartQuizId,
    required this.userId,
  }) : super(key: key);

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<QuizModel> quizzes = [];
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadQuizzes().then((_) {
      if (widget.autoStartQuizId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startQuizById(widget.autoStartQuizId!);
        });
      }
    });
  }

  Future<void> _loadQuizzes() async {
    final snapshot = await FirebaseFirestore.instance.collection('quizzes').get();
    final userData = await _firebaseService.getUserData(widget.userId);
    _userPoints = userData?['points'] ?? 0;

    final loadedQuizzes = <QuizModel>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lessonId = doc.id;
      final displayTitle = _formatQuizTitle(lessonId);
      final iconName = data['icon'] ?? 'school';
      final questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
      final iconData = _getIconFromName(iconName);
      final requiredPoints = data['requiredPoints'] ?? 0;

      final progress = await _firebaseService.getQuizProgress(widget.userId, displayTitle);

      loadedQuizzes.add(QuizModel(
        title: displayTitle,
        icon: iconData,
        totalQuestions: questions.length,
        completedPercentage: progress['percentage'] ?? 0,
        correctAnswers: progress['correct'] ?? 0,
        requiredPoints: requiredPoints,
      ));
    }

    setState(() {
      quizzes = loadedQuizzes;
      _isLoading = false;
    });
  }

  String _formatQuizTitle(String id) {
    return id
        .replaceAll('lesson_', '')
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'money':
        return Icons.attach_money;
      case 'lock':
        return Icons.lock;
      case 'credit_card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'school':
      default:
        return Icons.school;
    }
  }

  void _startQuizById(String quizId) {
    final formattedTitle = _formatQuizTitle(quizId);
    final quiz = quizzes.firstWhere(
          (q) => q.title == formattedTitle,
      orElse: () => quizzes.first,
    );
    _startQuiz(quiz);
  }

  Future<void> _startQuiz(QuizModel quiz) async {
    if (_userPoints < quiz.requiredPoints) {
      _showInsufficientPointsDialog(quiz.requiredPoints);
      return;
    }

    final query = await FirebaseFirestore.instance.collection('quizzes').get();
    final doc = query.docs.firstWhere(
          (doc) => _formatQuizTitle(doc.id) == quiz.title,
      orElse: () => throw Exception("Quiz not found"),
    );

    final data = doc.data();
    final questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FintechQuizScreen(
          userId: widget.userId,
          quizTitle: quiz.title,
          totalQuestions: questions.length,
          questions: questions,
        ),
      ),
    );
  }

  void _showInsufficientPointsDialog(int requiredPoints) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Not enough points"),
        content: Text("You need $requiredPoints points to attempt this quiz."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuizColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          },
        ),
        title: Text(
          'FinTech Quizzes',
          style: QuizColors.courierText(28, FontWeight.bold),
        ),
        backgroundColor: QuizColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Test your financial knowledge:",
              style: QuizColors.courierText(18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return QuizCard(
                    quiz: quiz,
                    onStartPressed: () => _startQuiz(quiz),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
