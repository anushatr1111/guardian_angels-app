import 'package:aura_safe_app/main.dart';
import 'package:aura_safe_app/screens/login_screen.dart';
import 'package:aura_safe_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We get an instance of our AuthService to access the user stream.
    final AuthService authService = AuthService();

    // StreamBuilder listens to the stream and rebuilds the UI whenever new data arrives.
    return StreamBuilder<User?>(
      stream: authService.user, // This is the stream that tells us if the user is logged in.
      builder: (context, snapshot) {
        // 1. While the stream is connecting, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          );
        }

        // 2. If the snapshot has data, it means the user is logged in.
        if (snapshot.hasData) {
          return const MainScreen(); // Show the main app screen.
        }

        // 3. If the snapshot has no data, the user is not logged in.
        else {
          return const LoginScreen(); // Show the login screen.
        }
      },
    );
  }
}