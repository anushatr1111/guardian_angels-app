import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For API Key
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteAiService {
  // --- 22.2: Find Nearby Places (Hospitals, Police) ---

  /// Fetches nearby places of a specific type (e.g., "hospital", "police")
  /// around a given location.
  Future<List<LatLng>> getNearbyPlaces({
    required LatLng location,
    required String placeType,
    double radius = 5000, // 5km radius
  }) async {
    final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("❌ Error: GOOGLE_MAPS_API_KEY not found in .env");
      return []; // Return empty list
    }

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${location.latitude},${location.longitude}'
        '&radius=$radius'
        '&type=$placeType'
        '&key=$apiKey';

    print("Requesting nearby places: $placeType");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<LatLng> places = [];

        if (jsonResponse['results'] != null) {
          for (var place in jsonResponse['results']) {
            final lat = place['geometry']['location']['lat'];
            final lng = place['geometry']['location']['lng'];
            places.add(LatLng(lat, lng));
          }
        }
        print("Found ${places.length} $placeType locations.");
        return places;
      } else {
        print("❌ Places API Error: ${response.statusCode}, ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching places: $e");
      return [];
    }
  }

  // --- 22.1: Suggest Safest Route (Placeholder) ---
  
  /// Placeholder for future AI-based route analysis.
  /// For now, it might just return the primary route.
  Future<String?> getSafestRoute(LatLng origin, LatLng destination) async {
    // TODO: Implement AI logic.
    // This could involve:
    // 1. Calling Directions API for *alternative* routes.
    // 2. Sending route data (polylines, time, distance) to Gemini
    //    along with context (e.g., "it is night time").
    // 3. Gemini returns an "index" of the safest route.
    // For now, we'll just log a message.
    print("Placeholder: AI Safety analysis would happen here.");
    return null; // Placeholder
  }
}