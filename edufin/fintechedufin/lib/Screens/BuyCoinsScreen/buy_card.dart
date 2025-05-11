import 'package:fintech/Screens/BuyCoinsScreen/payement.dart';
import 'package:flutter/material.dart';

class BuyCard extends StatefulWidget {
  final int coins;
  final String price;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const BuyCard({
    Key? key,
    required this.coins,
    required this.price,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<BuyCard> createState() => _BuyCardState();
}

class _BuyCardState extends State<BuyCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.green, size: 32),
              const SizedBox(width: 8),
              Text(
                '${widget.coins} Coins',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final success = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RetroPaymentScreen(
                            coins: widget.coins,
                            price: widget.price,
                            onPaymentSuccess:
                                () {}, // Empty callback, handled by return value
                          ),
                    ),
                  );

                  if (success == true && mounted) {
                    widget.onPressed();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: Text(
                  'Buy for ${widget.price}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Courier',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
