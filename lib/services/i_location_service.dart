import 'package:geolocator/geolocator.dart';

abstract class ILocationService {
  // Future<bool> isLocationServiceEnabled();
  // Future<LocationPermission> checkAndRequestPermission();
  // Future<void> openAppSettings();
  // Future<void> openLocationSettings();
  // Future<Position> getCurrentLocation();
  Future<Position?> fetchUserLocation();

  // Add any additional methods declared in the interface
}
