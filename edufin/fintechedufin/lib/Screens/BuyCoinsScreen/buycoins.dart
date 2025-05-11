import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech/Screens/BuyCoinsScreen/buy_card.dart';
import 'package:flutter/material.dart';

class BuyCoinsScreen extends StatefulWidget {
  final Function(int) onCoinsUpdate;
  final String userId; // ✅ Accept userId directly

  const BuyCoinsScreen({
    super.key,
    required this.onCoinsUpdate,
    required this.userId, // ✅ Add this
  });

  @override
  State<BuyCoinsScreen> createState() => _BuyCoinsScreenState();
}

class _BuyCoinsScreenState extends State<BuyCoinsScreen> {
  int _coins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoinsFromFirestore();
  }

  Future<void> _loadCoinsFromFirestore() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();
      if (doc.exists) {
        setState(() {
          _coins = doc.data()?['coins'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading coins: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error loading coins.'),
          backgroundColor: Colors.red.shade300,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buyCoins(int amount) async {
    try {
      final newTotal = _coins + amount;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'coins': newTotal});

      if (!mounted) return; // Add this check

      setState(() {
        _coins = newTotal;
      });

      widget.onCoinsUpdate(newTotal);

      if (!mounted) return; // Add this check

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '+$amount Coins Added!',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'courier',
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.green.shade400,
        ),
      );
    } catch (e) {
      print('Error purchasing coins: $e');
      if (!mounted) return; // Add this check

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to purchase coins. Try again.'),
          backgroundColor: Colors.red.shade300,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Buy Coins',
          style: TextStyle(fontFamily: 'PressStart2P'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            BuyCard(
              coins: 50,
              price: '\$20',
              title: 'Starter Pack',
              subtitle: 'Great for testing the store experience!',
              onPressed: () => _buyCoins(50),
            ),
            BuyCard(
              coins: 120,
              price: '\$280',
              title: 'Standard Pack',
              subtitle: 'Most popular choice for learners',
              onPressed: () => _buyCoins(120),
            ),
            BuyCard(
              coins: 300,
              price: '\$600',
              title: 'Mega Pack',
              subtitle: 'Unlock quizzes and vouchers faster!',
              onPressed: () => _buyCoins(300),
            ),
            BuyCard(
              coins: 800,
              price: '\$1500',
              title: 'Ultimate Bundle',
              subtitle: 'Everything you’ll ever need!',
              onPressed: () => _buyCoins(800),
            ),
          ],
        ),
      ),
    );
  }
}
