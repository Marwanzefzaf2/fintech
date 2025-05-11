import 'package:fintech/Screens/Store/Avatar.dart';
import 'package:fintech/Screens/Store/LessonsStore.dart';
import 'package:fintech/Screens/Store/Voucher.dart';
import 'package:flutter/material.dart';
import 'package:fintech/firebase_service.dart';

class StoreScreen extends StatefulWidget {
  final String userId;
  final int initialCoins;
  final int initialPoints;
  final Function(int) onCoinsUpdate;
  final Function(int) onPointsUpdate;
  final Function(String) onAvatarChanged;

  const StoreScreen({
    Key? key,
    required this.userId,
    required this.initialCoins,
    required this.initialPoints,
    required this.onCoinsUpdate,
    required this.onPointsUpdate,
    required this.onAvatarChanged,
  }) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late int _coins;
  late int _points;
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _firebaseService.getUserData(widget.userId);
    if (mounted) {
      setState(() {
        _coins = data?['coins'] ?? widget.initialCoins;
        _points = data?['points'] ?? widget.initialPoints;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCoins(int newCoins) async {
    await _firebaseService.updateUserField(widget.userId, {'coins': newCoins});
    if (mounted) {
      setState(() => _coins = newCoins);
    }
    widget.onCoinsUpdate(newCoins);
  }

  Future<void> _updatePoints(int newPoints) async {
    await _firebaseService.updateUserField(widget.userId, {'points': newPoints});
    if (mounted) {
      setState(() => _points = newPoints);
    }
    widget.onPointsUpdate(newPoints);
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFAF1E6);
    const headerColor = Color(0xFFFCDA9C);
    const accentColor = Color(0xFF5D3A00);

    TextStyle tabTextStyle = const TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: 10,
      color: Colors.black,
    );

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: headerColor,
          elevation: 4,
          iconTheme: const IconThemeData(color: Colors.black),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'Store',
              key: ValueKey('StoreTitle'),
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          bottom: TabBar(
            indicator: RetroTabIndicator(color: accentColor),
            labelColor: accentColor,
            unselectedLabelColor: Colors.black54,
            labelStyle: tabTextStyle,
            tabs: const [
              Tab(icon: Icon(Icons.face), text: 'Avatars'),
              Tab(icon: Icon(Icons.menu_book), text: 'Lessons'),
              Tab(icon: Icon(Icons.card_giftcard), text: 'Vouchers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AvatarsScreen(
              userId: widget.userId,
              initialCoins: _coins,
              initialPoints: _points,
              onCoinsUpdate: _updateCoins,
              onPointsUpdate: _updatePoints,
              onAvatarChanged: widget.onAvatarChanged,
            ),
            LessonsStoreTab(
              userId: widget.userId,
              onCoinsUpdate: _updateCoins,
            ),
            VouchersScreen(
              userId: widget.userId,
              initialCoins: _coins,
              initialPoints: _points,
              onCoinsUpdate: _updateCoins,
              onPointsUpdate: _updatePoints,
            ),
          ],
        ),
      ),
    );
  }
}

class RetroTabIndicator extends Decoration {
  final Color color;

  const RetroTabIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RetroPainter(color);
  }
}

class _RetroPainter extends BoxPainter {
  final Color color;
  _RetroPainter(this.color);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Rect rect = Offset(offset.dx, configuration.size!.height - 4) &
    Size(configuration.size!.width, 4);
    canvas.drawRect(rect, paint);
  }
}
