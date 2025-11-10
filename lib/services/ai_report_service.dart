import 'dart:convert';
import 'package:aura_safe_app/services/preferences_service.dart'; // To get the selected model
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting the current date

class AiReportService {
  final PreferencesService _prefsService = PreferencesService();
  final String _apiBaseUrl = 'https://generativelanguage.googleapis.com';
  final String _apiVersion = 'v1';

  /// Takes raw user text and generates a formatted incident report using Gemini.
  Future<String> generateReport(String rawText) async {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return "Error: AI Service is not configured (API Key missing).";
    }

    final String selectedModel = await _prefsService.getSelectedGeminiModel();
    final String apiUrl = '$_apiBaseUrl/$_apiVersion/models/$selectedModel:generateContent?key=$apiKey';

    // --- Create a detailed prompt for the AI ---
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String prompt = """
    You are an AI assistant helping a user write a formal incident report. 
    The user provided the following unstructured text describing what happened:
    "$rawText"

    Based *only* on the text provided, generate a structured report. 
    Use the following format. If information for a field is not available in the text, write 'N/A'.
    Do not add any information that wasn't provided.

    Incident Report
    ---------------------------------
    Date of Report: $currentDate
    Incident Date: (Infer from text, otherwise N/A)
    Incident Time: (Infer from text, otherwise N/A)
    Location: (Infer from text, otherwise N/A)

    Summary:
    (Write a brief, objective summary of the event based on the user's text.)

    Involved Parties:
    (List any people, vehicles, or entities mentioned, otherwise N/A.)

    Detailed Timeline / Sequence of Events:
    (Provide a bulleted or numbered list of events as described, otherwise N/A.)

    Additional Notes:
    (Include any other details provided by the user, otherwise N/A.)
    """;
    // --- End of prompt ---

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Safely extract the generated text
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return "Error: AI returned an invalid response structure.";
        }
      } else {
        // Return the API error message
        print('AI Report Service Error: ${response.statusCode}, ${response.body}');
        return "Error: Failed to generate report (Code: ${response.statusCode}).";
      }
    } catch (e) {
      print('AI Report Service Exception: $e');
      return "Error: An exception occurred while contacting the AI.";
    }
  }
}