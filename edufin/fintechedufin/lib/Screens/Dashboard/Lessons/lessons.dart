import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech/firebase_service.dart';
import 'package:fintech/Screens/BuyCoinsScreen/buycoins.dart';
import 'package:fintech/Screens/Dashboard/Lessons/lesson1.dart';
import 'package:fintech/preferences.dart';

class LessonsScreen extends StatefulWidget {
  final bool isStoreMode;
  final int initialCoins;
  final Function(int)? onCoinsUpdate;
  final String userId;

  const LessonsScreen({
    Key? key,
    this.isStoreMode = false,
    this.initialCoins = 0,
    this.onCoinsUpdate,
    required this.userId,
  }) : super(key: key);

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  List<Map<String, dynamic>> _allLessons = [];
  List<Map<String, dynamic>> _filteredLessons = [];
  List<String> _purchasedLessonIds = [];
  int _coins = 0;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Try Firestore first
      final snapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .get()
          .timeout(const Duration(seconds: 5));

      _allLessons =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
    } catch (e) {
      debugPrint("Using local lessons: $e");
    }

    try {
      final purchased = await FirebaseService.getPurchasedLessons(
        widget.userId,
      );
      final localPurchased = await Preferences.getPurchasedLessons(
        widget.userId,
      );
      _purchasedLessonIds = [...purchased, ...localPurchased];
    } catch (e) {
      debugPrint("Error loading purchases: $e");
    }

    _filterLessons();
    setState(() => _isLoading = false);
  }

  void _filterLessons() {
    _filteredLessons =
        widget.isStoreMode
            ? _allLessons
            : _allLessons
                .where((lesson) => _purchasedLessonIds.contains(lesson['id']))
                .toList();
  }

  void _searchLessons(String query) {
    final sourceList =
        widget.isStoreMode
            ? _allLessons
            : _allLessons
                .where((l) => _purchasedLessonIds.contains(l['id']))
                .toList();

    setState(() {
      _filteredLessons =
          sourceList.where((lesson) {
            final title = (lesson['title'] ?? '').toLowerCase();
            final desc = (lesson['description'] ?? '').toLowerCase();
            return title.contains(query.toLowerCase()) ||
                desc.contains(query.toLowerCase());
          }).toList();
    });
  }

  Future<void> _purchaseLesson(Map<String, dynamic> lesson) async {
    try {
      final price = lesson['price'] as int;
      if (_coins >= price) {
        // Save to both Firestore and local preferences
        await FirebaseService.purchaseLesson(
          widget.userId,
          lesson['id'],
          price,
        );
        await Preferences.savePurchasedLesson(widget.userId, lesson['id']);
        await Preferences.saveCoins(widget.userId, _coins - price);

        setState(() {
          _coins -= price;
          _purchasedLessonIds.add(lesson['id']);
          _filterLessons();
        });

        widget.onCoinsUpdate?.call(_coins);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchased ${lesson['title']}!')),
        );
      } else {
        _showNotEnoughCoinsDialog();
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: ${e.toString()}')),
      );
    }
  }

  void _showNotEnoughCoinsDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Not Enough Coins'),
            content: const Text('Would you like to buy more coins?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BuyCoinsScreen(
                            userId: widget.userId,
                            onCoinsUpdate: (updatedCoins) {
                              setState(() => _coins = updatedCoins);
                              widget.onCoinsUpdate?.call(updatedCoins);
                            },
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade200,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: const Text(
                  'Buy Coins',
                  style: TextStyle(fontFamily: 'PressStart2P'),
                ),
              ),
            ],
          ),
    );
  }

  void _openLesson(Map<String, dynamic> lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Lesson1Screen(lessonId: lesson['id'], userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF1E6),
      appBar:
          widget.isStoreMode
              ? null
              : AppBar(
                backgroundColor: const Color(0xFFFAF1E6),
                elevation: 4,
                title: const Text(
                  'FinTech Lessons',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
              ),
      body: Column(
        children: [
          if (widget.isStoreMode) _buildCoinsHeader(),
          _buildSearchBar(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredLessons.isEmpty
                    ? const Center(child: Text("No lessons available"))
                    : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _filteredLessons.length,
                        itemBuilder:
                            (_, index) => LessonCard(
                              lesson: _filteredLessons[index],
                              isStoreMode: widget.isStoreMode,
                              isPurchased: _purchasedLessonIds.contains(
                                _filteredLessons[index]['id'],
                              ),
                              coins: _coins,
                              onPurchase: _purchaseLesson,
                              onOpen: _openLesson,
                            ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset('Assets/Images/coin.png', width: 20),
          const SizedBox(width: 4),
          Text(
            'Coins: $_coins',
            style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 12),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _searchLessons,
          decoration: InputDecoration(
            hintText: 'Search lessons...',
            hintStyle: const TextStyle(fontFamily: 'PressStart2P'),
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 12),
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final bool isStoreMode;
  final bool isPurchased;
  final int coins;
  final Function(Map<String, dynamic>) onPurchase;
  final Function(Map<String, dynamic>) onOpen;

  const LessonCard({
    Key? key,
    required this.lesson,
    required this.isStoreMode,
    required this.isPurchased,
    required this.coins,
    required this.onPurchase,
    required this.onOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(lesson['color'] ?? '#FFFFFF');

    return GestureDetector(
      onTap:
          () =>
              isStoreMode && !isPurchased ? onPurchase(lesson) : onOpen(lesson),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.asset(
                lesson['imagePath'] ?? '',
                height: 120,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey,
                      child: const Center(child: Icon(Icons.error)),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPurchased && !isStoreMode)
                    const Text(
                      'OWNED',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    lesson['title'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson['description'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${lesson['price'] ?? 0} coins',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isStoreMode)
                        ElevatedButton(
                          onPressed:
                              isPurchased ? null : () => onPurchase(lesson),
                          child: Text(
                            isPurchased ? 'OWNED' : 'BUY',
                            style: const TextStyle(fontFamily: 'PressStart2P'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPurchased
                                    ? Colors.green.shade100
                                    : coins >= (lesson['price'] ?? 0)
                                    ? Colors.orange.shade100
                                    : Colors.grey,
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
