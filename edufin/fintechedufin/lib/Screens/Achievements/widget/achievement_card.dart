import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AchievementState { locked, toClaim, claimed }

class AchievementCard extends StatefulWidget {
  final String achievementId;
  final String title;
  final String description;
  final String condition; // 👈 Added: condition like 'lessons>=5'
  final AchievementState initialState;
  final IconData icon;
  final Color color;
  final int rewardCoins;
  final int rewardPoints;

  const AchievementCard({
    super.key,
    required this.achievementId,
    required this.title,
    required this.description,
    required this.condition,
    required this.initialState,
    required this.icon,
    required this.color,
    required this.rewardCoins,
    required this.rewardPoints,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard> {
  late AchievementState _currentState;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  int _currentValue = 0;
  int _requiredValue = 1;
  String _requirementLabel = "";

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
    _parseCondition();
    _fetchProgressAndUpdateState();
  }

  void _parseCondition() {
    final parts = widget.condition.split(">=");
    if (parts.length == 2) {
      _requirementLabel = parts[0].trim();
      _requiredValue = int.tryParse(parts[1].trim()) ?? 1;
    }
  }

  Future<void> _fetchProgressAndUpdateState() async {
    if (_userId == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    final data = doc.data() ?? {};

    setState(() {
      _currentValue = (data[_requirementLabel] ?? 0) as int;
    });

    if (_currentValue >= _requiredValue && _currentState == AchievementState.locked) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('achievements')
          .doc(widget.achievementId)
          .set({'unlocked': true}, SetOptions(merge: true));

      setState(() => _currentState = AchievementState.toClaim);
    }

    // Check claim status
    final claimDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('achievements_claimed')
        .doc(widget.achievementId)
        .get();

    if (claimDoc.exists && claimDoc.data()?['claimed'] == true) {
      setState(() => _currentState = AchievementState.claimed);
    }
  }

  Future<void> _claimAchievement() async {
    if (_currentState != AchievementState.toClaim || _userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('achievements_claimed')
        .doc(widget.achievementId)
        .set({'claimed': true});

    await FirebaseFirestore.instance.collection('users').doc(_userId).update({
      'coins': FieldValue.increment(widget.rewardCoins),
      'points': FieldValue.increment(widget.rewardPoints),
    });

    setState(() => _currentState = AchievementState.claimed);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Claimed '${widget.title}'! 🏆 +${widget.rewardCoins}🪙 +${widget.rewardPoints}⭐",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressRatio = (_currentValue / _requiredValue).clamp(0.0, 1.0);
    final progressText = "$_currentValue of $_requiredValue $_requirementLabel";

    return GestureDetector(
      onTap: _claimAchievement,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2.0),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusBorderColor(), width: 1.5),
                ),
                child: Text(
                  _currentState == AchievementState.locked
                      ? 'LOCKED'
                      : _currentState == AchievementState.toClaim
                      ? 'CLAIM'
                      : 'CLAIMED',
                  style: TextStyle(
                    color: _getStatusTextColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: CircleAvatar(
                    backgroundColor: _getIconBackgroundColor(),
                    radius: 24,
                    child: Icon(widget.icon, color: _getIconColor(), size: 24),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(widget.description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      const SizedBox(height: 10),
                      if (_currentState != AchievementState.claimed) ...[
                        Text(
                          progressText,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 6,
                          backgroundColor: Colors.white,
                          color: widget.color,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_currentState) {
      case AchievementState.locked:
        return Colors.grey[200]!;
      case AchievementState.toClaim:
        return widget.color.withOpacity(0.2);
      case AchievementState.claimed:
        return Colors.white;
    }
  }

  Color _getIconBackgroundColor() {
    switch (_currentState) {
      case AchievementState.locked:
        return Colors.grey[300]!;
      case AchievementState.toClaim:
        return widget.color.withOpacity(0.3);
      case AchievementState.claimed:
        return widget.color.withOpacity(0.2);
    }
  }

  Color _getIconColor() {
    return _currentState == AchievementState.locked ? Colors.grey[600]! : widget.color;
  }

  Color _getStatusBackgroundColor() {
    return _currentState == AchievementState.locked
        ? Colors.black
        : widget.color.withOpacity(0.3);
  }

  Color _getStatusBorderColor() {
    return _currentState == AchievementState.locked ? Colors.grey[700]! : widget.color;
  }

  Color _getStatusTextColor() {
    return _currentState == AchievementState.locked ? Colors.white : widget.color;
  }
}
