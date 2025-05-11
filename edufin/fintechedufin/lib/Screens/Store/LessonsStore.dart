import 'package:flutter/material.dart';
import 'package:fintech/Screens/Dashboard/Lessons/lessons.dart';
import 'package:fintech/firebase_service.dart';

class LessonsStoreTab extends StatefulWidget {
  final String userId;
  final Function(int) onCoinsUpdate;

  const LessonsStoreTab({
    Key? key,
    required this.userId,
    required this.onCoinsUpdate,
  }) : super(key: key);

  @override
  State<LessonsStoreTab> createState() => _LessonsStoreTabState();
}

class _LessonsStoreTabState extends State<LessonsStoreTab> {
  final FirebaseService _firebaseService = FirebaseService();
  int _coins = 0;  // default value to avoid null safety issue
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final data = await _firebaseService.getUserData(widget.userId);
    if (mounted) {
      setState(() {
        _coins = data?['coins'] ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LessonsScreen(
      isStoreMode: true,
      initialCoins: _coins,
      onCoinsUpdate: widget.onCoinsUpdate,
      userId: widget.userId,
    );
  }
}
