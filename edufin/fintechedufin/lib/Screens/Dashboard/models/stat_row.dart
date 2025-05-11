import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fintech/Screens/Dashboard/widgets/retroBox.dart';

class StatRow extends StatefulWidget {
  final String userId;

  const StatRow({super.key, required this.userId});

  @override
  State<StatRow> createState() => _StatRowState();
}

class _StatRowState extends State<StatRow> {
  int _coins = 0;
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
    if (!mounted) return;
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _coins = data?['coins'] ?? 0;
        _points = data?['points'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: RetroStatBox(
              title: "Points:",
              value: _points.toString(),
              imagePath: 'Assets/Images/star.png',
              backgroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: RetroStatBox(
              title: "Coins:",
              value: _coins.toString(),
              imagePath: 'Assets/Images/coin.png',
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
