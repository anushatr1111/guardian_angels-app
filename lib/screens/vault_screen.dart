import 'package:aura_safe_app/widgets/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  // Create an instance of the secure storage
  final _secureStorage = const FlutterSecureStorage();

  // Define keys for each piece of data
  final String _keyBloodType = 'blood_type';
  final String _keyAllergies = 'allergies';
  final String _keyMedications = 'medications';
  final String _keyPhysicianName = 'physician_name';
  final String _keyPhysicianPhone = 'physician_phone';

  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _physicianNameController = TextEditingController();
  final _physicianPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVaultData(); // Load any saved data when the screen opens
  }

  /// Loads all data from secure storage and populates the text fields.
  Future<void> _loadVaultData() async {
    _bloodTypeController.text = await _secureStorage.read(key: _keyBloodType) ?? '';
    _allergiesController.text = await _secureStorage.read(key: _keyAllergies) ?? '';
    _medicationsController.text = await _secureStorage.read(key: _keyMedications) ?? '';
    _physicianNameController.text = await _secureStorage.read(key: _keyPhysicianName) ?? '';
    _physicianPhoneController.text = await _secureStorage.read(key: _keyPhysicianPhone) ?? '';
  }

  /// Writes all data from the text fields to secure storage.
  Future<void> _saveVaultData() async {
    await _secureStorage.write(key: _keyBloodType, value: _bloodTypeController.text);
    await _secureStorage.write(key: _keyAllergies, value: _allergiesController.text);
    await _secureStorage.write(key: _keyMedications, value: _medicationsController.text);
    await _secureStorage.write(key: _keyPhysicianName, value: _physicianNameController.text);
    await _secureStorage.write(key: _keyPhysicianPhone, value: _physicianPhoneController.text);

    _showSuccessDialog(); // Show the animation dialog on success
  }

  /// Shows a dialog with a Lottie animation to confirm the save.
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e1e1e),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/success.json',
                repeat: false,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text('Vault Secured', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _physicianNameController.dispose();
    _physicianPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Vault'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'This information is stored securely on your device and will only be accessed during an emergency.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          _buildExpansionTile(
            title: 'Medical Information',
            icon: LineIcons.medicalBriefcase,
            children: [
              _buildTextField(controller: _bloodTypeController, label: 'Blood Type'),
              _buildTextField(controller: _allergiesController, label: 'Allergies'),
              _buildTextField(controller: _medicationsController, label: 'Medications'),
            ],
          ),
          const SizedBox(height: 10),
          _buildExpansionTile(
            title: 'Primary Physician',
            icon: Icons.medical_services,
            children: [
              _buildTextField(controller: _physicianNameController, label: 'Doctor\'s Name'),
              _buildTextField(controller: _physicianPhoneController, label: 'Doctor\'s Phone Number', keyboardType: TextInputType.phone),
            ],
          ),
          const SizedBox(height: 40),
          AnimatedButton(
            text: 'Save Vault Info',
            onTap: _saveVaultData, // Call the save function
          )
        ],
      ),
    );
  }

  // Helper widgets remain the same
  Widget _buildExpansionTile({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.cyanAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedAlignment: Alignment.topLeft,
        children: children,
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
        ),
      ),
    );
  }
}