import 'package:flutter/material.dart';

class QuizColors {
  static const primary = Color(0xFFFFF391);
  static const background = Color(0xFFFFFCE1);
  static const card = Color(0xFFFFF391);
  static const button = Color(0xFFCE93D8); // Purple[200]
  static const correctAnswer = Color(0xFFA5D6A7); // Green[200]
  static const wrongAnswer = Color(0xFFEF9A9A); // Red[200]

  static const blackBorder = BorderSide(color: Colors.black, width: 2);
  static const thickBlackBorder = BorderSide(color: Colors.black, width: 3);

  static const shadow = BoxShadow(
    color: Colors.black,
    offset: Offset(3, 3),
    blurRadius: 0,
  );
  static const thickShadow = BoxShadow(
    color: Colors.black,
    offset: Offset(4, 4),
    blurRadius: 0,
  );

  static TextStyle courierText(double size, [FontWeight? weight]) {
    return TextStyle(
      fontFamily: 'Courier',
      fontSize: size,
      fontWeight: weight ?? FontWeight.normal,
    );
  }
}
