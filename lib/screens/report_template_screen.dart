import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart'; // To get location
import 'package:aura_safe_app/utils/report_utils.dart';

class ReportTemplateScreen extends StatefulWidget {
  const ReportTemplateScreen({super.key});

  @override
  State<ReportTemplateScreen> createState() => _ReportTemplateScreenState();
}

class _ReportTemplateScreenState extends State<ReportTemplateScreen> {
  // Controllers for user input
  final _incidentDetailsController = TextEditingController();
  final _involvedPartiesController = TextEditingController();
  final _witnessesController = TextEditingController();

  // State for pre-filled data
  String _currentTime = 'Fetching time...';
  String _currentLocation = 'Fetching location...';
  String _primaryContact = 'Fetching contact...'; // Placeholder

  final Location _locationController = Location();

  @override
  void initState() {
    super.initState();
    _loadPrefilledData();
  }

  @override
  void dispose() {
    _incidentDetailsController.dispose();
    _involvedPartiesController.dispose();
    _witnessesController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefilledData() async {
    // --- Pre-fill Timestamp ---
    _currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // --- Pre-fill Location ---
    try {
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        _currentLocation = "Location service disabled.";
        setState(() {}); // Update UI even if service disabled
        return; // Don't proceed if no service
      }

      PermissionStatus permissionGranted = await _locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationController.requestPermission();
      }
      if (permissionGranted != PermissionStatus.granted) {
         _currentLocation = "Location permission denied.";
         setState(() {}); // Update UI if permission denied
         return; // Don't proceed if no permission
      }

      final locationData = await _locationController.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        _currentLocation =
            "Lat: ${locationData.latitude!.toStringAsFixed(4)}, Lon: ${locationData.longitude!.toStringAsFixed(4)}";
        // Optional: Use geocoding package to get an address string
      } else {
        _currentLocation = "Could not fetch location.";
      }
    } catch (e) {
      _currentLocation = "Error fetching location.";
      print("Error getting location for report: $e");
    }

    // --- Pre-fill Contact (Placeholder) ---
    // TODO: Fetch primary contact from Firestore (similar to EmergencyManager)
    _primaryContact = "Jane Doe - 555-1234 (Primary)"; // Example

    // Update the UI with fetched data
    setState(() {});
  }

  // --- UPDATED Export PDF Function ---
  void _exportAsPdf() {
    ReportUtils.generateAndSharePdf(
      context: context,
      currentTime: _currentTime,
      currentLocation: _currentLocation,
      primaryContact: _primaryContact,
      incidentDetails: _incidentDetailsController.text,
      involvedParties: _involvedPartiesController.text,
      witnesses: _witnessesController.text,
    );
  }

  // --- UPDATED Send Email Function ---
  void _sendAsEmail() {
    // For testing, hardcode a recipient or use a simple dialog to ask
    const String testRecipientEmail = "anusharajeshkumar08@gmail.com"; // REPLACE with a real email for testing

    // Add basic validation
    if (testRecipientEmail.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a recipient email for testing.'))
       );
       return;
    }

    ReportUtils.sendEmailWithReport(
      context: context,
      recipientEmail: testRecipientEmail, // Pass the recipient
      currentTime: _currentTime,
      currentLocation: _currentLocation,
      primaryContact: _primaryContact,
      incidentDetails: _incidentDetailsController.text,
      involvedParties: _involvedPartiesController.text,
      witnesses: _witnessesController.text,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Pre-filled Info ---
            _buildInfoSection('Time:', _currentTime, LineIcons.clock),
            _buildInfoSection('Location:', _currentLocation, LineIcons.mapMarker),
            _buildInfoSection('Primary Contact Notified:', _primaryContact, LineIcons.userShield),
            const Divider(height: 30),

            // --- User Input Fields ---
            _buildTextField(_incidentDetailsController, 'Incident Details', LineIcons.pen, maxLines: 5),
            _buildTextField(_involvedPartiesController, 'Involved Parties (Optional)', LineIcons.users),
            _buildTextField(_witnessesController, 'Witnesses (Optional)', LineIcons.eye),
            const SizedBox(height: 30),

            // --- Export Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(LineIcons.pdfFile),
                  label: const Text('Export PDF'),
                  onPressed: _exportAsPdf, // Updated
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
                ElevatedButton.icon(
                  icon: const Icon(LineIcons.paperPlane),
                  label: const Text('Send Email'),
                  onPressed: _sendAsEmail, // Updated
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper for displaying pre-filled info
  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for text input fields
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}