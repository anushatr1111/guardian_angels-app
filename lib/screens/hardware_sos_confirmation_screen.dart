import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class HardwareSosConfirmationScreen extends StatefulWidget {
  const HardwareSosConfirmationScreen({super.key});

  @override
  State<HardwareSosConfirmationScreen> createState() =>
      _HardwareSosConfirmationScreenState();
}

class _HardwareSosConfirmationScreenState
    extends State<HardwareSosConfirmationScreen> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    // Provide haptic feedback on start
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _triggerSOS();
      }
    });
  }

  void _cancelSOS() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  void _triggerSOS() {
    print("--- 🚨 HARDWARE SOS TRIGGERED AND CONFIRMED! 🚨 ---");
    // Replace the pop with a navigation to a "Help is on the way" screen
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS alerts have been sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'SOS ACTIVATED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _countdown / 5.0,
                      strokeWidth: 10,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _cancelSOS,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  shape: const StadiumBorder(),
                ),
                child:
                    const Text('CANCEL', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}