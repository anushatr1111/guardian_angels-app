🛡️ Aura Safe App (Guardian Angel)

A personal safety mobile application built with Flutter, designed to provide users with quick access to help, real-time location sharing, and AI-powered smart safety features.

✨ Features Overview
🧭 Core UI & Navigation

Modern, glassmorphism-inspired UI with smooth transitions.

Bottom Navigation Bar: Home, SOS, Map, Profile.

Custom animated alert cards and action buttons.

Theming with Google Fonts and soft gradients.

🔐 Authentication

Secure Firebase Authentication (Email/Password).

Persistent login state with AuthWrapper.

👥 Emergency Contacts

Add emergency contacts directly from your phonebook.

Secure per-user contact storage via Firestore.

Manage, view, and update contacts seamlessly.

🚨 SOS Features

Dedicated SOS screen showing emergency contacts.

One-tap SOS trigger (with confirmation).

Floating SOS button on the Map screen for quick access.

🗺️ Mapping & Navigation

Real-time live location tracking with a custom animated marker.

Tap-to-route navigation using Google Directions API.

Interactive polylines for routes with toggle visibility.

👤 Profile & Settings

Editable Profile Screen displaying user name & email.

Settings with toggles for:

Location Sharing

Dark Mode (placeholder)

Notifications (placeholder)

Gemini AI Features (placeholder)

Preferences saved using shared_preferences.

🧾 Help Vault

Securely store medical and emergency details using flutter_secure_storage.

Expandable UI with ExpansionTile.

Biometric lock (via local_auth) for access protection.

Lottie animations for feedback during save actions.

🎙️ Smart Triggers

Voice-Activated SOS: Keyword “Help Me” triggers an alert.

Waveform visualization and glowing mic animation (speech_to_text).

Hardware Trigger: Rapid volume button presses trigger an SOS confirmation screen with haptic feedback.

🤖 AI Assistant (Gemini Integration)

Chat-style AI assistant with animated message bubbles.

Quick action cards: Fake Call, Share Location, Text Friend.

Gemini API integration for real-time smart responses.

Dynamically selectable model and interactive UI.

🧘 Post-Incident Guide

Guided “Calm → Contact → Report → Recover” steps with progress indicator (easy_stepper).

Includes breathing exercise animation (lottie).

Direct buttons to Call Emergency or Message Contacts.

Soothing theme to aid user calmness after distress.

📄 Reporting Tools

Incident Report Template with:

Auto-filled timestamp and current location

Input fields for details, parties, and witnesses

PDF export using pdf + printing.

Email export via mailer (manual setup required).

🧠 Planned Features (Levels 18–25)
Level	Feature	Description
18	AI Emotion Check-in	Sentiment-based mood tracking with calming suggestions.
19	Voice Assistant for Crisis	Hands-free TTS + speech-recognition for emergency guidance.
20	Incident Capture Vault	Secure, encrypted vault for text, voice, and photo evidence.
21	AI Auto Report Generator	Automatically generates detailed incident summaries using Gemini.
22	AI Smart Route Suggestions	AI-recommended safe routes highlighting hospitals/police stations.
23	Guided Breathing Mode	Breathing exercises with vibration and ambient sounds.
24	Positive Affirmations & Journal	Daily self-reflection and mental wellness tools.
25	Final QA & UI Polishing	Testing, cleanup, and performance optimization.
📸 App Screenshots

(Add screenshots in the order below for an appealing GitHub presentation.)

Screen	Preview
Login / Signup	:![Login Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0001.jpg?raw=true)

Home Dashboard	:![Home Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0002.jpg?raw=true)

Map & Route	:![Map Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0003.jpg?raw=true)

SOS Screen	:![SOS Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0004.jpg?raw=true)

Profile Screen	:![Profile Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0005.jpg?raw=true)

Help Vault (Locked)	:![Help Vault Locked Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0006.jpg?raw=true)

Help Vault (Unlocked)	:![Help Vault Unlocked Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0007.jpg?raw=true)

Voice SOS	:![Voice SOS Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0008.jpg?raw=true)

Hardware SOS Confirmation	:![Hardware SOS Confirmation Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0009.jpg?raw=true)

AI Assistant	:![AI Assistant Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0010.jpg?raw=true)

Post-Incident Guide	:![Post-Incident Guide Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0011.jpg?raw=true)

Settings	:![Settings Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0012.jpg?raw=true)

Incident Report Template	:![Report Template Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0013.jpg?raw=true)

Manage Safe Zones	:![Manage Safe Zones Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0014.jpg?raw=true)

Add/Edit Safe Zone Screen:![Add/Edit Safe Zone Screen](https://github.com/anushatr1111/aura-safe-app/blob/main/assets/images/IMG-20251022-WA0015.jpg?raw=true) 
⚙️ Setup & Installation

Follow these steps to run Aura Safe App locally:

Install Flutter SDK
Ensure Flutter version 3.x.x or higher is installed.

flutter doctor


Configure Firebase

Enable Authentication and Firestore in your Firebase console.

Download firebase_options.dart and place it in lib/.

Obtain Required API Keys

Google Maps Platform: Enable Maps SDK and Directions API.

Google AI (Gemini): Create an API key from your Google Cloud console.

Add both keys in a .env file at your project root:

GEMINI_API_KEY=your_gemini_api_key
GOOGLE_MAPS_API_KEY=your_maps_api_key


Install Dependencies

flutter pub get


Run the App

flutter run

🧩 Tech Stack
Category	Technology
Frontend	Flutter, Dart
Backend	Firebase (Auth + Firestore)
APIs	Google Maps, Directions, Gemini AI
Storage	Flutter Secure Storage, Shared Preferences
Design	Glassmorphism UI, Lottie Animations
Security	Biometric Auth, Encrypted Data Storage
🤝 Contributing

Contributions are welcome!
To contribute:

Fork the repository

Create a feature branch (feature/your-feature)

Commit your changes

Open a Pull Request

📜 License

This project is licensed under the MIT License — see the LICENSE
 file for details.

🌟 Acknowledgments

Flutter for a beautiful, cross-platform framework.

Firebase for seamless authentication and cloud storage.

Google Maps & Gemini APIs for powering navigation and AI features.

Everyone committed to building a safer, smarter world. 💙