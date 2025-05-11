import 'package:fintech/Screens/Achievements/achievements.dart';
import 'package:fintech/Screens/Achievements/widget/achievements_grid.dart';
import 'package:fintech/Screens/Dashboard/Lessons/lessons.dart';
import 'package:fintech/Screens/Quiz/quiz_list_screen.dart';
import 'package:fintech/Screens/Store/store.dart';
import 'package:fintech/preferences.dart';
import 'package:flutter/material.dart';
import 'package:fintech/Screens/Dashboard/widgets/retrogrid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SectionGrid extends StatefulWidget {
  final Function(String) onAvatarChanged; // Add this callback parameter
  final String userId;

  const SectionGrid({
    super.key,
    required this.onAvatarChanged,
    required this.userId, // Require userId
  });

  @override
  State<SectionGrid> createState() => _SectionGridState();
}

class _SectionGridState extends State<SectionGrid> {
  int _coins = 100;
  int _points = 50;

  @override
  void initState() {
    super.initState();
    _loadCoinsAndPoints();
  }

  Future<void> _loadCoinsAndPoints() async {
    final coins = await QuizPreferences.getCoins(widget.userId);
    setState(() {
      _coins = coins;
      _points = 0; // If you plan to track points later from preferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      children: [
        RetroGridItem(
          title: "Lessons",
          iconPath: 'Assets/Images/lessons.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => LessonsScreen(
                      isStoreMode: false,

                      userId: widget.userId,
                    ),
              ),
            );
          },
        ),
        RetroGridItem(
          title: "Quizzes",
          iconPath: 'Assets/Images/quizzes.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizListScreen(userId: widget.userId),
              ),
            );
          },
        ),
        RetroGridItem(
          title: "Store",
          iconPath: 'Assets/Images/store.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => StoreScreen(
                      userId: widget.userId,
                      initialCoins: 100,
                      initialPoints: 50,
                      onCoinsUpdate: (coins) {
                        setState(() {
                          _coins = coins;
                        });
                      },
                      onPointsUpdate: (points) {
                        setState(() {
                          _points = points;
                        });
                      },
                      onAvatarChanged:
                          widget.onAvatarChanged, // Pass the callback
                    ),
              ),
            );
          },
        ),
        RetroGridItem(
          title: "Achievements",
          iconPath: 'Assets/Images/achievements.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AchievementsPage()),
            );
          },
        ),
      ],
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home Screen")),
//       body: Center(
//         child: Text('This is the home screen', style: TextStyle(fontSize: 20)),
//       ),
//     );
//   }
// }
