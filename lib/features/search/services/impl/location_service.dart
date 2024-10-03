
import 'package:geolocator/geolocator.dart';

import '../i_location_service.dart';

class LocationService implements ILocationService {
  // Consolidated function to check permissions and fetch the user's current location
  @override
  Future<Position?> fetchUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await _isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _openLocationSettings();
        return null;
      }

      // Request permissions for location access
      LocationPermission permission = await _checkAndRequestPermission();
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return null;
      }

      if (permission == LocationPermission.denied) {
        return null;
      }

      // Fetch the user's current location if permissions are granted
      return await _getCurrentLocation();
    } catch (e) {
      // You can log the error or handle it as needed
      return null;
    }
  }

  // Original helper functions for individual steps

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

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
