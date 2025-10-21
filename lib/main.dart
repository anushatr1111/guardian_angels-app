import 'dart:async';
import 'package:aura_safe_app/auth_wrapper.dart';
import 'package:aura_safe_app/firebase_options.dart';
import 'package:aura_safe_app/screens/hardware_sos_confirmation_screen.dart';
import 'package:aura_safe_app/screens/home_screen.dart';
import 'package:aura_safe_app/screens/map_screen.dart';
import 'package:aura_safe_app/screens/profile_screen.dart';
import 'package:aura_safe_app/screens/sos_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// The main function is now asynchronous to await Firebase initialization.
Future<void> main() async {
  // Ensures that widget binding is initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initializes Firebase with the platform-specific options.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian Angel',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  double _currentVolume = 0.0;
  final List<DateTime> _pressTimestamps = [];

  @override
  void initState() {
    super.initState();
    _startListeningToVolumeChanges();
  }

  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    super.dispose();
  }

  void _startListeningToVolumeChanges() async {
    // Get initial volume
    _currentVolume = await FlutterVolumeController.getVolume() ?? 0.0;
    
    // Hide the system volume UI (optional)
    await FlutterVolumeController.updateShowSystemUI(false);
    
    // Listen to volume changes
    FlutterVolumeController.addListener((volume) {
      // Detect volume changes (button presses)
      if (volume != _currentVolume) {
        _currentVolume = volume;
        
        _pressTimestamps.add(DateTime.now());
        
        // Remove timestamps older than 2 seconds
        _pressTimestamps.removeWhere(
          (t) => DateTime.now().difference(t).inSeconds > 2,
        );

        print('Volume changed to: $volume, Press count: ${_pressTimestamps.length}');

        // If 3 presses within 2 seconds, trigger SOS
        if (_pressTimestamps.length >= 3) {
          print('Volume button SOS pattern detected!');
          _pressTimestamps.clear();
          
          // Show system UI again before navigation
          FlutterVolumeController.updateShowSystemUI(true);
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HardwareSosConfirmationScreen(),
            ),
          );
        }
      }
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SosScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(LineIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(LineIcons.lifeRing), label: 'SOS'),
          BottomNavigationBarItem(icon: Icon(LineIcons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(LineIcons.user), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black.withOpacity(0.8),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
      ),
    );
  }
}