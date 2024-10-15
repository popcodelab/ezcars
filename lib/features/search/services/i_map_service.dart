import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/vehicle.dart';
import '../providers/rental_period_provider.dart';

/// Interface for handling map-related operations such as fetching data,
/// updating circles, filtering vehicles, and adding custom markers.
abstract class IMapService {

  /// Fetches the list of vehicles from the vehicle service.
  ///
  /// Returns a list of [Vehicle] objects.
  Future<List<Vehicle>> fetchVehicules();

  /// Fetches the user's current location using a location service.
  ///
  /// Returns a [LatLng] object with the user's latitude and longitude,
  /// or `null` if the location cannot be fetched.
  Future<LatLng?> fetchUserLocation(BuildContext context);

  /// Updates the transparent circles around the user's current location.
  ///
  /// [currentLatLng] is the user's current location.
  /// [walkingRadius] is the radius of the circle in meters.
  /// [opacity] sets the transparency of the circle (from 0.0 to 1.0).
  ///
  /// Returns a set of [Circle] objects to be drawn on the map.
  Set<Circle> updateCircles(LatLng currentLatLng, double walkingRadius, double opacity);

  /// Filters the list of vehicles to only those that are within the visible region
  /// of the map and available during the selected rental period.
  ///
  /// [vehicles] is the list of all vehicles.
  /// [bounds] is the visible region of the map defined by the latitude and longitude bounds.
  /// [rentalPeriodState] contains the selected rental period (start and end date).
  ///
  /// Returns a filtered list of [Vehicle] objects that meet the location and availability criteria.
  List<Vehicle> filterVisibleVehicules(List<Vehicle> vehicles, LatLngBounds bounds, RentalPeriodProvider rentalPeriodState);

  /// Checks if a vehicle is within the visible bounds of the map.
  ///
  /// [vehicle] is the vehicle to check.
  /// [bounds] defines the visible region of the map.
  ///
  /// Returns `true` if the vehicle is within bounds, `false` otherwise.
  bool isVehiculeWithinBounds(Vehicle vehicle, LatLngBounds bounds);

  /// Checks if a vehicle is available during the selected rental period.
  ///
  /// [vehicle] is the vehicle to check.
  /// [rentalPeriodState] contains the selected rental period (start and end date).
  ///
  /// Returns `true` if the vehicle is available during the rental period, `false` otherwise.
  bool isVehiculeAvailableDuringRentalPeriod(Vehicle vehicle, RentalPeriodProvider rentalPeriodState);

  /// Adds a custom marker with a label (such as "15 mins") to the map.
  ///
  /// [currentLatLng] is the user's current location.
  /// [walkingRadius] is the distance in meters to adjust the marker's position above the user's location.
  ///
  /// Returns a [Uint8List] containing the byte data of the marker icon.
  Future<Uint8List> addCustomLabelMarker(LatLng currentLatLng, double walkingRadius);
}
