import 'dart:ui';
import 'package:aura_safe_app/screens/contacts_screen.dart';
import 'package:aura_safe_app/screens/edit_profile_screen.dart';
import 'package:aura_safe_app/screens/lock_screen.dart'; // We still need this for the Help Vault
import 'package:aura_safe_app/screens/my_contacts_screen.dart';
import 'package:aura_safe_app/screens/settings_screen.dart';
import 'package:aura_safe_app/screens/voice_assistant_screen.dart';
import 'package:aura_safe_app/screens/voice_sos_screen.dart';
import 'package:aura_safe_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:line_icons/line_icons.dart';
import 'package:aura_safe_app/screens/incident_vault_screen.dart'; // Import Incident Vault
import 'package:aura_safe_app/screens/ai_emotion_screen.dart'; // Import Emotion Screen
import 'package:local_auth/local_auth.dart'; // Import local_auth
import 'package:aura_safe_app/screens/calm_mode_screen.dart';
import 'package:aura_safe_app/screens/journal_screen.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? get _user => FirebaseAuth.instance.currentUser;
  final LocalAuthentication _localAuth = LocalAuthentication(); // Instance for biometric auth

  // --- NEW FUNCTION for Incident Vault Auth ---
  Future<void> _authenticateAndOpenIncidentVault() async {
    bool isAuthenticated = false;
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to access your Incident Vault',
          options: const AuthenticationOptions(
            biometricOnly: true, // Only allow biometric, no PIN
            stickyAuth: true,    // Keep prompt open
          ),
        );
      } else {
        // Handle devices without biometrics (e.g., show passcode screen, or just allow)
        // For this secure feature, we'll assume biometrics are preferred.
        // If you want to support passcodes, you'd need to implement a separate PIN screen.
        // For now, we can show an error or just let them through (less secure).
        // Let's show an error for this example:
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometrics not available on this device.')),
            );
         }
         return; // Don't proceed if biometrics aren't available
      }
    } catch (e) {
      print("Error during biometric auth: $e");
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Authentication error: $e')),
          );
       }
    }

    // If authentication was successful, navigate to the screen
    if (isAuthenticated && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IncidentVaultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LineIcons.userEdit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              ).then((_) {
                setState(() {}); // Rebuild to show updated name
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://i.pinimg.com/originals/c7/a9/50/c7a95049b109b015b81a737a34614a9a.jpg'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: <Widget>[
              const SizedBox(height: 20),
              // --- Profile Picture Section ---
              const Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.cyanAccent,
                  child: Icon(LineIcons.user, size: 70, color: Colors.black),
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: -0.5),

              const SizedBox(height: 15),
              // --- User Info Section ---
              Center(
                child: Text(
                  _user?.displayName ?? 'Aura User',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  _user?.email ?? 'user@example.com',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 40),

              // --- Glass Card for Main Menu Options ---
              _buildGlassCard(
                child: Column(
                  children: [
                    _buildProfileOption(
                      icon: LineIcons.userShield,
                      title: 'Help Vault (Personal Info)',
                      onTap: () {
                        // This one uses its own LockScreen
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LockScreen()));
                      },
                    ),
                    // --- UPDATED INCIDENT VAULT ---
                    _buildProfileOption(
                      icon: LineIcons.archive,
                      title: 'Incident Vault (Evidence)',
                      onTap: _authenticateAndOpenIncidentVault, // Call the auth function
                    ),
                    _buildProfileOption(
                      icon: LineIcons.brain,
                      title: 'AI Emotion Check-in',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AiEmotionScreen()));
                      },
                    ),
                    _buildProfileOption(
                      icon: LineIcons.microphone,
                      title: 'Crisis Voice Assistant',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceAssistantScreen()));
                      },
                    ),
                    _buildProfileOption(
                      icon: LineIcons.microphone,
                      title: 'Voice SOS Setup',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceSosScreen()));
                      },
                    ),
                    _buildProfileOption(
                      icon: LineIcons.heartbeat, // or LineIcons.spa
                      title: 'Calm Mode',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalmModeScreen()));
                      },
                    ),
                    _buildProfileOption(
                        icon: LineIcons.book,
                        title: 'Reflection Journal',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const JournalScreen()));
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Glass Card for Contacts & Settings ---
               _buildGlassCard(
                child: Column(
                  children: [
                     _buildProfileOption(
                      icon: LineIcons.users,
                      title: 'My Emergency Contacts',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyContactsScreen()));
                      },
                    ),
                    _buildProfileOption(
                      icon: LineIcons.userPlus,
                      title: 'Add from Phonebook',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsScreen()));
                      },
                    ),
                    _buildProfileOption(
                      icon: LineIcons.cog,
                      title: 'Settings',
                       onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Glass Card for Sign Out ---
              _buildGlassCard(
                child: _buildProfileOption(
                  icon: LineIcons.alternateSignOut,
                  title: 'Sign Out',
                  color: Colors.redAccent,
                  onTap: () async {
                    await _authService.signOut();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for the glass card effect.
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Helper widget for creating reusable menu options.
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(title, style: TextStyle(color: color ?? Colors.white)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}