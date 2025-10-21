import 'package:aura_safe_app/screens/vault_screen.dart';
import 'package:aura_safe_app/widgets/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _authenticate() async {
    bool isAuthenticated = false;
    try {
      // Check if biometrics are available on the device
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        _showFeedbackDialog(isSuccess: false, message: 'Biometrics not available.');
        return;
      }

      // Trigger the biometric authentication prompt
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your Help Vault',
        options: const AuthenticationOptions(
          biometricOnly: true, // Only allow biometric, no PIN
          stickyAuth: true, // Keep the prompt open until success or failure
        ),
      );
    } catch (e) {
      print("Error during authentication: $e");
      _showFeedbackDialog(isSuccess: false, message: 'An error occurred.');
    }

    if (mounted) {
      if (isAuthenticated) {
        _showFeedbackDialog(isSuccess: true, message: 'Unlocked');
        // Wait for the animation to finish then navigate
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const VaultScreen()),
        );
      } else {
        _showFeedbackDialog(isSuccess: false, message: 'Authentication Failed');
      }
    }
  }

  void _showFeedbackDialog({required bool isSuccess, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              isSuccess ? 'assets/animations/unlock_success.json' : 'assets/animations/fingerprint.json', // Or a fail animation
              repeat: false,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B0D2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'Vault is Locked',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Authenticate to continue',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 50),
                  Lottie.asset(
                    'assets/animations/fingerprint.json',
                    width: 150,
                    height: 150,
                  ),
                  const Spacer(),
                  AnimatedButton(
                    text: 'Authenticate to Unlock',
                    onTap: _authenticate,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}