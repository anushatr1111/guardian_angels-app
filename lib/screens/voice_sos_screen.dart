import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceSosScreen extends StatefulWidget {
  const VoiceSosScreen({super.key});

  @override
  State<VoiceSosScreen> createState() => _VoiceSosScreenState();
}

class _VoiceSosScreenState extends State<VoiceSosScreen> {
  // --- STATE VARIABLES ---
  final RecorderController _waveformController = RecorderController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _statusText = "Initializing...";
  final String _keyword = "help me"; // The keyword to detect

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initializes the speech recognizer.
  void _initSpeech() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _statusText = 'Say "$_keyword" to trigger an alert.';
      });
      _startListening();
    } else {
      setState(() {
        _statusText = 'Speech recognition not available.';
      });
    }
  }

  /// Starts listening to the microphone.
  void _startListening() {
    if (!_isListening) {
      _speechToText.listen(
        onResult: (result) {
          String recognizedWords = result.recognizedWords.toLowerCase();
          print("Heard: $recognizedWords"); // For debugging

          // Check if the recognized text contains our keyword
          if (recognizedWords.contains(_keyword)) {
            _stopListening(); // Stop listening to prevent multiple triggers
            _triggerSOS();
          }
        },
        listenFor: const Duration(minutes: 5), // Listen for a long duration
        onSoundLevelChange: (level) {
          // Update the waveform based on microphone volume
          _waveformController.refresh();
        },
      );
      setState(() => _isListening = true);
    }
  }

  /// Stops listening to the microphone.
  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  /// Triggers the SOS action.
  void _triggerSOS() {
    print("--- 🚨 SOS KEYWORD DETECTED! 🚨 ---");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'SOS Triggered!',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Your keyword "$_keyword" was detected. Sending alerts now.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startListening(); // Resume listening after dismissing
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Voice SOS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isListening ? 'Listening...' : _statusText,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              AudioWaveforms(
                size: Size(MediaQuery.of(context).size.width * 0.8, 100.0),
                recorderController: _waveformController,
                waveStyle: const WaveStyle(
                  waveColor: Colors.white,
                  showMiddleLine: false,
                  spacing: 8.0,
                ),
              ),
              const SizedBox(height: 40),
              AvatarGlow(
                animate: _isListening, // Make the glow animate only when listening
                glowColor: Colors.cyanAccent,
                endRadius: 80.0,
                child: const Material(
                  elevation: 8.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.cyan,
                    radius: 40.0,
                    child: Icon(Icons.mic, size: 40, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Keyword: "$_keyword"',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}