import 'dart:ui';
import 'package:aura_safe_app/services/contact_service.dart'; // Import the new service
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact>? _contacts;
  bool _isLoading = true;
  final ContactService _contactService = ContactService(); // Instance of the service

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        final contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
        setState(() => _contacts = contacts);
      } catch (e) {
        print("Error fetching contacts: $e");
      }
    } else {
      print("Contacts permission denied.");
      if (mounted) {
        _showFeedbackSnackBar('Permission denied. Cannot fetch contacts.', isError: true);
      }
    }
    setState(() => _isLoading = false);
  }

  // --- LOGIC TO ADD CONTACT TO FIRESTORE ---
  Future<void> _addContactToFirebase(Contact contact) async {
    final String displayName = contact.displayName;
    final String phoneNumber = contact.phones.first.number;

    try {
      await _contactService.addEmergencyContact(name: displayName, phone: phoneNumber);
      _showFeedbackSnackBar('$displayName has been added to your emergency contacts.');
    } catch (e) {
      _showFeedbackSnackBar(e.toString(), isError: true);
    }
  }

  // Helper for showing feedback
  void _showFeedbackSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Emergency Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }
    if (_contacts == null || _contacts!.isEmpty) {
      return const Center(child: Text('No contacts found.', style: TextStyle(fontSize: 18)));
    }
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, index) {
        final contact = _contacts![index];
        final phoneNumber = contact.phones.isNotEmpty ? contact.phones.first.number : 'No number';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            child: Text(contact.displayName.isNotEmpty ? contact.displayName[0] : '',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          title: Text(contact.displayName),
          subtitle: Text(phoneNumber, style: const TextStyle(color: Colors.white70)),
          trailing: _buildAddButton(contact),
        );
      },
    );
  }

  Widget _buildAddButton(Contact contact) {
    if (contact.phones.isEmpty) {
      return const SizedBox.shrink();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: InkWell(
          onTap: () => _addContactToFirebase(contact), // Call the new function
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: const Icon(Icons.add, color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}