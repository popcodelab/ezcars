import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/unavailability_period.dart';
import '../../models/vehicle.dart';
import '../../providers/walking_radiius_provider.dart';
import '../i_vehicle_service.dart';

import 'dart:math'; // For distance calculations

/// Service that provides a list of available vehicles for rental.
/// Implements the [IVehicleService] interface.
class VehicleService implements IVehicleService {
  /// Method to fetch the list of available vehicles.
  ///
  /// This method returns a static list of vehicle objects.
  /// In a real application, this could be modified to involve making a network request.
  @override
  Future<List<Vehicle>> getVehicles() async {
    // Uncomment the following line to simulate a network delay.
    // await Future.delayed(const Duration(seconds: 2));

    var result = [
      Vehicle(
        model: 'BMW i8',
        imageUrl: 'assets/images/vehicles/cars/bmw.jpeg',
        price: '\$120/day',
        location: 'Uptown Parking Lot',
        distance: 0,
        latitude: 34.0530,
        longitude: -118.2420,
        type: 'gas', // Gas-powered vehicle
      ),
      Vehicle(
        model: 'Audi A7',
        imageUrl: 'assets/images/vehicles/cars/audi.jpg',
        price: '\$80/day',
        location: 'Midtown Garage',
        distance: 0,
        latitude: 12.9122285,
        longitude: 100.8640967,
        type: 'gas', // Gas-powered vehicle
        unavailabilityPeriods: [
          UnavailabilityPeriod(
            startDate: DateTime(2024, 11, 1),
            startTime: const TimeOfDay(hour: 10, minute: 0),
            endDate: DateTime(2024, 11, 10),
            endTime: const TimeOfDay(hour: 18, minute: 0),
          ),
        ],
      ),
      Vehicle(
        model: 'Chevrolet Corvette 2024',
        imageUrl: 'assets/images/vehicles/cars/corvette.png',
        price: '\$250/day',
        location: 'Midtown Garage',
        distance: 0,
        latitude: 12.9622,
        longitude: 100.8940967,
        type: 'gas', // Gas-powered vehicle
      ),
      Vehicle(
        model: 'Porsche 911',
        imageUrl: 'assets/images/vehicles/cars/porsche911.png',
        price: '\$250/day',
        location: 'Midtown Garage',
        distance: 0,
        latitude: 12.8722,
        longitude: 100.9010967,
        type: 'gas', // Gas-powered vehicle
      ),
      Vehicle(
        model: 'Mercedes G63',
        imageUrl: 'assets/images/vehicles/cars/g63.png',
        price: '\$80/day',
        location: 'Midtown Garage',
        distance: 0,
        latitude: 12.9222285,
        longitude: 100.8640967,
        type: 'gas', // Gas-powered vehicle
      ),
      Vehicle(
        model: 'Toyota Hilux',
        imageUrl: 'assets/images/vehicles/cars/hilux.jpg',
        price: '\$180/day',
        location: 'Midtown Garage',
        distance: 0,
        latitude: 37.4519983,
        longitude: -122.1234,
        type: 'gas', // Gas-powered vehicle
        unavailabilityPeriods: [
          UnavailabilityPeriod(
            startDate: DateTime(2024, 11, 1),
            startTime: const TimeOfDay(hour: 10, minute: 0),
            endDate: DateTime(2024, 11, 10),
            endTime: const TimeOfDay(hour: 18, minute: 0),
          ),
        ],
      ),
      Vehicle(
        model: 'MG 5',
        imageUrl: 'assets/images/vehicles/cars/mg5.jpg',
        price: '\$180/day',
        location: 'Midtown Garage',
        distance: 0,
        latitude: 37.4219983,
        longitude: -122.184,
        type: 'gas', // Gas-powered vehicle
        unavailabilityPeriods: [
          UnavailabilityPeriod(
            startDate: DateTime(2024, 10, 15),
            startTime: const TimeOfDay(hour: 8, minute: 0),
            endDate: DateTime(2024, 10, 20),
            endTime: const TimeOfDay(hour: 18, minute: 0),
          ),
          UnavailabilityPeriod(
            startDate: DateTime(2024, 10, 25),
            startTime: const TimeOfDay(hour: 9, minute: 0),
            endDate: DateTime(2024, 10, 30),
            endTime: const TimeOfDay(hour: 17, minute: 0),
          ),
        ],
      ),
      Vehicle(
        model: 'Tesla Model 3',
        imageUrl: 'assets/images/vehicles/cars/tesla.jpeg',
        price: '\$45/day',
        location: 'Downtown Garage',
        distance: 0,
        latitude: 37.409983,
        longitude: -122.060,
        type: 'electric', // Electric vehicle
      ),
    ];
    return result;
  }

  /// Calculate distances for all vehicles from the user's current location.
  Future<List<Vehicle>> calculateVehicleDistances(
      List<Vehicle> vehicles, Position userPosition,
      {String unit = 'miles'}) async {
    return vehicles.map((vehicle) {
      double distanceInMeters = _calculateDistanceBetween2Objects(
        userPosition.latitude,
        userPosition.longitude,
        vehicle.latitude,
        vehicle.longitude,
      );

      vehicle.distance = _convertDistance(
          distanceInMeters, unit); // Set the distance in the required unit
      return vehicle;
    }).toList();
  }

  /// Filters vehicles based on proximity and returns only those within the walking radius.
  Future<List<Vehicle>> filterVehiclesByProximity(List<Vehicle> vehicles,
      Position userPosition, WalkingRadiusProvider radiusProvider,
      {String unit = 'miles'}) async {
    double radius = radiusProvider.walkingRadius;

    return vehicles.where((vehicle) {
      double distanceInMeters = _calculateDistanceBetween2Objects(
        userPosition.latitude,
        userPosition.longitude,
        vehicle.latitude,
        vehicle.longitude,
      );

      vehicle.distance =
          _convertDistance(distanceInMeters, unit); // Calculate distance

      return distanceInMeters <= radius; // Filter by radius
    }).toList();
  }

  /// Helper function to calculate the distance between two points using Haversine formula
  double _calculateDistanceBetween2Objects(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusMeters = 6371000;
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Convert meters to the desired unit (miles or kilometers)
  double _convertDistance(double distanceInMeters, String unit) {
    if (unit == 'miles') {
      return distanceInMeters / 1609.34;
    } else if (unit == 'kilometers') {
      return distanceInMeters / 1000;
    }
    return distanceInMeters; // Default to meters if unit not specified
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
