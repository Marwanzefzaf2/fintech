import 'package:fintech/Screens/admin/AccessDeniedScreen.dart';
import 'package:fintech/Screens/admin/AdminPanelPage.dart';
import 'package:fintech/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'Screens/login/login_screen.dart';
import 'Screens/dashboard/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String adminEmail = 'admin@edufin.com';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduFin',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin': (context) {
          final user = FirebaseAuth.instance.currentUser;

          if (user != null &&
              user.email?.trim().toLowerCase() == adminEmail.toLowerCase()) {
            return const AdminPanelPage();
          } else {
            return const AccessDeniedScreen();
          }
        },
      },
    );
  }
}
