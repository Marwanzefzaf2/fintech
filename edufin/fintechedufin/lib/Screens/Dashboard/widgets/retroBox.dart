import 'package:flutter/material.dart';

class RetroStatBox extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;
  final Color backgroundColor;

  const RetroStatBox({
    required this.title,
    required this.value,
    required this.imagePath,
    this.backgroundColor = Colors.white,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 248, 179),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle icon
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),

          const SizedBox(width: 10),

          // Title and value side by side
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
