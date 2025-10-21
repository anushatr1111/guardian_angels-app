import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart'; // 📍 For getting current location
import 'package:aura_safe_app/widgets/alert_card.dart';
import 'package:aura_safe_app/screens/safe_zones_screen.dart';
import 'package:aura_safe_app/screens/post_incident_screen.dart';

// 🧭 HomeScreen shows Safe Zone, Post-Incident, and current location
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationData? _currentLocation; // Stores current GPS coordinates
  final Location _locationController = Location(); // Location handler

  @override
  void initState() {
    super.initState();
    _getLocation(); // Fetch location when screen opens
  }

  // 📍 Get current location safely with permission checks
  Future<void> _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    try {
      final locationData = await _locationController.getLocation();
      if (mounted) {
        setState(() {
          _currentLocation = locationData;
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // 🧱 Build main UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://i.pinimg.com/originals/c7/a9/50/c7a95049b109b015b81a737a34614a9a.jpg',
            ),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧍‍♀️ Greeting
                const Text(
                  'Hello,',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text('Stay safe today.',
                    style: TextStyle(fontSize: 20, color: Colors.white70)),
                const SizedBox(height: 30),

                // 🎯 Action cards (Safe Zones & Post-Incident)
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: LineIcons.mapMarked,
                        title: 'Safe Zones',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SafeZonesScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: LineIcons.firstAid,
                        title: 'Post-Incident',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PostIncidentScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // ⚠️ Example alert (static)
                const AlertCard(
                  title: 'Location Sharing Active',
                  message: 'Sharing with 1 contact.',
                  icon: LineIcons.mapMarker,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 20),

                // 📍 Live location indicator
                _buildLocationIndicator(),

                const Spacer(), // Pushes location to bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧊 Small blurred card for displaying location
  Widget _buildLocationIndicator() {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            const Icon(LineIcons.locationArrow, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentLocation != null
                    ? 'Lat: ${_currentLocation!.latitude?.toStringAsFixed(4)}, '
                      'Lon: ${_currentLocation!.longitude?.toStringAsFixed(4)}'
                    : 'Fetching location...',
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💠 Reusable glass effect card
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }

  // 🎴 Reusable Action Card (Safe Zones / Post-Incident)
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.cyanAccent, size: 40),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
