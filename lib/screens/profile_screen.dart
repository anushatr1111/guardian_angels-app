import 'dart:ui';
import 'package:aura_safe_app/screens/contacts_screen.dart';
import 'package:aura_safe_app/screens/edit_profile_screen.dart';
import 'package:aura_safe_app/screens/lock_screen.dart';
import 'package:aura_safe_app/screens/my_contacts_screen.dart';
import 'package:aura_safe_app/screens/settings_screen.dart';
import 'package:aura_safe_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:line_icons/line_icons.dart';
import 'package:aura_safe_app/screens/voice_sos_screen.dart';
import 'package:aura_safe_app/screens/ai_assistant_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  // Get the current user directly, it will be up-to-date after setState is called.
  User? get _user => FirebaseAuth.instance.currentUser;

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
                // This rebuilds the screen to show the updated name when we return.
                setState(() {});
              });
            },
          ),
        ],
      ),
      // Use a Container with a BoxDecoration for the background
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
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: -0.5, curve: Curves.easeInOut),

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
                      title: 'Help Vault',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LockScreen()));
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
                      icon: LineIcons.users,
                      title: 'My Emergency Contacts',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyContactsScreen()));
                      },
                    ),
                    _buildProfileOption(
        icon: LineIcons.robot,
        title: 'Safe-Situation AI',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AiAssistantScreen()));
        },
      ),
                    _buildProfileOption(
                      icon: LineIcons.cog,
                      title: 'Settings',
                      onTap: () {
                        Navigator.push(
                      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
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