import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RetroPaymentScreen extends StatefulWidget {
  final int coins;
  final String price;
  final VoidCallback onPaymentSuccess;

  const RetroPaymentScreen({
    Key? key,
    required this.coins,
    required this.price,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  _RetroPaymentScreenState createState() => _RetroPaymentScreenState();
}

class _RetroPaymentScreenState extends State<RetroPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'PURCHASE ${widget.coins} COINS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
            color: Colors.purple,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 241, 228, 241),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.purple),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Purchase Summary
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.coins} Coins',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.price,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Retro Card Preview
              _buildCardPreview(),
              SizedBox(height: 30),
              // Payment Form
              _buildPaymentForm(),
              SizedBox(height: 30),
              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF2A6D), Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CREDIT CARD',
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.credit_card, color: Colors.white, size: 30),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'CARD NUMBER',
            style: TextStyle(
              fontFamily: 'Courier',
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
          Text(
            _cardNumberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : _cardNumberController.text,
            style: TextStyle(
              fontFamily: 'Courier',
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARDHOLDER NAME',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _nameController.text.isEmpty
                        ? 'YOUR NAME'
                        : _nameController.text,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRY DATE',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _expiryController.text.isEmpty
                        ? '••/••'
                        : _expiryController.text,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Card Number
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberFormatter(),
            ],
            style: TextStyle(fontFamily: 'Courier', color: Colors.purple),
            decoration: InputDecoration(
              labelText: 'CARD NUMBER',
              labelStyle: TextStyle(color: Colors.purple),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF2A6D), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.credit_card, color: Colors.purple),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter card number';
              }
              if (value.length < 16) {
                return 'Card number must be 16 digits';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 16),
          // Cardholder Name
          TextFormField(
            controller: _nameController,
            style: TextStyle(fontFamily: 'Courier', color: Colors.purple),
            decoration: InputDecoration(
              labelText: 'CARDHOLDER NAME',
              labelStyle: TextStyle(color: Colors.purple),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF2A6D), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.person, color: Colors.purple),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              // Expiry Date
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    CardExpiryFormatter(),
                  ],
                  style: TextStyle(fontFamily: 'Courier', color: Colors.purple),
                  decoration: InputDecoration(
                    labelText: 'EXPIRY (MM/YY)',
                    labelStyle: TextStyle(color: Colors.purple),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFF2A6D),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.purple,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 5) {
                      return 'Invalid date';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 16),
              // CVV
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  obscureText: true,
                  style: TextStyle(fontFamily: 'Courier', color: Colors.purple),
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    labelStyle: TextStyle(color: Colors.purple),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFF2A6D),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.purple),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 3) {
                      return 'Invalid CVV';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed:
          _isProcessing
              ? null
              : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isProcessing = true);

                  await Future.delayed(Duration(seconds: 2));

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Success! ${widget.coins} coins added'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.of(context).pop(true); // Return success status
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF2A6D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.purple, width: 2),
        ),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        elevation: 5,
      ),
      child:
          _isProcessing
              ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
              : Text(
                'PAY NOW',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

// Custom formatters
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
