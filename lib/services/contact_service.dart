import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET the stream of emergency contacts
  Stream<QuerySnapshot> getEmergencyContactsStream() {
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No user is currently logged in.');
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts')
        .orderBy('addedOn', descending: true) // Show newest contacts first
        .snapshots(); // This returns a real-time stream
  }

  // ADD a contact (this function is from the previous step)
  Future<void> addEmergencyContact({
    required String name,
    required String phone,
  }) async {
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No user is currently logged in.');
    }

    final CollectionReference emergencyContacts = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts');

    await emergencyContacts.add({
      'name': name,
      'phone': phone,
      'addedOn': Timestamp.now(),
    });
  }

  // DELETE an emergency contact
  Future<void> deleteEmergencyContact(String contactId) async {
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No user is currently logged in.');
    }

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts')
        .doc(contactId)
        .delete();
  }
  Future<List<DocumentSnapshot>> getEmergencyContactsList() async {
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No user is currently logged in.');
    }

    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts')
        .get(); // .get() performs a one-time read from the database

    return querySnapshot.docs;
  }
}