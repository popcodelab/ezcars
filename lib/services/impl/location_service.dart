import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart'; // To access BuildContext
import '../i_location_service.dart';
import '../../keys.dart'; // API keys
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocationService implements ILocationService {

  /// Consolidated function to check permissions and fetch the user's current location
  @override
  Future<Position?> fetchUserLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await _isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Return localized error message if location services are disabled
        return Future.error(AppLocalizations.of(context)?.location_services_disabled ?? 'Location services are disabled.');
      }

      LocationPermission permission = await _checkAndRequestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Return localized error message if permissions are permanently denied
        return Future.error(AppLocalizations.of(context)?.location_permissions_permanently_denied ?? 'Location permissions are permanently denied.');
      }

      if (permission == LocationPermission.denied) {
        // Return localized error message if permissions are denied
        return Future.error(AppLocalizations.of(context)?.location_permissions_denied ?? 'Location permission denied.');
      }

      // Fetch the user's current location if permissions are granted
      return await _getCurrentLocation();
    } catch (e) {
      log('Error while fetching user location: $e');
      // Return localized general failure message
      return Future.error(AppLocalizations.of(context)?.error_fetching_location ?? 'Failed to fetch location.');
    }
  }

  /// Fetch the place name (formatted address) using latitude and longitude
  Future<String?> getPlaceName(double latitude, double longitude, BuildContext context) async {
    final String apiKey = Platform.isAndroid ? APIKeys.androidPlacesApiKey : APIKeys.iosApiKey;
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final jsonResponse = await _makeApiRequest(url, context);

    if (jsonResponse != null && jsonResponse['results'].isNotEmpty) {
      final placeName = jsonResponse['results'][0]['formatted_address'];
      return placeName;
    } else {
      log('No results found for coordinates: ($latitude, $longitude)');
      return AppLocalizations.of(context)?.no_results_for_coordinates ?? 'No address found';
    }
  }

  /// Helper function to make API requests and handle network errors
  Future<Map<String, dynamic>?> _makeApiRequest(String url, BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        log('API request failed with status code: ${response.statusCode}');
        return null;
      }
    } on SocketException {
      log('Network error. Please check your connection.');
      return Future.error(AppLocalizations.of(context)?.network_error ?? 'Network error.');
    } catch (e) {
      log('Unexpected error during API request: $e');
      return null;
    }
  }

  // Helper functions for location service and permissions
  Future<bool> _isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> _checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
