import 'dart:convert';
import 'package:aura_safe_app/services/preferences_service.dart'; // Import Preferences
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:http/http.dart' as http;

// AI Service class handles interactions with the Google Generative AI API
class AiService {
  final PreferencesService _prefsService = PreferencesService(); // Service to get user settings
  final String _apiBaseUrl = 'https://generativelanguage.googleapis.com';
  final String _apiVersion = 'v1'; // Using stable v1 API

  /// Sends a prompt to the Gemini API and gets a response using the user's selected model.
  Future<String?> getAiResponse(String userPrompt) async {
    print('🤖 GEMINI API CALLED with prompt: $userPrompt');

    // --- Get API Key from environment ---
    final String? apiKey = dotenv.env['GEMINI_API_KEY']; // Access the key loaded in main.dart

    // --- API Key Check ---
    if (apiKey == null || apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
      print("❌ Error: GEMINI_API_KEY not found in .env file or is still placeholder!");
      return "Sorry, the AI service isn't configured correctly. (Missing API Key)";
    }
    // --- End Check ---

    // --- Get selected model dynamically ---
    final String selectedModel = await _prefsService.getSelectedGeminiModel();
    final String apiUrl = '$_apiBaseUrl/$_apiVersion/models/$selectedModel:generateContent?key=$apiKey';
    print("🤖 Using model: $selectedModel");

    try {
      final response = await http.post(
        Uri.parse(apiUrl), // Use dynamically constructed URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Structure the request body as required by the Gemini API
          'contents': [
            {
              'parts': [
                {'text': userPrompt}
              ]
            }
          ],
          // Optional: Add safety settings if needed
          // 'safetySettings': [ ... ]
        }),
      );

      print('📡 Response Status Code: ${response.statusCode}');

      // --- Handle the response ---
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Safely extract the generated text from the response
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
          print('❌ Gemini API Error 404: Model Not Found or Not Supported for this method/version.');
          print('Model used: $selectedModel, API Version: $_apiVersion');
          print('Raw Error Body: ${response.body}');
          return 'Sorry, the selected AI model ($selectedModel) is not available or compatible. Please try another model in Settings. (Code 404)';
      } else if (response.statusCode == 400) {
        print('❌ Gemini API Error 400: Bad Request. Check API key restrictions or API enablement.');
        print('Raw Error Body: ${response.body}');
        return 'Sorry, there was a configuration error with the AI service. (Code 400)';
      } else if (response.statusCode == 403) {
        print('❌ Gemini API Error 403: Permission Denied. Check API Key validity and ensure "Generative Language API" is enabled.');
        print('Raw Error Body: ${response.body}');
        return 'Sorry, access to the AI service was denied. Please check configuration. (Code 403)';
      } else if (response.statusCode == 429) {
        print('❌ Gemini API Error 429: Quota Exceeded. You might be making too many requests.');
        print('Raw Error Body: ${response.body}');
        return 'Sorry, the AI service is temporarily unavailable due to high usage. Please try again later. (Code 429)';
      } else {
        // Handle other non-200 status codes
        print('❌ Gemini API Error: ${response.statusCode}');
        print('Raw Error Body: ${response.body}');
        return 'Sorry, there was an error communicating with the AI. (Code ${response.statusCode})';
      }
    } catch (e) {
      print('❌ Network or other error calling Gemini API: $e');
      return 'Sorry, an unexpected network error occurred while contacting the AI.';
    }
  }

  /// Fetches the list of available Gemini models that support generateContent.
  Future<List<String>> listAvailableModels() async {
    // --- Get API Key from environment ---
    final String? apiKey = dotenv.env['GEMINI_API_KEY']; // Access the key

    // --- API Key Check ---
    if (apiKey == null || apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
      print("❌ Error: GEMINI_API_KEY not found in .env file for listing models!");
      return ["Error: API Key missing"]; // Return error indication
    }
    // --- End Check ---

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
        print("✅ Available Models: $availableModels");
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