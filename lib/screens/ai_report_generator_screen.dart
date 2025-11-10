import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:aura_safe_app/widgets/animated_button.dart';
import 'package:aura_safe_app/services/ai_report_service.dart'; // Import the report generator service
import 'package:aura_safe_app/utils/report_utils.dart'; // Import the export utils

class AiReportGeneratorScreen extends StatefulWidget {
  const AiReportGeneratorScreen({super.key});

  @override
  State<AiReportGeneratorScreen> createState() => _AiReportGeneratorScreenState();
}

class _AiReportGeneratorScreenState extends State<AiReportGeneratorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  
  String _generatedReport = ""; // To store the AI's formatted report
  bool _isLoading = false; // For the 'Generate' button
  bool _isListening = false; // For the microphone button
  
  // Initialize services
  final AiReportService _aiReportService = AiReportService();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialize the speech-to-text plugin
  void _initSpeech() async {
    await _speechToText.initialize();
  }

  /// --- 21.1: Capture Voice Input ---
  void _startVoiceInput() async {
    if (await _speechToText.initialize()) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          _inputController.text = result.recognizedWords; // Update text field live
          if (result.finalResult) {
            setState(() => _isListening = false);
          }
        },
      );
    } else {
      print("Speech recognition not available");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available.')),
      );
    }
  }

  /// Stop listening to voice input
  void _stopVoiceInput() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  /// --- 21.2: Generate Formatted Report ---
  Future<void> _generateReport() async {
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe what happened.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedReport = ""; // Clear old report
    });

    // --- Call the AI Report Service ---
    String report = await _aiReportService.generateReport(_inputController.text.trim());
    // --- End ---

    setState(() {
      _generatedReport = report; // Display the result from the AI
      _isLoading = false;
    });
  }

  /// --- 21.3: Export PDF ---
  void _exportPdf() {
    if (_generatedReport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please generate a report first.')),
      );
      return;
    }
    
    // Call the correct utility function for AI-generated text
    ReportUtils.generateAndSharePdfFromText(
      context: context,
      generatedReportText: _generatedReport,
    );
  }
  
  /// --- 21.3: Send Email ---
  void _sendEmail() {
     if (_generatedReport.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please generate a report first.')),
      );
      return;
    }
    
    // For testing, hardcode a recipient.
    // In a real app, you'd get this from user input or storage.
    const String testRecipientEmail = "test@example.com"; // REPLACE with your test email

    // Call the correct utility function for AI-generated text
    ReportUtils.sendEmailWithReportText(
      context: context,
      recipientEmail: testRecipientEmail,
      generatedReportText: _generatedReport,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Report Generator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 21.1: Capture Text/Voice Input ---
            Text(
              _isListening ? "Listening... Speak now." : "Describe what happened...",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _inputController,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'Speak or type all the details you remember...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(_isListening ? Icons.stop_circle_outlined : LineIcons.microphone),
                color: _isListening ? Colors.redAccent : Colors.cyanAccent,
                iconSize: 35,
                tooltip: _isListening ? "Stop Listening" : "Start Voice Input",
                onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
              ),
            ),
            const SizedBox(height: 20),

            // --- 21.2: Generate Report Button ---
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              AnimatedButton(
                text: 'Generate Formatted Report',
                onTap: _generateReport,
              ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),

            // --- 21.3: Display & Export Area ---
            if (_generatedReport.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generated Report:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      _generatedReport, // This now shows the real AI response
                      style: const TextStyle(height: 1.5, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(LineIcons.pdfFile),
                        label: const Text('Export PDF'),
                        onPressed: _exportPdf, // Linked to the correct function
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(LineIcons.paperPlane),
                        label: const Text('Send Email'),
                        onPressed: _sendEmail, // Linked to the correct function
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      ),
                    ],
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}