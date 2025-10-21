import 'package:aura_safe_app/services/contact_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class MyContactsScreen extends StatefulWidget {
  const MyContactsScreen({super.key});

  @override
  State<MyContactsScreen> createState() => _MyContactsScreenState();
}

class _MyContactsScreenState extends State<MyContactsScreen> {
  final ContactService _contactService = ContactService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Emergency Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _contactService.getEmergencyContactsStream(),
        builder: (context, snapshot) {
          // 1. Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle error state
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          // 3. Handle empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have not added any emergency contacts yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          // 4. Display the list of contacts
          final contacts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final contactData = contact.data() as Map<String, dynamic>;
              final contactId = contact.id; // Get the document ID for deleting

              return ListTile(
                leading: const Icon(LineIcons.userShield, color: Colors.cyanAccent, size: 30),
                title: Text(contactData['name']),
                subtitle: Text(contactData['phone'], style: const TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    await _contactService.deleteEmergencyContact(contactId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${contactData['name']} removed.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}