import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:aura_safe_app/widgets/animated_button.dart';
import 'dart:io'; // To display image files

// TODO: Import vault_service.dart later

class IncidentVaultScreen extends StatefulWidget {
  const IncidentVaultScreen({super.key});

  @override
  State<IncidentVaultScreen> createState() => _IncidentVaultScreenState();
}

class _IncidentVaultScreenState extends State<IncidentVaultScreen> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  // State to hold captured media
  XFile? _capturedImage;
  String? _audioRecordingPath; // Placeholder for audio file path
  bool _isRecording = false;

  final ImagePicker _picker = ImagePicker();
  // TODO: Initialize audio recorder from 'record' package

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  /// --- 20.1: Capture Text ---
  // Text is captured via the TextFormFields below.

  /// --- 20.1: Capture Photo ---
  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        _capturedImage = photo;
      });
    } catch (e) {
      print("Error capturing photo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error capturing photo.')),
      );
    }
  }

  /// --- 20.1: Pick Photo from Gallery ---
  Future<void> _pickFromGallery() async {
     try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image.')),
      );
    }
  }

  /// --- 20.1: Capture Voice (Placeholder) ---
  Future<void> _toggleRecording() async {
    // TODO: Implement actual audio recording logic with 'record' package
    if (_isRecording) {
      // --- Stop Recording ---
      setState(() => _isRecording = false);
      _audioRecordingPath = "/path/to/fake/recording.mp3"; // Placeholder
      print("Stopping recording. File at: $_audioRecordingPath");
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Recording stopped.')),
      );
    } else {
      // --- Start Recording ---
      // TODO: Request mic permission
      // TODO: Start audio recorder
      setState(() => _isRecording = true);
      _audioRecordingPath = null; // Clear old path
      print("Starting recording...");
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Recording started...')),
      );
    }
  }

  /// --- 20.2: Save Incident (Placeholder) ---
  void _saveIncident() {
    if (_titleController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title.')),
      );
      return;
    }

    print("--- Saving Incident ---");
    print("Title: ${_titleController.text}");
    print("Details: ${_detailsController.text}");
    print("Image Path: ${_capturedImage?.path}");
    print("Audio Path: $_audioRecordingPath");
    // TODO: Call VaultService to encrypt and save data (Step 20.2)

    ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Incident saved securely (Placeholder).')),
    );
    Navigator.pop(context); // Go back after saving
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Incident'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveIncident,
            tooltip: 'Save Incident',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Text Input ---
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title / Summary',
                hintText: 'e.g., "Encounter on Main St."',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Details (What happened?)',
                hintText: 'Describe the event, location, people involved...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),

            // --- Media Capture Buttons ---
            Text("Add Evidence (Optional)", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // --- Audio Button ---
            ElevatedButton.icon(
              icon: Icon(_isRecording ? LineIcons.stop : LineIcons.microphone),
              label: Text(_isRecording ? 'Stop Recording' : 'Record Audio'),
              onPressed: _toggleRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.redAccent : Colors.white.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            if (_audioRecordingPath != null && !_isRecording)
               Text("Audio saved: ${_audioRecordingPath!.split('/').last}", style: const TextStyle(color: Colors.greenAccent)),

            const SizedBox(height: 16),

            // --- Photo Buttons ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(LineIcons.camera),
                    label: const Text('Camera'),
                    onPressed: _capturePhoto,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.white.withOpacity(0.1),
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(LineIcons.image),
                    label: const Text('Gallery'),
                    onPressed: _pickFromGallery,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.white.withOpacity(0.1),
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                  ),
                ),
              ],
            ),

            // --- Captured Image Preview ---
            if (_capturedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(File(_capturedImage!.path)),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      onPressed: () => setState(() => _capturedImage = null),
                    )
                  ],
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}