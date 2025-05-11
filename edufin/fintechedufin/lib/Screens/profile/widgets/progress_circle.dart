import 'package:flutter/material.dart';

class ProgressCircle extends StatelessWidget {
  final double progress;
  final int level;
  
  const ProgressCircle({
    super.key,
    required this.progress,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6C5CE7), // Purple accent color
                ),
              ),
            ),
            const CircleAvatar(
              radius: 50,
              //backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Level $level',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}