import 'dart:async';
import 'dart:typed_data';

import 'package:ezcars/features/search/services/i_map_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import '../../models/car.dart';
import '../../providers/rental_period_provider.dart';
import '../i_car_service.dart';
import '../i_location_service.dart';
import '../i_map_circle_label_service.dart';
import '../i_map_transparent_circle_service.dart';

class MapService  implements IMapService{
  final ICarService carService;
  final ILocationService locationService;
  final IMapCircleLabelService mapCircleLabelService;
  final IMapTransparentCircleService circlesService;

  MapService({
    required this.carService,
    required this.locationService,
    required this.mapCircleLabelService,
    required this.circlesService,
  });

  Future<List<Car>> fetchCars() async {
    return await carService.getCars();
  }

  Future<LatLng?> fetchUserLocation() async {
    final position = await locationService.fetchUserLocation();
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    }
    return null;
  }

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

  List<Car> filterVisibleCars(
      List<Car> cars, LatLngBounds bounds, RentalPeriodProvider rentalPeriodState) {
    return cars.where((car) {
      bool isWithinBounds = isCarWithinBounds(car, bounds);
      if (rentalPeriodState.startDate == null ||
          rentalPeriodState.endDate == null) {
        return isWithinBounds;
      }
      bool isAvailable = isCarAvailableDuringRentalPeriod(car, rentalPeriodState);
      return isWithinBounds && isAvailable;
    }).toList();
  }

  bool isCarWithinBounds(Car car, LatLngBounds bounds) {
    return car.lat >= bounds.southwest.latitude &&
        car.lat <= bounds.northeast.latitude &&
        car.lng >= bounds.southwest.longitude &&
        car.lng <= bounds.northeast.longitude;
  }

  bool isCarAvailableDuringRentalPeriod(Car car, RentalPeriodProvider rentalPeriodState) {
    DateTime selectedStartDate = rentalPeriodState.startDate!;
    DateTime selectedEndDate = rentalPeriodState.endDate!;

    return !car.unavailabilityPeriods.any((period) {
      return selectedStartDate.isBefore(period.endDate) &&
          selectedEndDate.isAfter(period.startDate);
    });
  }

  Future<Uint8List> addCustomLabelMarker(
      LatLng currentLatLng, double walkingRadius) async {
    final double newLatitude = currentLatLng.latitude + (walkingRadius / 111000.0);
    const Size markerSize = Size(150, 60);

    return await mapCircleLabelService.createCustomMarker('15 mins', markerSize);
  }
}
