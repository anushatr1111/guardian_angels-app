import 'package:aura_safe_app/services/emotion_service.dart'; // Import the service
import 'package:aura_safe_app/widgets/animated_button.dart'; // Using the existing button
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AiEmotionScreen extends StatefulWidget {
  const AiEmotionScreen({super.key});

  @override
  State<AiEmotionScreen> createState() => _AiEmotionScreenState();
}

class _AiEmotionScreenState extends State<AiEmotionScreen> {
  final TextEditingController _moodInputController = TextEditingController();
  final EmotionService _emotionService = EmotionService(); // Instance of the service

  // State for displaying results
  String _detectedEmotion = ''; // To store the result
  String _calmingTip = '';      // To store the suggestion
  bool _isLoading = false;      // To show loading state

  // Map of emotions to calming tips (Step 18.3)
  final Map<String, String> _calmingTips = {
    'Negative': 'It\'s okay to feel this way. Take a moment to focus on your breathing. Inhale slowly for 4 seconds, hold for 4, and exhale for 6. Repeat this 5 times.',
    'Positive': 'That\'s great to hear! Take a moment to appreciate this feeling. What is one small thing that contributed to this good mood?',
    'Neutral': 'Feelings come and go. A good moment to check in with your body. Try stretching your arms above your head or taking a short walk.',
    'Error': 'I\'m having a bit of trouble understanding. Could you try rephrasing?'
  };

  @override
  void dispose() {
    _moodInputController.dispose();
    super.dispose();
  }

  // Function to handle analysis (Steps 18.2 & 18.3)
  Future<void> _analyzeEmotion() async {
    if (_moodInputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe how you are feeling.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _detectedEmotion = ''; // Clear previous results
      _calmingTip = '';
    });

    String inputText = _moodInputController.text.trim();
    print("Input Text: $inputText");

    // --- Step 18.2: Call Emotion Service (Placeholder) ---
    String sentiment = await _emotionService.analyzeSentiment(inputText);
    
    // Handle potential error from service
    if (sentiment.startsWith('Error')) {
      sentiment = 'Error';
    }

    // --- Step 18.3: Suggest Calming Tip ---
    // Look up the tip from our map. Default to a neutral tip if not found.
    String tip = _calmingTips[sentiment] ?? _calmingTips['Neutral']!;

    setState(() {
      _detectedEmotion = sentiment;
      _calmingTip = tip;
      _isLoading = false;
    });
    // --- End ---
  }

  // Placeholder for voice input
  void _startVoiceInput() {
    // TODO: Implement speech-to-text logic here (Step 18.4)
    print("Voice input button tapped (not implemented)");
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice input coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Check-in'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make children fill width
          children: [
            const Text(
              'How are you feeling right now?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // --- Mood Input TextField (Step 18.1) ---
            TextField(
              controller: _moodInputController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your feelings here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                // --- Optional: Voice Input Button (Step 18.1 / 18.4) ---
                suffixIcon: IconButton(
                  icon: const Icon(LineIcons.microphone),
                  color: Colors.white54,
                  tooltip: 'Use Voice Input',
                  onPressed: _startVoiceInput,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // --- Analyze Button (Step 18.1) ---
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              AnimatedButton(
                text: 'Analyze Emotion',
                onTap: _analyzeEmotion,
              ),
            const SizedBox(height: 40),

            // --- Display Area (Step 18.1) ---
            if (_detectedEmotion.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detected Emotion: $_detectedEmotion', // Display result
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    const Text(
                      'Suggestion:',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _calmingTip, // Display tip
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}