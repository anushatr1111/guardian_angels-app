import 'dart:math'; // For Random
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptics
import 'package:audioplayers/audioplayers.dart'; // For sound
import 'package:vibration/vibration.dart'; // For vibration

class CalmModeScreen extends StatefulWidget {
  const CalmModeScreen({super.key});

  @override
  State<CalmModeScreen> createState() => _CalmModeScreenState();
}

// Use TickerProviderStateMixin for the animation controller
class _CalmModeScreenState extends State<CalmModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _guideText = "Inhale...";

  @override
  void initState() {
    super.initState();

    // --- 23.3: Start Ambient Sound ---
    _startAmbientSound();

    // --- 23.1: Animate Inhale/Exhale ---
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds to inhale
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // --- 23.2: Add Vibration Feedback ---
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _guideText = "Exhale...");
        Vibration.vibrate(duration: 100); // Vibrate on hold/exhale
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _guideText = "Inhale...");
        Vibration.vibrate(duration: 100); // Vibrate on inhale
        _animationController.forward();
      }
    });

    // Start the animation loop
    _animationController.forward();

    // --- 24.1: Show Affirmation Popup ---
    _showAffirmation();
    // --- End 24.1 ---
  }

  /// --- NEW FUNCTION for Step 24.1 ---
  void _showAffirmation() {
    // Waits for the first frame to build before showing SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final affirmations = [
        "I am calm and in control of my feelings.",
        "This feeling is temporary and will pass.",
        "I am safe in this present moment.",
        "I choose to respond with peace.",
        "I am resilient and can get through this.",
      ];
      // Pick a random affirmation
      final randomAffirmation =
          affirmations[Random().nextInt(affirmations.length)];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            randomAffirmation,
            style:
                const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.cyanAccent.withOpacity(0.9),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating, // Floats above bottom nav bar
          margin: const EdgeInsets.all(10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }
  // --- End new function ---

  Future<void> _startAmbientSound() async {
    try {
      // Assumes your file is in assets/sounds/calm_ambient.mp3
      await _audioPlayer.play(AssetSource('sounds/calm_ambient.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the sound
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.stop(); // Stop the sound
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 23.1: Animated Breathing Widget ---
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 60),

            // --- Guide Text ---
            Text(
              _guideText,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}