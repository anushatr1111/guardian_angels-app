import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:line_icons/line_icons.dart';
import 'package:aura_safe_app/services/ai_service.dart'; // Make sure this line exists and is correct
// A simple data model for a chat message
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// AI Service class to handle API calls
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isAiTyping = false;
  final AiService _aiService = AiService();

  @override
  void initState() {
    super.initState();
    _addMessage(ChatMessage(
      text: "Hello! I'm your Safe-Situation Assistant. How can I help you feel more secure right now?",
      isUser: false
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() => _messages.insert(0, message));
  }

  void _getAndAddAiResponse(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    // Show user message immediately
    _addMessage(ChatMessage(text: userMessage, isUser: true));

    // Show typing indicator
    setState(() => _isAiTyping = true);

    // Call the AI service
    final String? aiText = await _aiService.getAiResponse(userMessage);

    // Add the AI response (or an error message)
    _addMessage(ChatMessage(
      text: aiText ?? "Sorry, I couldn't respond.",
      isUser: false
    ));

    // Hide typing indicator
    setState(() => _isAiTyping = false);
  }

  void _onSuggestionTapped(String userMessage, String? specificPrompt) {
    _getAndAddAiResponse(specificPrompt ?? userMessage);
  }

  void _handleSubmitted() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      _getAndAddAiResponse(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text("AI Assistant"),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isAiTyping && index == 0) {
                  return _buildTypingIndicator();
                }
                final msgIndex = _isAiTyping ? index - 1 : index;
                return _buildMessageBubble(_messages[msgIndex]);
              },
            ),
          ),
          if (_messages.length == 1) _buildSuggestionArea(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF0F3460)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("AI is typing", style: TextStyle(color: Colors.white.withOpacity(0.7))),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What do you want to do?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSuggestionCard(
                icon: LineIcons.phone,
                text: "Fake a Call",
                onTap: () => _onSuggestionTapped(
                  "I need an excuse to leave.",
                  "Simulate receiving an urgent phone call on my device in 10 seconds as an excuse to leave my current situation.",
                ),
              ),
              _buildSuggestionCard(
                icon: LineIcons.mapMarker,
                text: "Share Location",
                onTap: () => _onSuggestionTapped(
                  "I want to share my location.",
                  "Explain how I can share my live location with my emergency contacts using this app's features.",
                ),
              ),
              _buildSuggestionCard(
                icon: LineIcons.sms,
                text: "Text a Friend",
                onTap: () => _onSuggestionTapped(
                  "Can you text my friend?",
                  "Ask me who I want to text from my emergency contacts and what the message should be.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 30),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _handleSubmitted(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF1A1A2E)),
              onPressed: _handleSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}