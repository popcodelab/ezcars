
import 'unavailability_period.dart';

base class Vehicle {
  final String model;
  final String imageUrl;
  final String price;
  final String location;
  final String distance;
  final double latitude;
  final double longitude;
  final List<UnavailabilityPeriod> unavailabilityPeriods;
  final String type;
  Vehicle({
    required this.model,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.distance,
    required this.latitude,
    required this.longitude,
    this.unavailabilityPeriods = const [], // Default to empty list
    required this.type // electric, gas, or any other type.
  });
}