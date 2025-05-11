import 'package:fintech/Screens/Quiz/model/quiz_model.dart';
import 'package:fintech/Screens/Quiz/Constants/quiz_colors.dart';
import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onStartPressed;

  const QuizCard({required this.quiz, required this.onStartPressed, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuizColors.card,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [QuizColors.shadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(quiz.icon, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: QuizColors.courierText(18, FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: quiz.completedPercentage / 100,
                  backgroundColor: Colors.white,
                  color: Colors.purple,
                  minHeight: 10,
                ),
                const SizedBox(height: 5),
                Text(
                  "${quiz.correctAnswers}/${quiz.totalQuestions} correct • ${quiz.completedPercentage}%",
                  style: QuizColors.courierText(12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onStartPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: QuizColors.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: QuizColors.blackBorder,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'START',
              style: QuizColors.courierText(14, FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
