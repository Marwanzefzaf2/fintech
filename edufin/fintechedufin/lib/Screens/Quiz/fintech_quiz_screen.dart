import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech/firebase_service.dart';
import 'package:fintech/Screens/Quiz/Constants/quiz_colors.dart';
import '../../firebase_service.dart';
import 'quiz_list_screen.dart';

class FintechQuizScreen extends StatefulWidget {
  final String quizTitle;
  final int totalQuestions;
  final List<Map<String, dynamic>> questions;
  final String userId;

  const FintechQuizScreen({
    Key? key,
    required this.quizTitle,
    required this.totalQuestions,
    required this.questions,
    required this.userId,
  }) : super(key: key);

  @override
  State<FintechQuizScreen> createState() => _FintechQuizScreenState();
}

class _FintechQuizScreenState extends State<FintechQuizScreen> {
  late final List<Map<String, dynamic>> _questions;
  int _currentQuestion = 0;
  String? _selectedOption;
  bool _answered = false;
  int _correctAnswers = 0;
  int _earnedCoins = 0;
  bool _hintUsed = false;
  int _userPoints = 0;
  bool _isLoading = true;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _questions = widget.questions;
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    final userData = await _firebaseService.getUserData(widget.userId);
    _userPoints = userData?['points'] ?? 0;

    final attemptsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('quiz_attempts')
        .doc(widget.quizTitle);

    final attemptSnapshot = await attemptsRef.get();
    int attempts = 0;
    if (attemptSnapshot.exists) {
      attempts = attemptSnapshot.data()?['attempts'] ?? 0;
    }

    if (attempts >= 1) {
      if (_userPoints < 20) {
        _showNotEnoughPointsForRetake();
        return;
      } else {
        _userPoints -= 20;
        await FirebaseService.updatePoints(widget.userId, -20);
      }
    }

    await attemptsRef.set({'attempts': attempts + 1});
    setState(() {
      _isLoading = false;
    });
  }

  void _showNotEnoughPointsForRetake() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Not enough points"),
        content: const Text("You need 20 points to retake this quiz."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizListScreen(userId: widget.userId),
                ),
              );
            },
            child: const Text("Back"),
          )
        ],
      ),
    );
  }

  void _selectOption(String option) async {
    if (_answered) return;

    setState(() {
      _selectedOption = option;
      _answered = true;
    });

    if (option == _questions[_currentQuestion]['answer']) {
      setState(() {
        _correctAnswers++;
        _earnedCoins += 3;
      });

      await FirebaseService.updateXP(widget.userId, 0.10);
      await FirebaseService.updatePoints(widget.userId, 5);
    }
  }

  Future<void> _useHint() async {
    if (_hintUsed || _userPoints < 10 || _answered) return;

    setState(() {
      _hintUsed = true;
      _userPoints -= 10;
    });

    await FirebaseService.updatePoints(widget.userId, -10);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Hint: Correct answer is \"${_questions[_currentQuestion]['answer']}\"",
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _skipQuestion() async {
    if (_userPoints < 15 || _answered) return;

    setState(() {
      _userPoints -= 15;
      _currentQuestion++;
      _selectedOption = null;
      _answered = false;
      _hintUsed = false;
    });

    await FirebaseService.updatePoints(widget.userId, -15);
  }

  Future<void> _retryQuestion() async {
    if (_userPoints < 10 || !_answered) return;

    setState(() {
      _userPoints -= 10;
      _selectedOption = null;
      _answered = false;
      _hintUsed = false;
    });

    await FirebaseService.updatePoints(widget.userId, -10);
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestion++;
      _selectedOption = null;
      _answered = false;
      _hintUsed = false;
    });
  }

  Future<void> _saveAndReturn() async {
    await _firebaseService.saveQuizProgress(
      userId: widget.userId,
      quizTitle: widget.quizTitle,
      correctAnswers: _correctAnswers,
      totalQuestions: widget.totalQuestions,
    );

    await FirebaseService.updateCoins(widget.userId, _earnedCoins);

    if (_correctAnswers >= 1) {
      await FirebaseService.unlockAchievement(widget.userId, 'quiz_beginner');
    }
    if (_correctAnswers >= 3) {
      await FirebaseService.unlockAchievement(widget.userId, 'quiz_pro');
    }
    if (_correctAnswers == widget.totalQuestions) {
      await FirebaseService.unlockAchievement(widget.userId, 'quiz_perfect');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => QuizListScreen(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentQuestion >= _questions.length) {
      return _buildResultsScreen();
    }
    return _buildQuizScreen();
  }

  Widget _buildResultsScreen() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.quizTitle, style: QuizColors.courierText(20, FontWeight.bold)),
        backgroundColor: QuizColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: QuizColors.background,
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [QuizColors.thickShadow],
                ),
                child: Column(
                  children: [
                    Text('🎉 Quiz Completed!', style: QuizColors.courierText(26, FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text('Score: $_correctAnswers/${_questions.length}', style: QuizColors.courierText(22)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on, size: 28),
                        const SizedBox(width: 8),
                        Text('$_earnedCoins coins earned!', style: QuizColors.courierText(20, FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveAndReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuizColors.button,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: QuizColors.thickBlackBorder,
                        ),
                      ),
                      child: Text('BACK TO QUIZZES', style: QuizColors.courierText(16, FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final current = _questions[_currentQuestion];
    return Scaffold(
      backgroundColor: QuizColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.quizTitle, style: QuizColors.courierText(20, FontWeight.bold)),
        backgroundColor: QuizColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, size: 25),
                const SizedBox(width: 5),
                Text('$_earnedCoins', style: QuizColors.courierText(16, FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: QuizColors.card,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [QuizColors.thickShadow],
          ),
          child: Column(
            children: [
              Text(
                'Question ${_currentQuestion + 1}/${_questions.length}',
                style: QuizColors.courierText(16, FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      current['question'],
                      textAlign: TextAlign.center,
                      style: QuizColors.courierText(20, FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    ...current['options'].map<Widget>((option) {
                      final isCorrect = option == current['answer'];
                      final isSelected = _selectedOption == option;
                      Color bgColor = QuizColors.background;

                      if (_answered) {
                        if (isSelected) {
                          bgColor = isCorrect ? QuizColors.correctAnswer : QuizColors.wrongAnswer;
                        } else if (isCorrect) {
                          bgColor = QuizColors.correctAnswer;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap: () => _selectOption(option),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(option, style: QuizColors.courierText(16, FontWeight.bold)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    if (!_answered && !_hintUsed)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton.icon(
                          onPressed: _userPoints >= 10 ? _useHint : null,
                          icon: const Icon(Icons.lightbulb),
                          label: const Text('Use Hint (-10 pts)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade200,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 2),
                            textStyle: const TextStyle(
                              fontFamily: 'Courier New',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (!_answered)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: _userPoints >= 15 ? _skipQuestion : null,
                          icon: const Icon(Icons.fast_forward),
                          label: const Text('Skip Question (-15 pts)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade200,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 2),
                            textStyle: const TextStyle(
                              fontFamily: 'Courier New',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (_answered)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: _userPoints >= 10 ? _retryQuestion : null,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Question (-10 pts)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade200,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 2),
                            textStyle: const TextStyle(
                              fontFamily: 'Courier New',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_answered)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QuizColors.button,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: QuizColors.thickBlackBorder,
                      ),
                    ),
                    child: Text(
                      _currentQuestion == _questions.length - 1 ? 'FINISH' : 'NEXT',
                      style: QuizColors.courierText(16, FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
