import 'package:aura_safe_app/services/contact_service.dart';
import 'package:aura_safe_app/screens/post_incident_screen.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final ContactService _contactService = ContactService();
  List<DocumentSnapshot>? _emergencyContacts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _contactService.getEmergencyContactsList();
      if (mounted) {
        setState(() => _emergencyContacts = contacts);
      }
    } catch (e) {
      print("Error loading emergency contacts: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _triggerSOS() {
    if (_emergencyContacts == null || _emergencyContacts!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add emergency contacts in your profile first.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e1e1e),
          title: const Text('Confirm SOS'),
          content: Text(
              'This will send an alert to your ${_emergencyContacts!.length} emergency contacts.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('CONFIRM', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                print('--- 🚨 SENDING SOS ALERTS 🚨 ---');
                for (var contact in _emergencyContacts!) {
                  final data = contact.data() as Map<String, dynamic>;
                  print('Alerting ${data['name']} at ${data['phone']}...');
                }
                print('---------------------------------');
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PostIncidentScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SOS alerts have been sent!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Alert'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: AvatarGlow(
                  glowColor: Colors.red,
                  endRadius: 150.0,
                  child: GestureDetector(
                    onTap: _triggerSOS,
                    child: const Material(
                      elevation: 8.0,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 80.0,
                        child: Text('SOS',
                            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white24, thickness: 1),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text('Contacts to be alerted:',
                        style: TextStyle(fontSize: 18, color: Colors.white70)),
                  ),
                  _buildContactsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_emergencyContacts == null || _emergencyContacts!.isEmpty) {
      return const Center(child: Text('No contacts found.', style: TextStyle(color: Colors.white54)));
    }
    return Expanded(
      child: ListView.builder(
        itemCount: _emergencyContacts!.length,
        itemBuilder: (context, index) {
          final data = _emergencyContacts![index].data() as Map<String, dynamic>;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LineIcons.userShield, color: Colors.cyanAccent),
            title: Text(data['name']),
            subtitle: Text(data['phone']),
          );
        },
      ),
    );
  }
}