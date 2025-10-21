import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aura_safe_app/services/preferences_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// AI Service class to handle Gemini API calls
class AiService {
  final PreferencesService _prefsService = PreferencesService();
  final String _apiBaseUrl = 'https://generativelanguage.googleapis.com';
  final String _apiVersion = 'v1'; // Or 'v1beta' if needed

  /// Sends a prompt to the Gemini API and gets a response using the user's selected model.
  Future<String?> getAiResponse(String userPrompt) async {
    print('🤖 GEMINI API CALLED with prompt: $userPrompt');

    // --- Get API Key from .env file ---
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("❌ Error: Gemini API Key is missing in .env file!");
      return "Sorry, the AI service isn't configured correctly. (Missing API Key)";
    }

    // --- Get selected model dynamically ---
    final String selectedModel = await _prefsService.getSelectedGeminiModel();
    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1/models/$selectedModel:generateContent?key=$apiKey';
    print("🤖 Using model: $selectedModel");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': userPrompt}
              ]
            }
          ],
        }),
      );

      print('📡 Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          final aiResponse = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          print('💬 AI Response: $aiResponse');
          return aiResponse;
        } else {
          print('⚠️ Gemini API Warning: Invalid response structure received.');
          print('Raw Response Body: ${response.body}');
          return 'Sorry, I received an unexpected response from the AI.';
        }
      } else if (response.statusCode == 404) {
        print('❌ Gemini API Error 404: Model Not Found.');
        print('Model used: $selectedModel');
        print('Raw Error Body: ${response.body}');
        return 'Sorry, the selected AI model ($selectedModel) is not available or compatible. Please try another model in Settings. (Code 404)';
      } else if (response.statusCode == 400) {
        print('❌ Gemini API Error 400: Bad Request.');
        print('Raw Error Body: ${response.body}');
        return 'Configuration error with the AI service. (Code 400)';
      } else if (response.statusCode == 403) {
        print('❌ Gemini API Error 403: Permission Denied.');
        print('Raw Error Body: ${response.body}');
        return 'Access denied. Check API Key and permissions. (Code 403)';
      } else if (response.statusCode == 429) {
        print('❌ Gemini API Error 429: Quota Exceeded.');
        print('Raw Error Body: ${response.body}');
        return 'AI service temporarily unavailable due to high usage. (Code 429)';
      } else {
        print('❌ Gemini API Error: ${response.statusCode}');
        print('Raw Error Body: ${response.body}');
        return 'Error communicating with the AI. (Code ${response.statusCode})';
      }
    } catch (e) {
      print('❌ Network or other error calling Gemini API: $e');
      return 'Unexpected network error occurred while contacting the AI.';
    }
  }

  /// Fetches the list of available Gemini models that support generateContent.
  Future<List<String>> listAvailableModels() async {
    // --- Get API Key from .env file ---
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("❌ Error: Gemini API Key is missing in .env file for listing models!");
      return ["Error: API Key missing"];
    }

    final String listModelsUrl = '$_apiBaseUrl/$_apiVersion/models?key=$apiKey';
    print("Fetching available models...");
    try {
      final response = await http.get(Uri.parse(listModelsUrl)); // Use GET request
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<String> availableModels = [];
        if (jsonResponse['models'] != null && jsonResponse['models'] is List) {
          for (var modelData in jsonResponse['models']) {
            // Check if the model supports the 'generateContent' method
            if (modelData['supportedGenerationMethods'] != null &&
                modelData['supportedGenerationMethods'] is List &&
                modelData['supportedGenerationMethods'].contains('generateContent')) {
                  
              // Extract the base model name (e.g., gemini-1.0-pro)
              String fullName = modelData['name'] ?? ''; // e.g., "models/gemini-1.0-pro"
              if (fullName.startsWith('models/')) {
                 availableModels.add(fullName.substring(7)); // Remove "models/" prefix
              }
            }
          }
        }
        print("Available Models: $availableModels");
        return availableModels.isEmpty ? ["No compatible models found"] : availableModels;
      } else {
        // Handle API errors
        print('❌ Error listing models: ${response.statusCode}');
        print('Raw Error Body: ${response.body}');
        return ["Error: ${response.statusCode}"];
      }
    } catch (e) {
      print('❌ Network or other error listing models: $e');
      return ["Error: Network issue"];
    }
  }
}