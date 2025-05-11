// avatar_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarService extends ChangeNotifier {
  String? _currentAvatarPath;
  String? get currentAvatarPath => _currentAvatarPath;

  final Map<String, String> avatarPaths = {
    'flower_girl': 'Assets/Images/avatar.png',
    'mystic_elf': 'Assets/Images/avatar1.png',
    'techie tina': 'Assets/Images/avatar2.png',
    'bun girl': 'Assets/Images/avatar3.png',
    'arcane master': 'Assets/Images/avatar4.png',
    'sunny boy': 'Assets/Images/avatar5.png',
    'cool boy': 'Assets/Images/avatar6.png',
    'beard bro': 'Assets/Images/avatar7.png',
    'sharp jack': 'Assets/Images/avatar8.png',
  };

  Future<void> loadCurrentAvatar(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final avatarId = prefs.getString('avatar_in_use_$userId');
    if (avatarId != null && avatarPaths.containsKey(avatarId)) {
      _currentAvatarPath = avatarPaths[avatarId];
      notifyListeners();
    }
  }

  Future<void> updateCurrentAvatar(String userId, String avatarId) async {
    if (avatarPaths.containsKey(avatarId)) {
      _currentAvatarPath = avatarPaths[avatarId];
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_in_use_$userId', avatarId);
    }
  }
}
