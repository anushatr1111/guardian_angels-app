import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:line_icons/line_icons.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:url_launcher/url_launcher.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();

  String _assistantText = "Initializing...";
  String _userSpokenText = "Tap the mic to speak";
  bool _isListening = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAssistant();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  /// Initializes both TTS and Speech Recognition
  Future<void> _initializeAssistant() async {
    // Init TTS
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    // Init Speech Recognition
    bool available = await _speechToText.initialize();

    if (available) {
      setState(() => _isInitialized = true);
      // Start the conversation
      _speak("This is your crisis assistant. Please say 'Call' to contact emergency services, or 'Calm' for a guided exercise.");
    } else {
      setState(() => _assistantText = "Speech recognition is not available on this device.");
    }

    // Set up TTS completion handler to automatically start listening
    _flutterTts.setCompletionHandler(() {
      if (mounted) _startListening();
    });
  }

  /// Speaks the given text using TTS
  Future<void> _speak(String text) async {
    setState(() {
      _assistantText = text;
      _userSpokenText = ""; // Clear user text when assistant speaks
    });
    await _flutterTts.speak(text);
  }

  /// Starts listening for a user's voice command
  void _startListening() {
    if (!_isInitialized || _speechToText.isListening) return;

    setState(() {
      _isListening = true;
      _userSpokenText = "Listening...";
    });

    _speechToText.listen(
      onResult: (result) {
        setState(() => _userSpokenText = result.recognizedWords);
        if (result.finalResult) {
          // User finished speaking, process the command
          _processCommand(result.recognizedWords.toLowerCase());
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
    );
  }

  /// Stops listening
  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  /// Processes the user's spoken command
  void _processCommand(String command) {
    setState(() => _isListening = false);

    if (command.contains("call")) {
      // --- Action: Call Emergency ---
      _speak("Calling emergency services now.");
      _callEmergency();
    } else if (command.contains("calm")) {
      // --- Action: Calm ---
      _speak("Okay, let's take a deep breath. A full breathing exercise will be here soon.");
      // TODO: Navigator.push(context, MaterialPageRoute(builder: (context) => BreathingScreen()));
    } else {
      // --- Action: Did not understand ---
      _speak("Sorry, I didn't understand that. Please say 'Call' or 'Calm'.");
    }
  }

  Future<void> _callEmergency() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _speak("I could not open the phone dialer.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Assistant"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- 1. Assistant's Output UI ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _assistantText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // --- 2. Microphone & Listening UI ---
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: AvatarGlow(
                  animate: _isListening,
                  glowColor: Colors.cyanAccent,
                  endRadius: 120.0,
                  child: Material(
                    elevation: 8.0,
                    shape: const CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: _isListening ? Colors.redAccent : Colors.cyan,
                      radius: 80.0,
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              
              // --- 3. User's Input UI ---
              Text(
                _userSpokenText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}