import 'dart:async';
import 'dart:math'; // For min()
import 'dart:ui' as ui;
import 'package:aura_safe_app/services/directions_service.dart';
import 'package:aura_safe_app/services/route_ai_service.dart'; // Import new service
import 'package:aura_safe_app/screens/sos_screen.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Import for polyline decoding
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // --- Services ---
  final Location _locationController = Location();
  final DirectionsService _directionsService = DirectionsService();
  final RouteAiService _routeAiService = RouteAiService(); // New service
  final PolylinePoints _polylinePoints = PolylinePoints(); // Polyline decoder

  // --- Controllers ---
  GoogleMapController? _mapController;
  StreamSubscription<LocationData>? _locationSubscription;

  // --- Map State Variables ---
  final Set<Polyline> _polylines = {};
  LatLng? _userLocation;

  // --- Marker State (Refactored) ---
  BitmapDescriptor? _userMarkerIcon;
  BitmapDescriptor? _hospitalMarkerIcon;
  BitmapDescriptor? _policeMarkerIcon;
  Marker? _userMarker;
  Marker? _destinationMarker;
  final Set<Marker> _hospitalMarkers = {};
  final Set<Marker> _policeMarkers = {};

  // --- Toggle State ---
  bool _showSafeRoute = true;
  bool _showHospitals = true; // Step 22.2 state
  bool _showPolice = true; // Step 22.2 state
  bool _safetyPlacesLoaded = false; // Track if we've fetched places

  // --- Getter to combine all visible markers ---
  Set<Marker> get _allMarkers {
    final Set<Marker> markers = {};
    if (_userMarker != null) markers.add(_userMarker!);
    if (_destinationMarker != null) markers.add(_destinationMarker!);
    if (_showHospitals) markers.addAll(_hospitalMarkers);
    if (_showPolice) markers.addAll(_policeMarkers);
    return markers;
  }

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(9.4674, 77.9622), // Virudhunagar
    zoom: 5.0,
  );

  @override
  void initState() {
    super.initState();
    // Load all custom marker icons first
    _createCustomMarkers().then((_) {
      _listenToLocationChanges(); // Then start listening for location
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  // --- Route Drawing ---
  Future<void> _drawRoute(LatLng destination) async {
    if (_userLocation == null) {
      print("⚠️ Cannot draw route: User location unknown.");
      return;
    }

    print("🚗 Requesting route from ${_userLocation!} to $destination");
    final String? polylineString =
        await _directionsService.getDirections(_userLocation!, destination);

    if (polylineString != null) {
      print("✅ Route received: Polyline string (starts with): ${polylineString.substring(0, min(50, polylineString.length))}...");

      // --- CORRECTED POLYLINE DECODING ---
      List<PointLatLng> result = _polylinePoints.decodePolyline(polylineString);
      final List<LatLng> pointCoordinates = result
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      // --- END CORRECTION ---

      if (pointCoordinates.isNotEmpty) {
        final safeRoute = Polyline(
          polylineId: const PolylineId('safe_route'),
          color: Colors.greenAccent, // Step 22.3 Color-coded map (route)
          width: 5,
          points: pointCoordinates,
        );
        setState(() => _polylines.add(safeRoute));
      }
    } else {
      print("❌ Route request failed.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not fetch route. Check API key/billing/network?'),
              backgroundColor: Colors.orangeAccent),
        );
      }
    }
  }

  void _onMapTapped(LatLng destination) {
    print("🗺️ Map Tapped at: ${destination.latitude}, ${destination.longitude}");
    setState(() {
      _polylines.clear(); // Clear old route
      _destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    });
    _drawRoute(destination);
    // Optionally: fetch safety places around the *destination*
    _fetchNearbySafetyPlaces(destination);
  }

  // --- Marker & Place Loading ---

  Future<void> _createCustomMarkers() async {
    // Load all icons concurrently
    try {
      final [userIcon, hospitalIcon, policeIcon] = await Future.wait([
        _getBytesFromAsset('assets/user_pin.png', 150),
        _getBytesFromAsset('assets/hospital_pin.png', 100), // Smaller icon
        _getBytesFromAsset('assets/police_pin.png', 100), // Smaller icon
      ]);
      _userMarkerIcon = BitmapDescriptor.fromBytes(userIcon);
      _hospitalMarkerIcon = BitmapDescriptor.fromBytes(hospitalIcon);
      _policeMarkerIcon = BitmapDescriptor.fromBytes(policeIcon);
    } catch (e) {
      print("🚨 Error creating custom marker: $e. Make sure 'user_pin.png', 'hospital_pin.png', and 'police_pin.png' are in assets/ and pubspec.yaml");
    }
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    final byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Unable to convert image to ByteData');
    }
    return byteData.buffer.asUint8List();
  }

  // --- 22.2: Fetch Nearby Safety Places ---
  Future<void> _fetchNearbySafetyPlaces(LatLng location) async {
    if (_hospitalMarkerIcon == null || _policeMarkerIcon == null) {
      print("⚠️ Skipping place search: Marker icons not loaded.");
      return;
    }
    
    // Fetch hospitals and police stations concurrently
    try {
      final [hospitalLocations, policeLocations] = await Future.wait([
        _routeAiService.getNearbyPlaces(location: location, placeType: 'hospital'),
        _routeAiService.getNearbyPlaces(location: location, placeType: 'police'),
      ]);

      // Create hospital markers
      final Set<Marker> hospitalMarkers = hospitalLocations.map((latLng) {
        final id = 'hospital_${latLng.latitude}_${latLng.longitude}';
        return Marker(
          markerId: MarkerId(id),
          position: latLng,
          icon: _hospitalMarkerIcon!,
          anchor: const Offset(0.5, 0.5),
        );
      }).toSet();

      // Create police markers
      final Set<Marker> policeMarkers = policeLocations.map((latLng) {
        final id = 'police_${latLng.latitude}_${latLng.longitude}';
        return Marker(
          markerId: MarkerId(id),
          position: latLng,
          icon: _policeMarkerIcon!,
          anchor: const Offset(0.5, 0.5),
        );
      }).toSet();

      setState(() {
        _hospitalMarkers.addAll(hospitalMarkers);
        _policeMarkers.addAll(policeMarkers);
        _safetyPlacesLoaded = true; // Mark as loaded
      });

    } catch (e) {
      print("🚨 Error fetching nearby places in parallel: $e");
    }
  }

  Future<void> _listenToLocationChanges() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    try {
       serviceEnabled = await _locationController.serviceEnabled();
       if (!serviceEnabled) {
         serviceEnabled = await _locationController.requestService();
         if (!serviceEnabled) {
             print("Location service disabled by user.");
             return;
          }
       }
       permissionGranted = await _locationController.hasPermission();
       if (permissionGranted == PermissionStatus.denied) {
         permissionGranted = await _locationController.requestPermission();
         if (permissionGranted != PermissionStatus.granted) {
            print("Location permission denied by user.");
            return;
         }
       }
       
       if (permissionGranted == PermissionStatus.granted) {
         _locationSubscription = _locationController.onLocationChanged.listen((LocationData currentLocation) {
           if (currentLocation.latitude != null && currentLocation.longitude != null) {
             _userLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
             print("📍 Location Update: ${_userLocation!.latitude}, ${_userLocation!.longitude}");

             _mapController?.animateCamera(
               CameraUpdate.newCameraPosition(
                 CameraPosition(target: _userLocation!, zoom: 16.0),
               ),
             );
             _updateUserMarker(_userLocation!);

             // Fetch nearby places ONCE on first location fix
             if (!_safetyPlacesLoaded) {
                _fetchNearbySafetyPlaces(_userLocation!);
             }
           }
         });
       }
    } catch (e) {
       print("Error setting up location listener: $e");
    }
  }

  void _updateUserMarker(LatLng position) {
    if (!mounted || _userMarkerIcon == null) return;
    
    setState(() {
      _userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: position,
        icon: _userMarkerIcon!,
        anchor: const Offset(0.5, 0.5),
      );
    });
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
              // Attempt to move camera to current location once map is created, if available
              if (_userLocation != null) {
                 controller.animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 16.0));
              }
            },
            onTap: _onMapTapped,
            polylines: _showSafeRoute ? _polylines : {},
            markers: _allMarkers, // Use the getter to show all visible markers
            myLocationEnabled: false,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            padding: const EdgeInsets.only(top: 100.0), // Padding for toggle chips
          ),
          _buildRouteToggleChips(), // Step 22.3
          _buildFloatingSosButton(),
        ],
      ),
    );
  }

  // --- 22.3: Updated Toggle Chips ---
  Widget _buildRouteToggleChips() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleChip(
              label: 'Safe Route',
              icon: Icons.shield_outlined,
              selected: _showSafeRoute,
              selectedColor: Colors.greenAccent,
              onSelected: (selected) => setState(() => _showSafeRoute = selected),
            ),
            const SizedBox(width: 8),
            _buildToggleChip(
              label: 'Hospitals',
              icon: Icons.local_hospital,
              selected: _showHospitals,
              selectedColor: Colors.blueAccent,
              onSelected: (selected) => setState(() => _showHospitals = selected),
            ),
            const SizedBox(width: 8),
            _buildToggleChip(
              label: 'Police',
              icon: Icons.local_police,
              selected: _showPolice,
              selectedColor: Colors.indigoAccent,
              onSelected: (selected) => setState(() => _showPolice = selected),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for creating consistent toggle chips
  Widget _buildToggleChip({
    required String label,
    required IconData icon,
    required bool selected,
    required Color selectedColor,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, color: selected ? Colors.black : selectedColor),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.black.withOpacity(0.5),
      selectedColor: selectedColor,
      labelStyle: TextStyle(color: selected ? Colors.black : Colors.white),
      checkmarkColor: Colors.black,
    );
  }

  Widget _buildFloatingSosButton() {
    // ... (This widget is the same as before) ...
    return Positioned(
      bottom: 30,
      right: 20,
      child: AvatarGlow(
        glowColor: Colors.red,
        endRadius: 45.0, // Use 'radius' for newer package versions
        // endRadius: 45.0, // Use 'endRadius' if you have an older version
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