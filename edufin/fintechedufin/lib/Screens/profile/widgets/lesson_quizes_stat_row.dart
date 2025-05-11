import 'package:flutter/material.dart';
import 'package:fintech/Screens/Dashboard/widgets/retroBox.dart';

class StatRow2 extends StatelessWidget {
  final int lessonsCompleted;
  final int quizzesCompleted;
  
  const StatRow2({
    super.key,
    required this.lessonsCompleted,
    required this.quizzesCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: RetroStatBox(
              title: "Lessons:",
              value: lessonsCompleted.toString(),
              imagePath: 'Assets/Images/avatar8.png', // Changed to book icon
              backgroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: RetroStatBox(
              title: "Quizzes:",
              value: quizzesCompleted.toString(),
              imagePath: 'Assets/Images/quizzes.png', // Changed to quiz icon
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}