import 'package:aura_safe_app/main.dart';
import 'package:aura_safe_app/screens/signup_screen.dart';
import 'package:aura_safe_app/services/auth_service.dart'; // Import AuthService
import 'package:aura_safe_app/widgets/animated_button.dart';
import 'package:aura_safe_app/widgets/glass_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuthException
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Create instance of AuthService
  bool _isLoading = false;

  // --- Login Logic ---
  Future<void> _loginUser() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        // Navigate to the main app screen on successful login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Show specific error message from Firebase
      _showErrorSnackBar(e.message ?? 'An error occurred.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Helper to show a SnackBar ---
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ... (decoration code is the same)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF2A0D2A),
              Color(0xFF1B0D2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Welcome Back', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Sign in to continue', style: TextStyle(fontSize: 18, color: Colors.white70)),
                  const SizedBox(height: 50),
                  GlassTextField(controller: _emailController, hintText: 'Email', icon: LineIcons.envelope),
                  const SizedBox(height: 20),
                  GlassTextField(controller: _passwordController, hintText: 'Password', icon: LineIcons.lock, isPassword: true),
                  const SizedBox(height: 40),

                  // Show a loading indicator or the button
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.cyanAccent)
                  else
                    AnimatedButton(
                      text: 'Login',
                      onTap: _loginUser, // Call the login function
                    ),
                  const SizedBox(height: 30),

                  // ... (navigation to signup screen is the same)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}