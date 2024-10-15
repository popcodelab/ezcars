import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart'; // Required for BuildContext

abstract class ILocationService {
  /// Fetch the user's current location with permission and location service checks.
  /// The `context` is used for localization.
  Future<Position?> fetchUserLocation(BuildContext context);

  /// Get the place name (formatted address) based on latitude and longitude.
  /// The `context` is used for localization.
  Future<String?> getPlaceName(double latitude, double longitude, BuildContext context);
}
