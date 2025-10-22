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
  bool _isLoading = false;

  // Function to pick and add contact from device
  Future<void> _pickContact() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _contactService.pickAndAddContact();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Contact added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to add contact';
        
        if (e.toString().contains('permission denied')) {
          errorMessage = 'Permission denied. Please allow contact access in settings.';
        } else if (e.toString().contains('No contact selected')) {
          errorMessage = 'No contact selected';
        } else if (e.toString().contains('no phone number')) {
          errorMessage = 'Selected contact has no phone number';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
            action: e.toString().contains('permanently denied')
                ? SnackBarAction(
                    label: 'Settings',
                    textColor: Colors.white,
                    onPressed: () {
                      _contactService.openAppSettings();
                    },
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Function to delete contact with confirmation
  Future<void> _deleteContact(String contactId, String contactName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to remove "$contactName" from emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _contactService.deleteEmergencyContact(contactId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$contactName removed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete contact: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Emergency Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Info button to show instructions
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Emergency Contacts'),
                  content: const Text(
                    'Add trusted contacts who will be notified in case of emergency. '
                    'Tap the + button to select contacts from your phone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _contactService.getEmergencyContactsStream(),
            builder: (context, snapshot) {
              // 1. Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Handle error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Something went wrong.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // 3. Handle empty state
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LineIcons.userShield,
                        size: 100,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Emergency Contacts',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Add trusted contacts who will be notified in emergencies',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickContact,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 4. Display the list of contacts
              final contacts = snapshot.data!.docs;

              return ListView.builder(
                itemCount: contacts.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final contactData = contact.data() as Map<String, dynamic>;
                  final contactId = contact.id;
                  final name = contactData['name'] ?? 'Unknown';
                  final phone = contactData['phone'] ?? 'No phone';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                        child: const Icon(
                          LineIcons.userShield,
                          color: Colors.cyanAccent,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        phone,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteContact(contactId, name),
                        tooltip: 'Remove contact',
                      ),
                    ),
                  );
                },
              );
            },
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.cyanAccent,
                ),
              ),
            ),
        ],
      ),
      
      // Floating action button to add contacts
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _pickContact,
        backgroundColor: _isLoading ? Colors.grey : Colors.cyanAccent,
        foregroundColor: Colors.black,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.person_add),
        label: Text(_isLoading ? 'Adding...' : 'Add Contact'),
      ),
    );
  }
}