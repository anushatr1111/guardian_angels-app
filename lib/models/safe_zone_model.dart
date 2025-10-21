import 'package:cloud_firestore/cloud_firestore.dart';

class SafeZone {
  final String id; // Document ID from Firestore
  final String name;
  final GeoPoint center; // Latitude and Longitude
  final double radius; // Radius in meters

  SafeZone({
    required this.id,
    required this.name,
    required this.center,
    required this.radius,
  });

  // Factory constructor to create a SafeZone from a Firestore document
  factory SafeZone.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SafeZone(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Zone',
      center: data['center'] ?? const GeoPoint(0, 0), // Default to (0,0) if missing
      radius: (data['radius'] ?? 100.0).toDouble(), // Default to 100m if missing
    );
  }

  // Method to convert a SafeZone object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'center': center,
      'radius': radius,
    };
  }
}