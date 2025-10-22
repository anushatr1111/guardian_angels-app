import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

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
        .orderBy('addedOn', descending: true)
        .snapshots();
  }

  // GET emergency contacts as a list (one-time read)
  Future<List<DocumentSnapshot>> getEmergencyContactsList() async {
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No user is currently logged in.');
    }

    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts')
        .get();

    return querySnapshot.docs;
  }

  // ADD a contact manually (with name and phone)
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

  // PICK contact from device and add to Firebase
  Future<void> pickAndAddContact() async {
    // 1. Request permission to access contacts
    final status = await Permission.contacts.request();

    if (status.isDenied) {
      throw Exception('Contact permission denied. Please enable it in settings.');
    }

    if (status.isPermanentlyDenied) {
      throw Exception('Contact permission permanently denied. Please enable it in app settings.');
    }

    // 2. Pick a contact from device using flutter_native_contact_picker
    final Contact? contact = await _contactPicker.selectContact();

    if (contact == null) {
      // User cancelled the picker
      throw Exception('No contact selected');
    }

    // 3. Extract contact information
    String name = contact.fullName ?? 'Unknown';
    
    // Get the first phone number from the list
    String phone = 'No phone number';
    if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {
      phone = contact.phoneNumbers!.first;
    }

    // Clean up phone number (remove spaces, dashes, etc.)
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // 4. Check if phone number is valid
    if (phone == 'No phone number' || phone.isEmpty) {
      throw Exception('Selected contact has no phone number');
    }

    // 5. Add to Firebase
    await addEmergencyContact(
      name: name,
      phone: phone,
    );
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

  // UPDATE an emergency contact
  Future<void> updateEmergencyContact({
    required String contactId,
    required String name,
    required String phone,
  }) async {
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('No user is currently logged in.');
    }

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts')
        .doc(contactId)
        .update({
      'name': name,
      'phone': phone,
    });
  }

  // CHECK if contact permission is granted
  Future<bool> hasContactPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }

  // OPEN app settings (if permission is permanently denied)
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}