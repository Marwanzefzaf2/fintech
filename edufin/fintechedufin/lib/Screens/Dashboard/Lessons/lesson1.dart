// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fintech/firebase_service.dart';
// import 'package:fintech/Screens/Quiz/quiz_list_screen.dart';

// class Lesson1Screen extends StatefulWidget {
//   final String lessonId;
//   final String userId;

//   const Lesson1Screen({Key? key, required this.lessonId, required this.userId})
//     : super(key: key);

//   @override
//   State<Lesson1Screen> createState() => _Lesson1ScreenState();
// }

// class _Lesson1ScreenState extends State<Lesson1Screen> {
//   late Future<Map<String, dynamic>?> _lessonFuture;

//   @override
//   void initState() {
//     super.initState();
//     _lessonFuture = _loadLesson();
//   }

//   Future<Map<String, dynamic>?> _loadLesson() async {
//     final doc =
//         await FirebaseFirestore.instance
//             .collection('lessons')
//             .doc(widget.lessonId)
//             .get();
//     if (!doc.exists) return null;
//     final data = doc.data();

//     if (data != null) {
//       final xp = data['xp'] ?? 0.25;
//       final points = data['points'] ?? 50;

//       await FirebaseService.markLessonCompleted(widget.userId, widget.lessonId);
//       await FirebaseService.updateXP(widget.userId, xp);
//       await FirebaseService.updatePoints(widget.userId, points);
//       await FirebaseService.unlockAchievementsAfterLesson(
//         widget.userId,
//         widget.lessonId,
//       );
//     }

//     return data;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: _lessonFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data == null) {
//           return const Scaffold(body: Center(child: Text("Lesson not found")));
//         }

//         final lesson = snapshot.data!;
//         final bullets = List<String>.from(lesson['bullets'] ?? []);
//         final title = lesson['title'] ?? 'Lesson';
//         final description = lesson['description'] ?? '';
//         final imagePath = lesson['imagePath'] ?? '';
//         final color = _hexToColor(lesson['color'] ?? '#FFFFFF');

//         return Scaffold(
//           backgroundColor: const Color(0xFFFAF1E6),
//           appBar: AppBar(
//             backgroundColor: const Color(0xFFFCDA9C),
//             elevation: 4,
//             title: Text(
//               title,
//               style: const TextStyle(
//                 fontFamily: 'PressStart2P',
//                 fontSize: 14,
//                 color: Colors.black,
//               ),
//             ),
//             centerTitle: true,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 if (imagePath.isNotEmpty)
//                   Image.asset(
//                     imagePath,
//                     height: 150,
//                     errorBuilder: (_, __, ___) => const Icon(Icons.image),
//                   ),
//                 const SizedBox(height: 20),
//                 Text(
//                   description,
//                   style: const TextStyle(
//                     fontFamily: 'PressStart2P',
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: ListView.separated(
//                     itemCount: bullets.length,
//                     separatorBuilder: (_, __) => const Divider(),
//                     itemBuilder: (context, index) {
//                       return Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Icon(Icons.brightness_1, size: 8),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               bullets[index],
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontFamily: 'PressStart2P',
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (_) => QuizListScreen(
//                               autoStartQuizId: widget.lessonId,
//                               userId: widget.userId,
//                             ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade300,
//                     foregroundColor: Colors.black,
//                     side: const BorderSide(color: Colors.black, width: 2),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                   child: const Text(
//                     'Take Quiz',
//                     style: TextStyle(fontFamily: 'PressStart2P'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Color _hexToColor(String hex) {
//     hex = hex.replaceFirst('#', '');
//     if (hex.length == 6) hex = 'FF$hex';
//     return Color(int.parse(hex, radix: 16));
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fintech/firebase_service.dart';
import 'package:fintech/Screens/Quiz/quiz_list_screen.dart';

class Lesson1Screen extends StatefulWidget {
  final String lessonId;
  final String userId;

  const Lesson1Screen({Key? key, required this.lessonId, required this.userId})
    : super(key: key);

  @override
  State<Lesson1Screen> createState() => _Lesson1ScreenState();
}

class _Lesson1ScreenState extends State<Lesson1Screen> {
  late Future<Map<String, dynamic>?> _lessonFuture;

  @override
  void initState() {
    super.initState();
    _lessonFuture = _loadLesson();
  }

  Future<Map<String, dynamic>?> _loadLesson() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('lessons')
            .doc(widget.lessonId)
            .get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<void> _completeLesson() async {
    final data = await _lessonFuture;
    if (data != null) {
      final xp = data['xp'] ?? 0.25;
      final points = data['points'] ?? 50;

      await FirebaseService.markLessonCompleted(widget.userId, widget.lessonId);
      await FirebaseService.updateXP(widget.userId, xp);
      await FirebaseService.updatePoints(widget.userId, points);
      await FirebaseService.unlockAchievementsAfterLesson(
        widget.userId,
        widget.lessonId,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => QuizListScreen(
              autoStartQuizId: widget.lessonId,
              userId: widget.userId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _lessonFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text("Lesson not found")));
        }

        final lesson = snapshot.data!;
        final bullets = List<String>.from(lesson['bullets'] ?? []);
        final title = lesson['title'] ?? 'Lesson';
        final description = lesson['description'] ?? '';
        final imagePath = lesson['imagePath'] ?? '';
        final color = _hexToColor(lesson['color'] ?? '#FFFFFF');

        return Scaffold(
          backgroundColor: const Color(0xFFFAF1E6),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCDA9C),
            elevation: 4,
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (imagePath.isNotEmpty)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey.shade600,
                                    ),
                                    Text(
                                      'Lesson Image',
                                      style: TextStyle(
                                        fontFamily: 'PressStart2P',
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: bullets.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final line = bullets[index];
                      final isBullet = line.startsWith(RegExp(r'[•✓]|[\d]\.'));
                      final icon =
                          line.startsWith('✓')
                              ? Icons.check
                              : line.startsWith('•')
                              ? Icons.circle
                              : line.startsWith(RegExp(r'[\d]\.'))
                              ? Icons.looks_one
                              : Icons.text_fields;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child:
                            isBullet
                                ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(icon, size: 16, color: Colors.black87),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        line.substring(1).trim(),
                                        style: const TextStyle(
                                          fontFamily: 'PressStart2P',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Text(
                                  line,
                                  style: const TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 14,
                                  ),
                                ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _completeLesson,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade200,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'TAKE QUIZ!',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
