import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintech/Screens/BuyCoinsScreen/buycoins.dart';
import 'package:flutter/material.dart';

class VouchersScreen extends StatefulWidget {
  final int initialCoins;
  final int initialPoints;
  final Function(int) onCoinsUpdate;
  final Function(int) onPointsUpdate;
  final String userId;

  const VouchersScreen({
    Key? key,
    required this.initialCoins,
    required this.initialPoints,
    required this.onCoinsUpdate,
    required this.onPointsUpdate,
    required this.userId,
  }) : super(key: key);

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  late int _coins;
  late int _points;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _vouchers = [
    {
      'title': '5% Cashback',
      'description': 'Get 5% back on next purchase',
      'cost': 50,
      'icon': Icons.percent,
      'color': Colors.purpleAccent.shade100,
    },
    {
      'title': 'Free Transfer',
      'description': 'Zero fees for 1 transaction',
      'cost': 30,
      'icon': Icons.send,
      'color': Colors.blueAccent.shade100,
    },
    {
      'title': 'Double Points',
      'description': '2x rewards for 24h',
      'cost': 80,
      'icon': Icons.star,
      'color': Colors.yellowAccent.shade100,
    },
    {
      'title': 'Discount+',
      'description': '10% off investments',
      'cost': 100,
      'icon': Icons.discount,
      'color': Colors.greenAccent.shade100,
    },
  ];

  Set<String> _redeemedVouchers = {};

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _points = widget.initialPoints;
    _loadVoucherData();
  }

  Future<void> _loadVoucherData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (doc.exists) {
        final data = doc.data();
        _coins = data?['coins'] ?? _coins;
        _points = data?['points'] ?? _points;

        final redeemedSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('vouchers_redeemed')
            .get();

        _redeemedVouchers = redeemedSnapshot.docs.map((doc) => doc.id).toSet();
      }
    } catch (e) {
      print('Error loading voucher data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _redeemWithCoins(Map<String, dynamic> voucher) async {
    final int cost = voucher['cost'];
    final String title = voucher['title'];

    if (_coins >= cost) {
      try {
        final newCoins = _coins - cost;

        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'coins': newCoins,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('vouchers_redeemed')
            .doc(title)
            .set({'redeemed': true});

        setState(() {
          _coins = newCoins;
          _redeemedVouchers.add(title);
        });

        widget.onCoinsUpdate(newCoins);
        _showSuccessDialog(title);
      } catch (e) {
        print('Redemption error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to redeem: $e')),
        );
      }
    } else {
      _showCoinErrorDialog();
    }
  }

  void _showSuccessDialog(String voucherTitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success!'),
        content: Text('You redeemed: $voucherTitle'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showCoinErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Not Enough Coins'),
        content: const Text('You need more coins to redeem this voucher.'),
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
                  builder: (_) => BuyCoinsScreen(
                    onCoinsUpdate: (updatedCoins) {
                      setState(() => _coins = updatedCoins);
                      widget.onCoinsUpdate(updatedCoins);
                    },
                    userId: widget.userId,
                  ),
                ),
              );
            },
            child: const Text('Buy Coins'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final availableVouchers = _vouchers.where((v) => !_redeemedVouchers.contains(v['title'])).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Points: $_points", style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 12)),
              Text("Coins: $_coins", style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: availableVouchers.length,
            itemBuilder: (context, index) {
              final voucher = availableVouchers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildVoucherCard(voucher),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> voucher) {
    return Card(
      color: voucher['color'],
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(voucher['icon'], size: 32),
        title: Text(voucher['title'], style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 10)),
        subtitle: Text(voucher['description'], style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 8)),
        trailing: ElevatedButton(
          onPressed: () => _redeemWithCoins(voucher),
          child: Text('${voucher['cost']} coins'),
        ),
      ),
    );
  }
}
