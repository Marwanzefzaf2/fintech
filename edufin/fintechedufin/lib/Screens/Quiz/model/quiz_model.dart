import 'package:flutter/material.dart';

class QuizModel {
  final String title;
  final int totalQuestions;
  int completedPercentage;
  final IconData icon;
  int correctAnswers;

  // 👇 NEW FIELD
  final int requiredPoints;

  QuizModel({
    required this.title,
    required this.totalQuestions,
    required this.completedPercentage,
    required this.icon,
    this.correctAnswers = 0,
    this.requiredPoints = 0, // 👈 Default to 0 if not provided
  });

  QuizModel copyWith({
    String? title,
    int? totalQuestions,
    int? completedPercentage,
    IconData? icon,
    int? correctAnswers,
    int? requiredPoints, // 👈 added to copyWith
  }) {
    return QuizModel(
      title: title ?? this.title,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completedPercentage: completedPercentage ?? this.completedPercentage,
      icon: icon ?? this.icon,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      requiredPoints: requiredPoints ?? this.requiredPoints, // 👈 use fallback
    );
  }
}
