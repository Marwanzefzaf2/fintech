import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech/Screens/Signup/signup_screen.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return; // Early exit if the widget is no longer in the tree

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _loginController.login(
        context,
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        _isLoading = false;
        if (!success) {
          _errorMessage = 'Login failed. Please check your credentials.';
        }
      });

      if (success) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email == 'admin@edufin.com') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred during login.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 250, 217),
      extendBodyBehindAppBar: true, // This makes the app bar transparent
      appBar: AppBar(
        title: const Text(
          'Hop on board!!',
          style: TextStyle(
            fontFamily: 'KT Nirma',
            color: Color.fromARGB(255, 233, 126, 20),
            fontWeight: FontWeight.bold,
            fontSize: 30,
            letterSpacing: 0.9,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Remove shadow
        // leading: IconButton(
        //   icon: Image.asset(
        //     'Assets/Images/Arrow.png', // Your custom arrow image
        //     width: 24, // Adjust size as needed
        //     height: 24,
        //     color: Colors.black, // Optional: if you want to tint the image
        //   ),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        iconTheme: const IconThemeData(
          color: Colors.black, // This ensures all app bar icons are black
        ),
      ),
      body: Stack(
        children: [
          // Background Images
          Positioned(
            top: 40,
            left: 20,
            child: Image.asset('Assets/Images/fig(1).png', width: 50),
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: Image.asset('Assets/Images/fig.png', width: 70),
          ),
          Positioned(
            bottom: 20,
            right: 160,
            child: Image.asset('Assets/Images/fig.png', width: 70),
          ),
          Positioned(
            top: 200,
            right: 600,
            child: Image.asset('Assets/Images/fig(1).png', width: 1155),
          ),
          Positioned(
            bottom: 150,
            left: 50,
            child: Image.asset('Assets/Images/fig(1).png', width: 55),
          ),
          Positioned(
            top: 100,
            left: 100,
            child: Image.asset('Assets/Images/fig(1).png', width: 35),
          ),

          // Login Form
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 255, 145),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.black, width: 4.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(-8, 8),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Login in to your account',
                        style: TextStyle(
                          fontSize: 22,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              222,
                              191,
                              255,
                            ),
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isLoading ? null : _submitForm,
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
