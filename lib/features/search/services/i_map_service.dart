import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/vehicule.dart';
import '../providers/rental_period_provider.dart';

/// Interface for handling map-related operations such as fetching data,
/// updating circles, filtering vehicules, and adding custom markers.
abstract class IMapService {

  /// Fetches the list of vehicules from the vehicule service.
  ///
  /// Returns a list of [Vehicule] objects.
  Future<List<Vehicule>> fetchVehicules();

  /// Fetches the user's current location using a location service.
  ///
  /// Returns a [LatLng] object with the user's latitude and longitude,
  /// or `null` if the location cannot be fetched.
  Future<LatLng?> fetchUserLocation();

  /// Updates the transparent circles around the user's current location.
  ///
  /// [currentLatLng] is the user's current location.
  /// [walkingRadius] is the radius of the circle in meters.
  /// [opacity] sets the transparency of the circle (from 0.0 to 1.0).
  ///
  /// Returns a set of [Circle] objects to be drawn on the map.
  Set<Circle> updateCircles(LatLng currentLatLng, double walkingRadius, double opacity);

  /// Filters the list of vehicules to only those that are within the visible region
  /// of the map and available during the selected rental period.
  ///
  /// [vehicules] is the list of all vehicules.
  /// [bounds] is the visible region of the map defined by the latitude and longitude bounds.
  /// [rentalPeriodState] contains the selected rental period (start and end date).
  ///
  /// Returns a filtered list of [Vehicule] objects that meet the location and availability criteria.
  List<Vehicule> filterVisibleVehicules(List<Vehicule> vehicules, LatLngBounds bounds, RentalPeriodProvider rentalPeriodState);

  /// Checks if a vehicule is within the visible bounds of the map.
  ///
  /// [vehicule] is the vehicule to check.
  /// [bounds] defines the visible region of the map.
  ///
  /// Returns `true` if the vehicule is within bounds, `false` otherwise.
  bool isVehiculeWithinBounds(Vehicule vehicule, LatLngBounds bounds);

  /// Checks if a vehicule is available during the selected rental period.
  ///
  /// [vehicule] is the vehicule to check.
  /// [rentalPeriodState] contains the selected rental period (start and end date).
  ///
  /// Returns `true` if the vehicule is available during the rental period, `false` otherwise.
  bool isVehiculeAvailableDuringRentalPeriod(Vehicule vehicule, RentalPeriodProvider rentalPeriodState);

  /// Adds a custom marker with a label (such as "15 mins") to the map.
  ///
  /// [currentLatLng] is the user's current location.
  /// [walkingRadius] is the distance in meters to adjust the marker's position above the user's location.
  ///
  /// Returns a [Uint8List] containing the byte data of the marker icon.
  Future<Uint8List> addCustomLabelMarker(LatLng currentLatLng, double walkingRadius);
}
