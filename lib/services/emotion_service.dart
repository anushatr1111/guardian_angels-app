// Placeholder for on-device sentiment analysis logic
class EmotionService {

  // Simulates analyzing text sentiment
  Future<String> analyzeSentiment(String text) async {
    // Prevent analyzing empty text
    if (text.trim().isEmpty) {
      return 'Neutral'; // Default if no details are given
    }

    print("🧠 Analyzing sentiment for: '$text'");
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // --- Placeholder Logic ---
    // This is a very basic keyword check for demonstration.
    String lowerText = text.toLowerCase();

    // Check for negative words
    if (lowerText.contains('sad') || 
        lowerText.contains('anxious') || 
        lowerText.contains('worried') || 
        lowerText.contains('angry') || 
        lowerText.contains('bad') ||
        lowerText.contains('terrible') ||
        lowerText.contains('scared') ||
        lowerText.contains('fear')) {
       print("🧠 -> Negative (Placeholder)");
       return 'Negative';
    } 
    // Check for positive words
    else if (lowerText.contains('happy') || 
               lowerText.contains('good') || 
               lowerText.contains('great') || 
               lowerText.contains('joy') ||
               lowerText.contains('okay') ||
               lowerText.contains('fine')) {
       print("🧠 -> Positive (Placeholder)");
       return 'Positive';
    } 
    // Default to neutral
    else {
       print("🧠 -> Neutral (Placeholder)");
       return 'Neutral';
    }
    // --- End Placeholder Logic ---
  }
}