# Aura Safe App (Guardian Angel) 🛡️

A personal safety mobile application built with Flutter, designed to provide users with quick access to help, location sharing, and smart safety features.

---

## ✨ Current Features (Completed)

This app currently includes the following core functionalities:

* **Core UI & Navigation:**
    * Modern, intuitive UI with glassmorphism panels and smooth transitions.
    * Bottom navigation bar (Home, SOS, Map, Profile).
    * Custom animated alert cards and buttons.
    * Theming with custom fonts (`google_fonts`).
* **Authentication:**
    * Secure user **login and signup** using Firebase Authentication (Email/Password).
    * Persistent login state (`AuthWrapper`).
* **Emergency Contacts:**
    * Ability to **add emergency contacts** from the phone's address book.
    * Contacts are stored securely per user in **Firestore**.
    * View and manage saved emergency contacts.
* **SOS Features:**
    * Dedicated **SOS screen** displaying emergency contacts.
    * One-tap **SOS button** (with confirmation) to simulate sending alerts.
    * **Floating SOS button** on the map screen.
* **Mapping & Navigation:**
    * Real-time **live location tracking** displayed on Google Maps.
    * Custom animated **user location marker**.
    * Tap-to-route functionality using the **Google Directions API**.
    * Route displayed as a **polyline** on the map.
    * Toggle chip to show/hide the route.
* **Profile & Settings:**
    * User profile screen displaying name and email.
    * Ability to **edit display name**.
    * Basic **settings panel** with toggles for Location Sharing, Theme (placeholder), Notifications (placeholder), and Gemini Features (placeholder), saved using `shared_preferences`.
* **Help Vault:**
    * Secure storage for medical/emergency info using `flutter_secure_storage`.
    * UI with expandable sections (`ExpansionTile`).
    * Lottie animation feedback on saving.
    * **Biometric lock** (`local_auth`) to protect access to the vault.
* **Smart Triggers:**
    * **Voice-activated SOS** using a keyword ("help me") via `speech_to_text`, with waveform visualization and glowing mic animation.
    * **Hardware SOS trigger** (detecting rapid volume button presses) leading to a confirmation screen with countdown and haptic feedback.
* **AI Assistant (Basic Integration):**
    * **Chat-style UI** for interacting with an AI assistant.
    * Quick **suggestion cards** ("Fake Call", "Share Location", "Text Friend").
    * Integration with **Google Gemini API** (via `http`) to provide real responses, using a dynamically selectable model.
    * Animated message bubbles.
* **Post-Incident Guide:**
    * **Step-by-step flow** (Calm -> Contact -> Report -> Recover) with progress indicator (`easy_stepper`).
    * **Calm UI theme** applied specifically to this screen.
    * Includes **breathing exercise animation** (`lottie`).
    * Direct action buttons (Call Emergency, Text Contact).
* **Reporting:**
    * **Incident report template** screen.
    * Auto-fills **timestamp** and **current location**.
    * Placeholders for user input (details, parties, witnesses).
    * **PDF export** functionality using `pdf` and `printing`.
    * **Email export** functionality using `mailer` (requires user setup).

---

## 🚀 Future Work (Planned Levels 18-25)

The following features are planned for future development:

* **Level 18: AI Emotion Check-in:** UI for mood input, basic sentiment analysis, and suggesting calming tips.
* **Level 19: Voice Assistant for Crisis:** Voice-guided UI, speech recognition + Text-to-Speech (TTS), interactive choices during a crisis.
* **Level 20: Incident Capture Vault:** Securely capture and encrypt incident details (text, voice, photos) behind biometrics/passcode.
* **Level 21: Auto Incident Summary Generator:** Use AI (like Gemini) to automatically generate a formatted report from captured text/voice input.
* **Level 22: AI Smart Route Suggestions:** Use AI to suggest the safest route based on various factors, highlighting key safety points (hospitals, police stations).
* **Level 23: Guided Breathing / Grounding Mode:** Dedicated screen with breathing animations, vibration feedback, and ambient sounds.
* **Level 24: Positive Affirmation & Reflection Journal:** Add wellness features like affirmation popups and a simple journaling function.
* **Level 25: Cleanup & Final Testing:** Thorough Quality Assurance (QA) testing, bug fixing, UI polishing, and code cleanup.

---

## 📸 Suggested Screenshots

To showcase the app effectively in your repository, consider adding screenshots of:

1.  **Login/Signup Screen:** Showing the gradient and glass text fields.
2.  **Home Screen (Dashboard):** Highlighting the action cards and alert card.
3.  **Map Screen:** Showing the custom marker, a drawn route, and the floating SOS button.
4.  **SOS Screen:** Displaying the main SOS button and the list of emergency contacts.
5.  **Profile Screen:** Showing the layout with the avatar, user details, and glass card options.
6.  **Help Vault (Locked):** The biometric lock screen.
7.  **Help Vault (Unlocked):** An expanded section showing the input fields.
8.  **Voice SOS Screen:** Showing the waveform and glowing microphone while listening.
9.  **Hardware SOS Confirmation Screen:** The red countdown screen.
10. **AI Assistant Screen:** A sample conversation with suggestion cards visible.
11. **Post-Incident Guide:** One step showing the calm theme and stepper (e.g., the "Calm" step with the breathing animation).
12. **Settings Screen:** Showing the various toggle options.
13. **Report Template Screen:** Showing the pre-filled data and input fields.
14. **Manage Safe Zones Screen:** Showing the list view (even if populated with test data).
15. **Add/Edit Safe Zone Screen:** Showing the map with the circle radius editor.

---

## 🛠️ Setup (Optional)

To run this project:

1.  Ensure you have the Flutter SDK installed (Version: `3.xx.x` - *Add your specific version*).
2.  Configure Firebase for your project (Android/iOS setup, Authentication, Firestore). Place your `firebase_options.dart` file in `lib/`.
3.  Obtain API keys for Google Maps Platform (Maps SDKs, Directions API) and Google AI (Gemini API). Ensure billing is enabled on your Google Cloud project.
4.  Create a `.env` file in the project root and add your keys:
    ```dotenv
    GEMINI_API_KEY=YOUR_GEMINI_KEY
    GOOGLE_MAPS_API_KEY=YOUR_MAPS_KEY
    ```
5.  Run `flutter pub get`.
6.  Run `flutter run`.

*(Add any other specific setup instructions if necessary)*

---

*(You can add sections for Contributing or License if you wish)*