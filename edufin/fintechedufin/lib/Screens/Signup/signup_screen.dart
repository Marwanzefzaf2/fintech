import 'package:flutter/material.dart';
import 'signup_controller.dart';
import 'package:fintech/Screens/Login/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignupController _controller = SignupController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _performSignup() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _controller.signup(
        username: _usernameController.text.trim(),
        context: context,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (mounted) {
        String? message;
        Color messageColor = Colors.red;

        switch (result) {
          case SignupResult.success:
            message = 'Signup Successful! Please Login.';
            messageColor = Colors.green;
            break;
          case SignupResult.passwordMismatch:
            message = 'Passwords do not match.';
            break;
          case SignupResult.weakPassword:
            message = 'Password must be at least 6 characters long.';
            break;
          case SignupResult.emailInUse:
            message = 'This email address is already registered.';
            break;
          case SignupResult.unknownError:
          default:
            message = 'An unknown error occurred. Please try again.';
            break;
        }

        if (message != null) {
          if (result != SignupResult.success) {
            setState(() => _errorMessage = message);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: messageColor),
            );
            _usernameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = 'An unexpected error occurred: ${e.toString()}',
        );
      }
      print("Signup Screen Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          'Join us now!',
          style: TextStyle(
            fontFamily: 'KT Nirma',
            color: Color.fromARGB(255, 233, 126, 20),
            fontWeight: FontWeight.bold,
            fontSize: 30,
            letterSpacing: 0.7,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // This ensures all app bar icons are black
        ),
      ),
      body: Stack(
        children: [
          // Background Images (same as other screens)
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

          // Main Form Content
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
                        'Create your Account',
                        style: TextStyle(
                          fontSize: 22,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.email),
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

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Error Message
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Sign Up Button
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
                          onPressed: _isLoading ? null : _performSignup,
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account!",
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
                              'Login',
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
