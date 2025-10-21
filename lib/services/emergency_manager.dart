import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart'; // Import for BuildContext
import 'package:flutter/foundation.dart' show kDebugMode; // Import for debug print
import 'package:location/location.dart'; // Import location
import 'package:cloud_firestore/cloud_firestore.dart'; // Import firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import auth

class EmergencyManager {
  final Location _locationController = Location();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- NEW: Function to get the last known location ---
  Future<String?> _getLastKnownLocationString() async {
    try {
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) return "Location service disabled.";
      }

      PermissionStatus permissionGranted = await _locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return "Location permission denied.";
      }

      final locationData = await _locationController.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        // You could optionally use a geocoding package here to get an address
        return "Lat: ${locationData.latitude!.toStringAsFixed(4)}, Lon: ${locationData.longitude!.toStringAsFixed(4)}";
      } else {
        return "Could not fetch location.";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
      return "Error fetching location.";
    }
  }

  // --- NEW: Function to get the primary emergency contact ---
  Future<String?> _getPrimaryContactNumber() async {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return null;

    try {
      // Fetch the first contact added (ordered by 'addedOn')
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contacts')
          .orderBy('addedOn', descending: false) // Get the oldest first
          .limit(1) // Only fetch one
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return data['phone'] as String?;
      } else {
        return null; // No contacts found
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching primary contact: $e");
      }
      return null;
    }
  }

  // --- UPDATED: Sends SMS using fetched contact and location ---
  Future<void> sendSosMessageToPrimaryContact(BuildContext context) async {
    // Fetch the primary contact number and location concurrently
    final results = await Future.wait([
      _getPrimaryContactNumber(),
      _getLastKnownLocationString(),
    ]);

    final String? recipientNumber = results[0] as String?;
    final String lastKnownLocation = (results[1] as String?) ?? "Location not available";

    if (recipientNumber == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
            content: Text('No emergency contact found. Please add one in your profile.'),
            backgroundColor: Colors.orangeAccent,
         ),
       );
       return;
    }

    String message = "Emergency! I need help. My last known location is approximately: $lastKnownLocation";

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: recipientNumber,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch SMS app.')),
        );
         if (kDebugMode) {
           print('Could not launch $smsUri');
        }
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error launching SMS: $e')),
       );
    }
  }
}