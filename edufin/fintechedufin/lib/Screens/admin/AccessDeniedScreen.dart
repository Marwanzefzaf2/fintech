import 'package:flutter/material.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Access Denied',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
    );
  }
}
