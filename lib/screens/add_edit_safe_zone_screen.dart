import 'package:aura_safe_app/models/safe_zone_model.dart';
import 'package:aura_safe_app/services/safe_zone_service.dart'; // Import the service
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for GeoPoint
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';

class AddEditSafeZoneScreen extends StatefulWidget {
  final SafeZone? existingSafeZone;

  const AddEditSafeZoneScreen({super.key, this.existingSafeZone});

  @override
  State<AddEditSafeZoneScreen> createState() => _AddEditSafeZoneScreenState();
}

class _AddEditSafeZoneScreenState extends State<AddEditSafeZoneScreen> {
  final _nameController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedCenter;
  double _selectedRadius = 150.0;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  late CameraPosition _initialPosition;

  final SafeZoneService _safeZoneService = SafeZoneService(); // Instance of the service
  bool _isSaving = false; // Loading state for save button

  @override
  void initState() {
    super.initState();
    if (widget.existingSafeZone != null) {
      _nameController.text = widget.existingSafeZone!.name;
      _selectedCenter = LatLng(widget.existingSafeZone!.center.latitude, widget.existingSafeZone!.center.longitude);
      _selectedRadius = widget.existingSafeZone!.radius;
      _initialPosition = CameraPosition(target: _selectedCenter!, zoom: 16.0);
      _updateMapVisuals();
    } else {
      _initialPosition = const CameraPosition(
        target: LatLng(9.4674, 77.9622), // Default to Virudhunagar approx.
        zoom: 12.0,
      );
      // TODO: Get user's current location to center initially more accurately
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedCenter = position;
      _updateMapVisuals();
    });
  }

  void _updateMapVisuals() {
    if (_selectedCenter == null) return;
    _markers.clear();
    _circles.clear();
    _markers.add(Marker(
      markerId: const MarkerId('selected_center'),
      position: _selectedCenter!,
      draggable: true,
      onDragEnd: (newPosition) {
        setState(() {
          _selectedCenter = newPosition;
          _updateMapVisuals();
        });
      },
    ));
    _circles.add(Circle(
      circleId: const CircleId('selected_radius'),
      center: _selectedCenter!,
      radius: _selectedRadius,
      fillColor: Colors.blue.withOpacity(0.2),
      strokeColor: Colors.blueAccent,
      strokeWidth: 2,
    ));
  }

  // --- UPDATED SAVE LOGIC ---
  Future<void> _saveSafeZone() async {
    if (_selectedCenter == null || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a location and enter a name.'),
            backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isSaving = true); // Show loading indicator

    final String name = _nameController.text.trim();
    final GeoPoint center = GeoPoint(_selectedCenter!.latitude, _selectedCenter!.longitude);
    final double radius = _selectedRadius;

    try {
      if (widget.existingSafeZone == null) {
        // Add new zone
        await _safeZoneService.addSafeZone(name: name, center: center, radius: radius);
      } else {
        // Update existing zone
        final updatedZone = SafeZone(
          id: widget.existingSafeZone!.id, // Use existing ID
          name: name,
          center: center,
          radius: radius,
        );
        await _safeZoneService.updateSafeZone(updatedZone);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Safe Zone "${name}" saved successfully.'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Go back after saving
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving Safe Zone: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
       if (mounted) {
           setState(() => _isSaving = false); // Hide loading indicator
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingSafeZone == null ? 'Add Safe Zone' : 'Edit Safe Zone'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Show loading indicator or save button
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveSafeZone,
                  tooltip: 'Save',
                ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated,
              onTap: _onMapTap,
              markers: _markers,
              circles: _circles,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Zone Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(LineIcons.tag),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Radius: ${_selectedRadius.toStringAsFixed(0)} meters'),
                  Slider(
                    value: _selectedRadius,
                    min: 50.0,
                    max: 1000.0,
                    divisions: 19,
                    label: '${_selectedRadius.toStringAsFixed(0)}m',
                    onChanged: (value) {
                      setState(() {
                        _selectedRadius = value;
                        _updateMapVisuals();
                      });
                    },
                    activeColor: Colors.cyanAccent,
                    inactiveColor: Colors.grey.shade700,
                  ),
                  if (_selectedCenter != null)
                    Text(
                      'Selected: Lat: ${_selectedCenter!.latitude.toStringAsFixed(4)}, Lon: ${_selectedCenter!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}