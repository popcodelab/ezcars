import 'unavailability_period.dart';
// Defines a car
class Car {
  final String name;
  final String image;
  final String price;
  final String location;
  final String distance;
  final double lat;
  final double lng;
  final List<UnavailabilityPeriod> unavailabilityPeriods;

  Car({
    required this.name,
    required this.image,
    required this.price,
    required this.location,
    required this.distance,
    required this.lat,
    required this.lng,
    this.unavailabilityPeriods = const [], // Default to empty list
  });
}

