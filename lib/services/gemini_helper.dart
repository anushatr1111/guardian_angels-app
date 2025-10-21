import 'dart:convert'; // Import for jsonEncode/jsonDecode
import 'package:http/http.dart' as http; // Import for http client

// Placeholder for Gemini API integration
// We would typically use a package like 'google_generative_ai' here,
// but this shows how to do it with basic HTTP requests.

class GeminiHelper {
  // ⚠️ IMPORTANT: Replace with your actual API Key
  // You should load this securely in a real app (e.g., from secure storage or env vars)
  static const String _apiKey = "AIzaSyAi5nMfsjdT0jwcrNFGbALjVd40G83uTfk"; // Replace this

  // The endpoint for the specific Gemini model
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey';

  // Placeholder: Initialize the Gemini client (Not strictly needed for HTTP calls)
  Future<void> initializeGemini() async {
    print("Placeholder: Gemini Helper initialized (using HTTP).");
    // If using an SDK, initialization would happen here.
  }

  // --- THIS FUNCTION IS NOW IMPLEMENTED ---
  /// Sends a prompt to the Gemini API and gets a response using HTTP.
  Future<String?> getResponse(String userPrompt) async {
    print("Sending prompt to Gemini via HTTP: '$userPrompt'");

    // Check if API key is set (basic check)
    if (_apiKey == "YOUR_GEMINI_API_KEY" || _apiKey.isEmpty) {
      print("Error: Gemini API Key is not set in gemini_helper.dart");
      return "Error: API Key not configured.";
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl), // <-- Gemini API endpoint
        headers: {'Content-Type': 'application/json'}, // <-- Headers
        body: jsonEncode({ // <-- Body with the message ('userPrompt')
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

      // --- Handle the response ---
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body); // <-- Decode response
        // Extract the generated text safely
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          // <-- Return response text
          return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        } else {
          print('Gemini API Error: Invalid response structure');
          print(response.body); // Print the raw response for debugging
          return 'Sorry, I received an unexpected response from the AI.';
        }
      } else {
        print('Gemini API Error: ${response.statusCode}');
        print(response.body); // Print the raw error response
        return 'Sorry, there was an error communicating with the AI (${response.statusCode}).';
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return 'Sorry, an unexpected error occurred while contacting the AI.';
    }
  }
  // --- END OF IMPLEMENTED FUNCTION ---

  // Placeholder: Securely load API key (Not used in this direct implementation)
  // Future<String?> _loadApiKey() async {
  //   // Implement secure loading mechanism here
  //   return _apiKey; // Example
  // }

  // Simple function to indicate if Gemini features should be active
  // In this HTTP implementation, it mainly depends on the API key being set.
  bool isGeminiEnabled() {
    // Basic check: Is the API key present?
    bool enabled = _apiKey != "YOUR_GEMINI_API_KEY" && _apiKey.isNotEmpty;
    print("Gemini Helper check: Features ${enabled ? 'enabled' : 'disabled (API Key missing?)'}");
    return enabled;
  }
}