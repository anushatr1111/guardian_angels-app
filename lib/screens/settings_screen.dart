import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:aura_safe_app/services/preferences_service.dart';
import 'package:aura_safe_app/services/ai_service.dart'; // Import AiService

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefsService = PreferencesService();
  final AiService _aiService = AiService(); // Add AiService instance

  // State variables for toggles
  bool _locationSharingEnabled = true;
  bool _calmModeEnabled = false;
  bool _notificationsEnabled = true;
  bool _geminiEnabled = true;
  String _selectedModel = 'gemini-1.0-pro'; // Default model
  List<String> _availableModels = ['gemini-1.0-pro']; // Start with default
  bool _isLoading = true; // Loading state
  bool _modelsLoaded = false; // Track if models have been fetched

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load current settings from SharedPreferences and fetch available models
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    // Load saved preferences first
    _locationSharingEnabled = await _prefsService.isLocationSharingEnabled();
    _calmModeEnabled = await _prefsService.isCalmModeEnabled();
    _notificationsEnabled = await _prefsService.areNotificationsEnabled();
    _geminiEnabled = await _prefsService.isGeminiEnabled();
    _selectedModel = await _prefsService.getSelectedGeminiModel();

    // Then fetch the available models from the API
    List<String> fetchedModels = await _aiService.listAvailableModels();
    if (fetchedModels.isNotEmpty && !fetchedModels[0].startsWith("Error:")) {
      // Make sure the currently selected model is in the fetched list
      // If not, default to the first available one
      if (!fetchedModels.contains(_selectedModel)) {
        _selectedModel = fetchedModels[0];
        await _prefsService.setSelectedGeminiModel(_selectedModel); // Save the valid default
      }
      _availableModels = fetchedModels;
      _modelsLoaded = true;
    } else {
      // Handle case where fetching models failed
      _availableModels = [_selectedModel]; // Keep the saved/default model
      _modelsLoaded = false; // Indicate models couldn't be loaded
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not fetch available AI models: ${fetchedModels.isNotEmpty ? fetchedModels[0] : "Unknown Error"}'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              children: [
                _buildSwitchTile(
                  title: 'Enable Location Sharing',
                  subtitle: 'Allow trusted contacts to see your live location.',
                  icon: LineIcons.mapMarker,
                  value: _locationSharingEnabled,
                  onChanged: (newValue) async {
                    await _prefsService.setLocationSharingEnabled(newValue);
                    setState(() => _locationSharingEnabled = newValue);
                    // TODO: Add logic to actually start/stop sharing
                  },
                ),
                _buildSwitchTile(
                  title: 'Calm Mode Theme',
                  subtitle: 'Use a lighter, calmer color scheme.',
                  icon: LineIcons.moon, // Or LineIcons.sun if Calm is active
                  value: _calmModeEnabled,
                  onChanged: (newValue) async {
                    await _prefsService.setCalmModeEnabled(newValue);
                    setState(() => _calmModeEnabled = newValue);
                    // The service already prints a TODO for theme switching
                  },
                ),
                _buildSwitchTile(
                  title: 'Enable Notifications',
                  subtitle: 'Receive alerts and updates from the app.',
                  icon: LineIcons.bell,
                  value: _notificationsEnabled,
                  onChanged: (newValue) async {
                    await _prefsService.setNotificationsEnabled(newValue);
                    setState(() => _notificationsEnabled = newValue);
                    // The service already prints a TODO for notification logic
                  },
                ),
                _buildSwitchTile(
                  title: 'Enable Gemini Features',
                  subtitle: 'Allow use of generative AI for assistance.',
                  icon: LineIcons.brain, // Brain icon for AI
                  value: _geminiEnabled,
                  onChanged: (newValue) async {
                    await _prefsService.setGeminiEnabled(newValue);
                    setState(() => _geminiEnabled = newValue);
                  },
                ),
                
                // AI Model Selection Section
                const Divider(height: 20),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 16.0),
                  child: Text(
                    "AI Chatbot Model",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                
                // Model Selection Dropdown (Updated with dynamic models)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedModel,
                    // Use the dynamically fetched list
                    items: _availableModels.map((String model) {
                      return DropdownMenuItem<String>(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                    onChanged: !_modelsLoaded ? null : (String? newValue) async { // Disable if models didn't load
                      if (newValue != null) {
                        await _prefsService.setSelectedGeminiModel(newValue);
                        setState(() {
                          _selectedModel = newValue;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    ),
                    dropdownColor: const Color(0xFF1e1e1e), // Dark dropdown background
                    // Show a message if models couldn't be loaded
                    disabledHint: !_modelsLoaded ? const Text("Could not load models") : null,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }

  // Helper widget for consistent SwitchListTile styling
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive( // adaptive makes it look native on iOS/Android
      secondary: Icon(icon, color: Colors.cyanAccent),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.cyanAccent,
    );
  }
}