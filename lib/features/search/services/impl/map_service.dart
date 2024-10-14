import 'dart:async';
import 'dart:typed_data';

import 'package:ezcars/features/search/services/i_map_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import '../../models/vehicule.dart';
import '../../providers/rental_period_provider.dart';
import '../i_vehicule_service.dart';
import '../i_location_service.dart';
import '../i_map_circle_label_service.dart';
import '../i_map_transparent_circle_service.dart';

/// `MapService` is responsible for managing map-related features such as:
/// - Fetching vehicles
/// - Fetching the user's location
/// - Managing circles on the map
/// - Filtering vehicles based on visibility and availability during a rental period
class MapService implements IMapService {
  final IVehiculeService carService;
  final ILocationService locationService;
  final IMapCircleLabelService mapCircleLabelService;
  final IMapTransparentCircleService circlesService;

  /// Caches the list of vehicles to avoid repeated fetching from the service.
  List<Vehicule>? _cachedVehicules;

  MapService({
    required this.carService,
    required this.locationService,
    required this.mapCircleLabelService,
    required this.circlesService,
  });

  /// Fetches the list of vehicles from the `carService`.
  /// Caches the result to improve performance.
  /// Handles any errors by logging or returning an empty list.
  @override
  Future<List<Vehicule>> fetchVehicules() async {
    // Return cached vehicles if available
    if (_cachedVehicules != null) {
      return _cachedVehicules!;
    }

    try {
      final vehicules = await carService.getCars();
      _cachedVehicules = vehicules; // Cache the fetched vehicles
      return vehicules;
    } catch (e) {
      // Handle the error (logging or showing a message)
      print("Error fetching vehicles: $e");
      return []; // Return an empty list if an error occurs
    }
  }

  /// Fetches the current location of the user.
  /// Returns a `LatLng` object or `null` if the location could not be fetched.
  /// Handles potential errors by returning null.
  @override
  Future<LatLng?> fetchUserLocation() async {
    try {
      final position = await locationService.fetchUserLocation();
      if (position != null) {
        return LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      // Handle the error (logging or showing a message)
      print("Error fetching user location: $e");
    }
    return null; // Return null if an error occurs or position is not available
  }

  /// Updates the map with a transparent circle centered at `currentLatLng`
  /// with a radius specified by `walkingRadius`.
  /// Returns a set of circles to be added to the map.
  @override
  Set<Circle> updateCircles(
      LatLng currentLatLng, double walkingRadius, double opacity) {
    return circlesService.createTransparentCircle(
      center: currentLatLng,
      radiusInMeters: walkingRadius,
      opacity: opacity,
      fillColor: Colors.green,
      strokeWidth: 2,
      strokeColor: Colors.greenAccent,
    );
  }

  /// Filters visible vehicles within the specified map bounds (`LatLngBounds`).
  /// Additionally filters vehicles that are available during the selected rental period
  /// in the `RentalPeriodProvider`.
  @override
  List<Vehicule> filterVisibleVehicules(
      List<Vehicule> vehicules, LatLngBounds bounds, RentalPeriodProvider rentalPeriodState) {
    return vehicules.where((vehicule) {
      bool isWithinBounds = isVehiculeWithinBounds(vehicule, bounds);

      // If rental period isn't set, only filter by bounds.
      if (rentalPeriodState.startDate == null || rentalPeriodState.endDate == null) {
        return isWithinBounds;
      }

      bool isAvailable = isVehiculeAvailableDuringRentalPeriod(vehicule, rentalPeriodState);
      return isWithinBounds && isAvailable;
    }).toList();
  }

  /// Checks if a given vehicle is within the visible map bounds.
  bool isVehiculeWithinBounds(Vehicule vehicule, LatLngBounds bounds) {
    return vehicule.lat >= bounds.southwest.latitude &&
        vehicule.lat <= bounds.northeast.latitude &&
        vehicule.lng >= bounds.southwest.longitude &&
        vehicule.lng <= bounds.northeast.longitude;
  }

  /// Checks if a vehicle is available during the selected rental period.
  bool isVehiculeAvailableDuringRentalPeriod(Vehicule vehicule, RentalPeriodProvider rentalPeriodState) {
    DateTime selectedStartDate = rentalPeriodState.startDate!;
    DateTime selectedEndDate = rentalPeriodState.endDate!;

    // Return false if any unavailability period overlaps with the rental period.
    return !vehicule.unavailabilityPeriods.any((period) {
      return selectedStartDate.isBefore(period.endDate) &&
          selectedEndDate.isAfter(period.startDate);
    });
  }

  /// Adds a custom marker to the map, typically representing walking time or a label.
  /// Returns a `Uint8List` representing the marker icon.
  @override
  Future<Uint8List> addCustomLabelMarker(
      LatLng currentLatLng, double walkingRadius) async {
    // Calculates new latitude based on walking radius
    final double newLatitude = currentLatLng.latitude + (walkingRadius / 111000.0);

    const Size markerSize = Size(150, 60); // Size of the marker

    // Creates a custom marker using the `mapCircleLabelService`
    return await mapCircleLabelService.createCustomMarker('15 mins', markerSize);
  }
}
