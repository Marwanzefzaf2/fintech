import 'package:flutter/material.dart';
import 'package:fintech/Screens/Achievements/widget/achievement_card.dart';
import 'package:fintech/Screens/Achievements/widget/achievements_grid.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Achievements'),
        centerTitle: true,
        elevation: 0,
        backgroundColor:const Color.fromARGB(255, 245, 228, 202), 

      ),
      backgroundColor:const Color.fromARGB(255, 245, 228, 202),

      body:  SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AchievementsList()
              ],
            ),
          ),
        ),
      ),
    );
  }
}