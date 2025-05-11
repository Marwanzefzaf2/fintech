import 'package:flutter/material.dart';

class RetroGridItem extends StatefulWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const RetroGridItem({
    required this.title,
    required this.iconPath,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<RetroGridItem> createState() => _RetroGridItemState();
}

class _RetroGridItemState extends State<RetroGridItem> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap(); // trigger navigation here
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 254, 248, 179),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 0,
                offset: Offset(4, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(12), // optional: round edges
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.iconPath,
                height: 120,
                width: 300,
                fit: BoxFit.cover,
              ),
              // const SizedBox(height: 10),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
