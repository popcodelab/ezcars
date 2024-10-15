import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/unavailability_period.dart';
import '../../models/vehicle.dart';
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

    return [
      Vehicle(
        model: 'Tesla Model 3',
        imageUrl: 'assets/images/vehicles/cars/tesla.jpeg',
        price: '\$45/day',
        location: 'Downtown Garage',
        distance: '2.5 miles',
        latitude: 34.0522,
        longitude: -118.2437,
      ),
      Vehicle(
        model: 'BMW i8',
        imageUrl: 'assets/images/vehicles/cars/bmw.jpeg',
        price: '\$120/day',
        location: 'Uptown Parking Lot',
        distance: '4.8 miles',
        latitude: 34.0530,
        longitude: -118.2420,
      ),
      Vehicle(
        model: 'Audi A7',
        imageUrl: 'assets/images/vehicles/cars/audi.jpg',
        price: '\$80/day',
        location: 'Midtown Garage',
        distance: '3.2 miles',
        latitude: 12.9122285,
        longitude: 100.8640967,
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
        model: 'Mercedes G63',
        imageUrl: 'assets/images/vehicles/cars/g63.png',
        price: '\$80/day',
        location: 'Midtown Garage',
        distance: '3.2 miles',
        latitude: 12.9222285,
        longitude: 100.8640967,
      ),
      Vehicle(
        model: 'Toyota Hilux',
        imageUrl: 'assets/images/vehicles/cars/hilux.jpg',
        price: '\$180/day',
        location: 'Midtown Garage',
        distance: '3.2 miles',
        latitude: 37.4519983,
        longitude: -122.1234,
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
        distance: '3.2 miles',
        latitude: 37.4219983,
        longitude: -122.084,
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
    ];
  }

  /// Filters vehicles by proximity to the user's location within a given radius.
  @override
  Future<List<Vehicle>> filterVehiclesByProximity(
      List<Vehicle> vehicles, Position userPosition, double radius) async {
    return vehicles.where((vehicle) {
      final distance = _calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        vehicle.latitude,
        vehicle.longitude,
      );
      return distance <= radius;
    }).toList();
  }

  /// Calculate the distance between two lat/lon coordinates using the Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusMeters = 6371000; // Radius of the Earth in meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c; // Distance in meters
  }

  /// Helper function to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}