import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DirectionsService {
  /// Fetches route information between two points from the Google Directions API.
  /// Returns an encoded polyline string on success, or null on failure.
  Future<String?> getDirections(LatLng origin, LatLng destination) async {
    // Get API key from .env file
    final String? googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (googleApiKey == null || googleApiKey.isEmpty) {
      print('❌ Error: Google Maps API Key is missing in .env file!');
      return null;
    }

    // Construct the URL for the API request.
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey';

    try {
      // Make the HTTP GET request.
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful (status code 200).
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Check if the API returned any routes.
        if (jsonResponse['routes'] != null &&
            jsonResponse['routes'].isNotEmpty) {
          // Extract the encoded polyline string from the first route.
          // This string contains all the points needed to draw the route line.
          final String polyline =
              jsonResponse['routes'][0]['overview_polyline']['points'];
          return polyline;
        } else {
          // Handle cases where Google can't find a route.
          print('Directions API Error: ${jsonResponse['status']}');
          return null;
        }
      } else {
        print(
          'Failed to fetch directions. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      // Handle network errors or other exceptions.
      print('An error occurred while fetching directions: $e');
      return null;
    }
  }
}