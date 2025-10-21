import 'dart:ui'; // Import this to use the ImageFilter for the blur effect.
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = LineIcons.infoCircle,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    // ClipRRect is used to curve the corners of the blurred background.
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        // This is the widget that creates the frosted glass effect.
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // Use a semi-transparent color for the glass effect.
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            // Add a subtle border to make the edges of the glass pop.
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}