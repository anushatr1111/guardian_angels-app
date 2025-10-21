import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Keys for SharedPreferences
  static const String _keyLocationSharing = 'locationSharingEnabled';
  static const String _keyCalmMode = 'calmModeEnabled'; // Assuming default is Dark
  static const String _keyNotifications = 'notificationsEnabled';
  static const String _keyGeminiEnabled = 'geminiEnabled';
  static const String _keySelectedGeminiModel = 'selectedGeminiModel';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // --- Location Sharing ---
  Future<bool> isLocationSharingEnabled() async {
    final prefs = await _getPrefs();
    // Default to true if not set
    return prefs.getBool(_keyLocationSharing) ?? true;
  }

  Future<void> setLocationSharingEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyLocationSharing, enabled);
  }

  // --- Calm Mode ---
  Future<bool> isCalmModeEnabled() async {
    final prefs = await _getPrefs();
    // Default to false (Dark mode) if not set
    return prefs.getBool(_keyCalmMode) ?? false;
  }

  Future<void> setCalmModeEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyCalmMode, enabled);
    // TODO: Add logic here to actually change the app's theme
    print("Theme mode changed. Implement theme switching logic.");
  }

  // --- Notifications ---
  Future<bool> areNotificationsEnabled() async {
    final prefs = await _getPrefs();
    // Default to true if not set
    return prefs.getBool(_keyNotifications) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyNotifications, enabled);
    // TODO: Add logic here to enable/disable push notifications
     print("Notification setting changed. Implement notification logic.");
  }
  Future<bool> isGeminiEnabled() async {
    final prefs = await _getPrefs();
    // Default to true for now, can be changed
    return prefs.getBool(_keyGeminiEnabled) ?? true;
  }

  Future<void> setGeminiEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyGeminiEnabled, enabled);
    // TODO: Add logic here to initialize/deactivate Gemini features if needed
    print("Gemini features ${enabled ? 'enabled' : 'disabled'}. Implement actual logic.");
  }
  Future<String> getSelectedGeminiModel() async {
    final prefs = await _getPrefs();
    // Default to the stable model if nothing is selected
    return prefs.getString(_keySelectedGeminiModel) ?? 'gemini-1.0-pro';
  }

  Future<void> setSelectedGeminiModel(String modelName) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keySelectedGeminiModel, modelName);
    print("Selected Gemini model updated to: $modelName");
  }
}