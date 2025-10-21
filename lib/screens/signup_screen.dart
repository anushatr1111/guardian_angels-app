import 'package:aura_safe_app/main.dart';
import 'package:aura_safe_app/services/auth_service.dart'; // Import AuthService
import 'package:aura_safe_app/widgets/animated_button.dart';
import 'package:aura_safe_app/widgets/glass_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuthException
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Create instance of AuthService
  bool _isLoading = false;

  // --- Signup Logic ---
  Future<void> _signupUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
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
                  const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Get started with your account', style: TextStyle(fontSize: 18, color: Colors.white70)),
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
                      text: 'Sign Up',
                      onTap: _signupUser, // Call the signup function
                    ),
                  const SizedBox(height: 30),

                  // ... (navigation to login screen is the same)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Login', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
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