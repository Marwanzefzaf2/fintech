import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressCircle extends StatelessWidget {
  final double levelProgress;
  final int currentLevel;

  const ProgressCircle({
    super.key,
    required this.levelProgress,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    int percentDisplay = (levelProgress.clamp(0.0, 1.0) * 100).toInt();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            245,
            228,
            202,
          ), // retro yellow background
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: CircularPercentIndicator(
          radius: 90.0,
          lineWidth: 10.0,
          animation: true,
          percent: levelProgress.clamp(0.0, 1.0),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: const Color.fromARGB(255, 126, 39, 232),
          backgroundColor: const Color.fromARGB(255, 247, 243, 243),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Level $currentLevel",
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$percentDisplay% done",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
