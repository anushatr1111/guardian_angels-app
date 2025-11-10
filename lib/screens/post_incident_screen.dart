import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart'; // For calling/SMS
import 'package:aura_safe_app/services/emergency_manager.dart'; // For SMS logic
import 'package:flutter/foundation.dart' show kDebugMode; // For debugging
import 'package:aura_safe_app/screens/report_template_screen.dart'; // Import manual report screen
import 'package:aura_safe_app/screens/ai_report_generator_screen.dart'; // Import AI report screen
import 'package:aura_safe_app/screens/calm_mode_screen.dart'; // Import Calm Mode screen

// --- Calm Color Palette ---
const Color calmBackground = Color(0xFFE0F2F7); // Very light cyan/blue
const Color calmPrimary = Color(0xFFB2DFDB);   // Soft teal
const Color calmAccent = Color(0xFF80CBC4);    // Slightly darker teal
const Color calmText = Color(0xFF37474F);      // Dark grey-blue (readable)
const Color calmTextLight = Color(0xFF546E7A); // Lighter grey-blue
const Color calmProgressDone = Color(0xFF81C784); // Soft green
// --- ---

class PostIncidentScreen extends StatefulWidget {
  const PostIncidentScreen({super.key});

  @override
  State<PostIncidentScreen> createState() => _PostIncidentScreenState();
}

class _PostIncidentScreenState extends State<PostIncidentScreen> {
  int _activeStep = 0;

  // Define the content for each step
  final List<Widget> _steps = [
    const StepCalm(),        // Step 0: Calm
    const StepContact(),     // Step 1: Contact
    const StepReport(),      // Step 2: Report
    const StepRecover(),     // Step 3: Recover
  ];

  @override
  Widget build(BuildContext context) {
    // --- APPLY CALM THEME ---
    return Theme(
      // Override ThemeData for this specific screen
      data: ThemeData(
        brightness: Brightness.light, // Use a light base
        scaffoldBackgroundColor: calmBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: calmText, // Dark text for light background
          iconTheme: IconThemeData(color: calmText), // Back button color
        ),
        textTheme: Theme.of(context).textTheme.apply( // Apply calm text colors
              bodyColor: calmText,
              displayColor: calmText,
            ),
        iconTheme: const IconThemeData(color: calmAccent), // Default icon color
        dividerColor: calmPrimary, // Separator color
        // Style ElevatedButton for this screen
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
             backgroundColor: calmAccent,
             foregroundColor: Colors.white, // White text on buttons
          ),
        ),
         // Style TextButton for this screen
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: calmTextLight,
          )
        )
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post-Incident Guide'),
        ),
        body: Column(
          children: [
            // --- Step Progress Indicator ---
            EasyStepper(
              activeStep: _activeStep,
              lineStyle: const LineStyle(
                lineLength: 80, // Corrected: moved inside LineStyle
                lineThickness: 2,
              ),
              stepShape: StepShape.circle,
              stepBorderRadius: 15,
              stepRadius: 28,
              finishedStepBackgroundColor: calmProgressDone, // Use calm green
              activeStepBackgroundColor: calmPrimary,     // Use calm teal
              unreachedStepBackgroundColor: Colors.grey.shade300, // Corrected parameter name
              activeStepIconColor: Colors.white,
              finishedStepIconColor: Colors.white,
              activeStepTextColor: calmText,
              finishedStepTextColor: calmText,
              unreachedStepTextColor: calmTextLight, // Corrected parameter name
              padding: const EdgeInsets.all(10), // Corrected: use padding instead of internalPadding
              steps: [
                 EasyStep(
                   icon: Icon(LineIcons.heart), // Changed: heartPulse doesn't exist
                   title: 'Calm',
                 ),
                 EasyStep(
                   icon: Icon(LineIcons.userFriends), 
                   title: 'Contact',
                 ),
                 EasyStep(
                   icon: Icon(LineIcons.fileAlt), 
                   title: 'Report',
                 ),
                 EasyStep(
                   icon: Icon(LineIcons.spa), 
                   title: 'Recover',
                 ),
              ],
              onStepReached: (index) => setState(() => _activeStep = index),
            ),

            // --- Step Content ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                // Use AnimatedSwitcher for smooth transitions between steps
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500), // Slower animation
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Container(
                    // Key ensures AnimatedSwitcher detects child change
                    key: ValueKey<int>(_activeStep),
                    child: _steps[_activeStep],
                  ),
                ),
              ),
            ),

            // --- Navigation Buttons ---
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

 // Navigation buttons adjusted for calm theme
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _activeStep > 0
                ? () => setState(() => _activeStep--)
                : null,
            child: Text(
              'Back',
              style: TextStyle( // Explicitly set color based on state
                color: _activeStep > 0 ? calmTextLight : Colors.grey.shade400,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _activeStep < _steps.length - 1
                ? () => setState(() => _activeStep++)
                : () => Navigator.of(context).pop(), // Close guide on last step
            child: Text(
              _activeStep < _steps.length - 1 ? 'Next' : 'Finish',
            ),
          ),
        ],
      ),
    );
  }
}

// --- Common Text Styles ---
TextStyle _calmTitleStyle = const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: calmText);
TextStyle _calmBodyStyle = const TextStyle(fontSize: 17, color: calmTextLight, height: 1.5);
TextStyle _calmSubTitleStyle = const TextStyle(color: calmTextLight, fontSize: 12);

// --- Step 0: Calm ---
class StepCalm extends StatelessWidget {
  const StepCalm({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You are Safe Now', style: _calmTitleStyle),
          const SizedBox(height: 10),
          Text(
            'Take a deep breath. Let\'s do a quick breathing exercise together.',
            textAlign: TextAlign.center,
            style: _calmBodyStyle.copyWith(fontSize: 18), // Slightly larger body
          ),
          Lottie.asset(
            // Ensure you have this animation file in assets/animations/
            'assets/animations/calm_breathing.json',
            width: 250,
            height: 250,
          ),
          Text(
            'Follow the animation: Breathe in... hold... and breathe out slowly.',
            textAlign: TextAlign.center,
            style: _calmBodyStyle.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// --- Step 1: Contact ---
class StepContact extends StatefulWidget {
  const StepContact({super.key});

  @override
  State<StepContact> createState() => _StepContactState();
}

class _StepContactState extends State<StepContact> {
  final EmergencyManager _emergencyManager = EmergencyManager(); // Non-const initialization

  Future<void> _callEmergency(BuildContext context) async {
    const String emergencyNumber = '112';
    final Uri launchUri = Uri(scheme: 'tel', path: emergencyNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone dialer.'))
          );
        }
        if (kDebugMode) print('Could not launch $launchUri');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching dialer: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reach Out', style: _calmTitleStyle),
          const SizedBox(height: 10),
          Text(
            'Consider contacting someone you trust or emergency services if needed.',
            style: _calmBodyStyle,
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(LineIcons.phoneVolume, color: Colors.redAccent, size: 30),
            title: const Text('Call Emergency Services', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
            onTap: () => _callEmergency(context),
          ),
          const Divider(), // Use theme divider color
          ListTile(
            leading: const Icon(LineIcons.userFriends, color: calmAccent),
            title: const Text('Text Primary Emergency Contact'),
            subtitle: Text('Sends a pre-filled message with location', style: _calmSubTitleStyle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await _emergencyManager.sendSosMessageToPrimaryContact(context);
            },
          ),
           ListTile(
            leading: const Icon(LineIcons.phone, color: calmAccent),
            title: const Text('Call a Support Hotline'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Add call logic to a specific support number */ },
          ),
        ],
      ),
    );
  }
}

// --- Step 2: Report ---
class StepReport extends StatelessWidget {
  const StepReport({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Document the Incident', style: _calmTitleStyle),
          const SizedBox(height: 10),
          Text(
            'If you feel comfortable, noting down details can be helpful later.',
            style: _calmBodyStyle,
          ),
          const SizedBox(height: 30),

          // --- ADDED: Link to AI Report Generator ---
          ListTile(
            leading: const Icon(LineIcons.robot, color: calmAccent),
            title: const Text('Auto-Generate Report with AI'),
            subtitle: Text('Speak or type what happened', style: _calmSubTitleStyle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AiReportGeneratorScreen()));
            },
          ),
          const Divider(),
          // --- END ADDED ---

           ListTile(
            leading: const Icon(LineIcons.fileAlt, color: calmAccent),
            title: const Text('File an Official Report (Manual)'),
            subtitle: Text('Consider reporting to authorities if appropriate', style: _calmSubTitleStyle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { 
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportTemplateScreen()));
            },
          ),
           ListTile(
            leading: const Icon(LineIcons.stickyNote, color: calmAccent),
            title: const Text('Make Personal Notes'),
             subtitle: Text('Record details for yourself', style: _calmSubTitleStyle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Optional: Navigate to an in-app notes feature? */ },
          ),
        ],
      ),
    );
  }
}

// --- Step 3: Recover ---
class StepRecover extends StatelessWidget {
  const StepRecover({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Focus on Recovery', style: _calmTitleStyle),
          const SizedBox(height: 10),
          Text(
            'Your well-being is the priority. Here are some resources for support and self-care.',
            style: _calmBodyStyle,
          ),
          const SizedBox(height: 30),

           // --- ADDED: Link to Calm Mode ---
           ListTile(
            leading: const Icon(LineIcons.heartbeat, color: calmAccent),
            title: const Text('Guided Breathing Exercise'),
            subtitle: Text('A quick grounding exercise', style: _calmSubTitleStyle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const CalmModeScreen()));
            },
          ),
          const Divider(),
          // --- END ADDED ---

           ListTile(
             leading: const Icon(LineIcons.edit, color: calmAccent), 
             title: const Text('Create Incident Report'),
             subtitle: Text('Document details for your records', style: _calmSubTitleStyle),
             trailing: const Icon(Icons.chevron_right),
             onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportTemplateScreen()));
             },
           ),
          ListTile(
            leading: const Icon(LineIcons.hands, color: calmAccent), // Changed: alternateHandsHelping doesn't exist
            title: const Text('Find Local Support Groups'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Add link to mental health resources */ },
          ),
          ListTile(
            leading: const Icon(LineIcons.bookOpen, color: calmAccent), // Book icon
            title: const Text('Self-Care Resources'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Add link to articles/guides on self-care */ },
          ),
          ListTile(
            leading: const Icon(LineIcons.comments, color: calmAccent), // Comments/Chat icon
            title: const Text('Talk to a Professional'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Add link to find therapists/counselors */ },
          ),
        ],
      ),
    );
  }
}