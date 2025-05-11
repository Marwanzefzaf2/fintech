import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech/Screens/BuyCoinsScreen/buycoins.dart';

class AvatarsScreen extends StatefulWidget {
  final int initialCoins;
  final int initialPoints;
  final Function(int) onCoinsUpdate;
  final Function(int) onPointsUpdate;
  final String userId;
  final Function(String) onAvatarChanged;

  const AvatarsScreen({
    Key? key,
    required this.initialCoins,
    required this.initialPoints,
    required this.onCoinsUpdate,
    required this.onPointsUpdate,
    required this.userId,
    required this.onAvatarChanged,
  }) : super(key: key);

  @override
  State<AvatarsScreen> createState() => _AvatarsScreenState();
}

class _AvatarsScreenState extends State<AvatarsScreen> {
  late int _coins;
  late int _points;
  Set<String> _purchasedAvatars = {};
  String? _avatarInUse;

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _points = widget.initialPoints;
    _loadAvatarData();
  }

  Future<void> _loadAvatarData() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
    if (userDoc.exists) {
      final data = userDoc.data();
      final List<dynamic> purchased = data?['purchased_avatars'] ?? [];
      final String? avatar = data?['avatarId'];

      setState(() {
        _purchasedAvatars = Set<String>.from(purchased);
        _avatarInUse = avatar;
      });
    }
  }

  Future<void> _buyWithCoins(int coinCost, String avatarId) async {
    if (_coins >= coinCost) {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId);
      await FirebaseFirestore.instance.runTransaction((txn) async {
        final snapshot = await txn.get(userRef);
        final data = snapshot.data() ?? {};
        final int currentCoins = data['coins'] ?? 0;
        final List<dynamic> owned = data['purchased_avatars'] ?? [];

        if (currentCoins < coinCost) throw Exception("Insufficient coins");

        txn.update(userRef, {
          'coins': currentCoins - coinCost,
          'purchased_avatars': FieldValue.arrayUnion([avatarId]),
        });
      });

      setState(() {
        _coins -= coinCost;
        _purchasedAvatars.add(avatarId);
      });
      widget.onCoinsUpdate(_coins);
    } else {
      _showNotEnoughCoinsDialog();
    }
  }

  void _showNotEnoughCoinsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Not Enough Coins'),
            content: const Text(
              'Coins are not sufficient. Do you want to buy more coins?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BuyCoinsScreen(
                            userId: widget.userId,
                            onCoinsUpdate: (updatedCoins) {
                              setState(() {
                                _coins = updatedCoins;
                              });
                            },
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade200,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Buy Coins',
                  style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _setAvatarInUse(String avatarId) async {
    if (!_purchasedAvatars.contains(avatarId)) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'avatarId': avatarId});

    setState(() {
      _avatarInUse = avatarId;
    });

    widget.onAvatarChanged(avatarId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('Assets/Images/star.png', height: 18),
                    const SizedBox(width: 4),
                    Text(
                      "Points: $_points",
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      'Assets/Images/coin.png',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Coins: $_coins",
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _buildAvatarCards(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAvatarCards() {
    final avatars = [
      {
        'title': 'Flower Girl',
        'id': 'flower_girl',
        'cost': 10,
        'path': 'Assets/Images/avatar.png',
      },
      {
        'title': 'Mystic Elf',
        'id': 'mystic_elf',
        'cost': 20,
        'path': 'Assets/Images/avatar1.png',
      },
      {
        'title': 'Techie Tina',
        'id': 'techie tina',
        'cost': 40,
        'path': 'Assets/Images/avatar2.png',
      },
      {
        'title': 'Bun Girl',
        'id': 'bun girl',
        'cost': 60,
        'path': 'Assets/Images/avatar3.png',
      },
      {
        'title': 'Arcane Master',
        'id': 'arcane master',
        'cost': 80,
        'path': 'Assets/Images/avatar4.png',
      },
      {
        'title': 'Sunny Boy',
        'id': 'sunny boy',
        'cost': 110,
        'path': 'Assets/Images/avatar5.png',
      },
      {
        'title': 'Cool Boy',
        'id': 'cool boy',
        'cost': 150,
        'path': 'Assets/Images/avatar6.png',
      },
      {
        'title': 'Beard Bro',
        'id': 'beard bro',
        'cost': 180,
        'path': 'Assets/Images/avatar7.png',
      },
      {
        'title': 'Sharp Jack',
        'id': 'sharp jack',
        'cost': 200,
        'path': 'Assets/Images/avatar8.png',
      },
    ];

    return avatars.map((avatar) {
      final isPurchased = _purchasedAvatars.contains(avatar['id']);
      final isInUse = _avatarInUse == avatar['id'];

      return _buildAvatarCard(
        title: avatar['title'] as String,
        avatarId: avatar['id'] as String,
        costText: '${avatar['cost']} coins',
        imagePath: avatar['path'] as String,
        isPurchased: isPurchased,
        isInUse: isInUse,
        onBuy:
            () => _buyWithCoins(avatar['cost'] as int, avatar['id'] as String),
        onUse: () => _setAvatarInUse(avatar['id'] as String),
      );
    }).toList();
  }

  Widget _buildAvatarCard({
    required String title,
    required String avatarId,
    required String costText,
    required String imagePath,
    required bool isPurchased,
    required bool isInUse,
    required VoidCallback onBuy,
    required VoidCallback onUse,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        // 👈 makes the card content scrollable
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage(imagePath),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              costText,
              style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 7),
            ),
            if (!isPurchased)
              ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: const Text(
                  'BUY',
                  style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
                ),
              ),
            if (isPurchased && !isInUse)
              ElevatedButton(
                onPressed: onUse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: const Text(
                  'USE',
                  style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
                ),
              ),
            if (isInUse)
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: const Text(
                  'IN USE',
                  style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
