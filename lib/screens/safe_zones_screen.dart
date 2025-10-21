import 'package:aura_safe_app/models/safe_zone_model.dart'; // Import model
import 'package:aura_safe_app/services/safe_zone_service.dart'; // Import service
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for GeoPoint formatting
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

// ✅ Add this import
import 'package:aura_safe_app/screens/add_edit_safe_zone_screen.dart';

class SafeZonesScreen extends StatefulWidget {
  const SafeZonesScreen({super.key});

  @override
  State<SafeZonesScreen> createState() => _SafeZonesScreenState();
}

class _SafeZonesScreenState extends State<SafeZonesScreen> {
  final SafeZoneService _safeZoneService = SafeZoneService(); // Instance of the service

  // ✅ Updated: Navigate to Add/Edit screen instead of placeholder
  void _addSafeZone() {
    // Navigate to the Add/Edit screen in "add" mode (no existing zone)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditSafeZoneScreen()),
    );
  }

  void _editSafeZone(SafeZone zone) {
    // Navigate to the Add/Edit screen in "edit" mode, passing existing zone data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSafeZoneScreen(existingSafeZone: zone),
      ),
    );
  }

  Future<void> _deleteSafeZone(String id, String name) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Safe Zone?'),
            content: Text('Are you sure you want to delete "$name"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed

    if (confirm) {
      try {
        await _safeZoneService.deleteSafeZone(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$name" deleted successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting zone: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Safe Zones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addSafeZone,
            tooltip: 'Add New Safe Zone',
          ),
        ],
      ),
      body: StreamBuilder<List<SafeZone>>(
        stream: _safeZoneService.getSafeZonesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final safeZones = snapshot.data!;
          return _buildSafeZoneList(safeZones);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSafeZone,
        backgroundColor: Colors.cyanAccent,
        tooltip: 'Add New Safe Zone',
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LineIcons.mapMarked, size: 80, color: Colors.grey.shade600),
          const SizedBox(height: 20),
          const Text('No Safe Zones Added Yet',
              style: TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 10),
          const Text('Tap the \'+\' button to create one.',
              style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildSafeZoneList(List<SafeZone> safeZones) {
    return ListView.builder(
      itemCount: safeZones.length,
      itemBuilder: (context, index) {
        final zone = safeZones[index];
        return ListTile(
          leading: const Icon(LineIcons.mapPin, color: Colors.cyanAccent),
          title: Text(zone.name),
          subtitle: Text(
              "Lat: ${zone.center.latitude.toStringAsFixed(4)}, Lon: ${zone.center.longitude.toStringAsFixed(4)}, Radius: ${zone.radius.toStringAsFixed(0)}m"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                onPressed: () => _editSafeZone(zone),
                tooltip: 'Edit Zone',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteSafeZone(zone.id, zone.name),
                tooltip: 'Delete Zone',
              ),
            ],
          ),
        );
      },
    );
  }
}
