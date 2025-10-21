import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_safe_app/models/safe_zone_model.dart'; // Import the model

class SafeZoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the current user's safe zones collection reference
  CollectionReference? _getSafeZonesCollection() {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('Error: No user logged in.');
      return null;
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('safe_zones');
  }

  // Get a stream of safe zones for the current user
  Stream<List<SafeZone>> getSafeZonesStream() {
    final collectionRef = _getSafeZonesCollection();
    if (collectionRef == null) {
      return Stream.value([]); // Return empty stream if no user
    }

    return collectionRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SafeZone.fromFirestore(doc)).toList();
    });
  }

  // Add a new safe zone
  Future<void> addSafeZone({
    required String name,
    required GeoPoint center,
    required double radius,
  }) async {
    final collectionRef = _getSafeZonesCollection();
    if (collectionRef != null) {
      await collectionRef.add({
        'name': name,
        'center': center,
        'radius': radius,
        'createdAt': Timestamp.now(), // Optional: timestamp
      });
    }
  }

  // Update an existing safe zone
  Future<void> updateSafeZone(SafeZone zone) async {
    final collectionRef = _getSafeZonesCollection();
    if (collectionRef != null) {
      await collectionRef.doc(zone.id).update(zone.toFirestore());
    }
  }

  // Delete a safe zone
  Future<void> deleteSafeZone(String zoneId) async {
    final collectionRef = _getSafeZonesCollection();
    if (collectionRef != null) {
      await collectionRef.doc(zoneId).delete();
    }
  }
}