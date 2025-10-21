import 'dart:async';
import 'dart:ui' as ui;
import 'package:aura_safe_app/services/directions_service.dart';
import 'package:aura_safe_app/screens/sos_screen.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Service and Controller instances
  final Location _locationController = Location();
  final DirectionsService _directionsService = DirectionsService();
  GoogleMapController? _mapController;
  StreamSubscription<LocationData>? _locationSubscription;

  // --- State variables for routing ---
  final Set<Polyline> _polylines = {};
  LatLng? _userLocation;
  Marker? _destinationMarker;
  bool _showSafeRoute = true; // State for the toggle chip

  // --- State variables for markers ---
  final Set<Marker> _markers = {};
  BitmapDescriptor? _userMarkerIcon;

  // Initial map position
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(13.0827, 80.2707), // Default to Chennai, India
    zoom: 5.0,
  );

  @override
  void initState() {
    super.initState();
    _createCustomMarker().then((_) {
      _listenToLocationChanges();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  /// Draws a route from the user's location to a destination.
  Future<void> _drawRoute(LatLng destination) async {
    if (_userLocation == null) return;

    final String? polylineString =
        await _directionsService.getDirections(_userLocation!, destination);

    if (polylineString != null) {
      final polylinePoints = PolylinePoints().decodePolyline(polylineString);
      final List<LatLng> pointCoordinates =
          polylinePoints.map((point) => LatLng(point.latitude, point.longitude)).toList();

      if (pointCoordinates.isNotEmpty) {
        final safeRoute = Polyline(
          polylineId: const PolylineId('safe_route'),
          color: Colors.greenAccent,
          width: 5,
          points: pointCoordinates,
        );
        setState(() => _polylines.add(safeRoute));
      }
    }
  }

  /// Handles user taps on the map to set a destination.
  void _onMapTapped(LatLng destination) {
    setState(() {
      _polylines.clear();
      _destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      _drawRoute(destination);
    });
  }

  /// Creates a custom marker icon from an asset image.
  Future<void> _createCustomMarker() async {
    final Uint8List markerIconBytes = await _getBytesFromAsset('assets/user_pin.png', 150);
    _userMarkerIcon = BitmapDescriptor.fromBytes(markerIconBytes);
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  /// Requests permissions and subscribes to the device's location stream.
  Future<void> _listenToLocationChanges() async {
    print("➡️ Starting location listener setup..."); // ADD THIS

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    try {
      serviceEnabled = await _locationController.serviceEnabled();
      print("Service initially enabled: $serviceEnabled"); // ADD THIS
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        print("Service requested, now enabled: $serviceEnabled"); // ADD THIS
        if (!serviceEnabled) {
          print("❌ Location service disabled by user."); // ADD THIS
          return;
        }
      }

      permissionGranted = await _locationController.hasPermission();
      print("Initial permission status: $permissionGranted"); // ADD THIS
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationController.requestPermission();
        print("Permission requested, now status: $permissionGranted"); // ADD THIS
        if (permissionGranted != PermissionStatus.granted) {
          print("❌ Location permission denied by user."); // ADD THIS
          return;
        }
      }

      // Check again in case permissions were just granted
      if (permissionGranted == PermissionStatus.granted) {
        print("✅ Permissions granted. Subscribing to location stream..."); // ADD THIS
        _locationSubscription = _locationController.onLocationChanged.listen((LocationData currentLocation) {
          if (currentLocation.latitude != null && currentLocation.longitude != null) {
            _userLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            print("📍 Location Update: ${_userLocation!.latitude}, ${_userLocation!.longitude}"); // Existing print

            _mapController?.animateCamera(
              CameraUpdate.newLatLng(_userLocation!),
            );
            _updateUserMarker(_userLocation!);
          }
        });
      } else {
        print("❌ Location permission not granted after request."); // ADD THIS
      }
    } catch (e) {
      print("🚨 Error during location setup: $e"); // ADD THIS
    }
  }

  /// Updates the position of the custom user marker on the map.
  void _updateUserMarker(LatLng position) {
    if (_userMarkerIcon == null) return;
    final userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: position,
      icon: _userMarkerIcon!,
      anchor: const Offset(0.5, 0.5),
    );

    _markers.clear();
    _markers.add(userMarker);
    if (_destinationMarker != null) {
      _markers.add(_destinationMarker!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
            polylines: _showSafeRoute ? _polylines : {},
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            padding: const EdgeInsets.only(top: 60.0),
          ),
          _buildRouteToggleChips(),
          _buildFloatingSosButton(),
        ],
      ),
    );
  }

  /// Builds the overlay toggle chips for route visibility.
  Widget _buildRouteToggleChips() {
    return Positioned(
      top: 50,
      left: 15,
      right: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterChip(
            label: const Text('Safe Route'),
            avatar: Icon(Icons.shield_outlined, color: _showSafeRoute ? Colors.black : Colors.greenAccent),
            selected: _showSafeRoute,
            onSelected: (bool selected) {
              setState(() => _showSafeRoute = selected);
            },
            backgroundColor: Colors.black.withOpacity(0.5),
            selectedColor: Colors.greenAccent,
            labelStyle: TextStyle(color: _showSafeRoute ? Colors.black : Colors.white),
            checkmarkColor: Colors.black,
          ),
        ],
      ),
    );
  }

  /// Builds the floating SOS button with a glowing animation.
  Widget _buildFloatingSosButton() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: AvatarGlow(
        glowColor: Colors.red,
        endRadius: 45.0,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SosScreen()));
          },
          backgroundColor: Colors.red,
          shape: const CircleBorder(),
          child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}