import 'package:flutter/material.dart';

import '../../models/car.dart';
import '../../models/unavailability_period.dart';
import '../i_car_service.dart';

/// Service that provides a list of available cars for rental.
/// Implements the [ICarService] interface.
class CarService implements ICarService {
  
  /// Method to fetch the list of available cars.
  /// 
  /// This method returns a static list of car objects.
  /// In a real application, this could be modified to involve making a network request.
  @override
  Future<List<Car>> getCars() async {
    // Uncomment the following line to simulate a network delay.
    // await Future.delayed(const Duration(seconds: 2));

    return [
      Car(
        name: 'Tesla Model 3',
        image: 'assets/images/tesla.jpeg',
        price: '\$45/day',
        location: 'Downtown Garage',
        distance: '2.5 miles',
        lat: 34.0522,
        lng: -118.2437,
      ),
      Car(
        name: 'BMW i8',
        image: 'assets/images/bmw.jpeg',
        price: '\$120/day',
        location: 'Uptown Parking Lot',
        distance: '4.8 miles',
        lat: 34.0530,
        lng: -118.2420,
      ),
      Car(
        name: 'Audi A7',
        image: 'assets/images/audi.jpg',
        price: '\$80/day',
        location: 'Midtown Garage',
        distance: '3.2 miles',
        lat: 12.9122285,
        lng: 100.8640967,
        unavailabilityPeriods: [
          UnavailabilityPeriod(
            startDate: DateTime(2024, 11, 1),
            startTime: const TimeOfDay(hour: 10, minute: 0),
            endDate: DateTime(2024, 11, 10),
            endTime: const TimeOfDay(hour: 18, minute: 0),
          ),
        ],
      ),
      Car(
        name: 'Mercedes G63',
        image: 'assets/images/g63.png',
        price: '\$80/day',
        location: 'Midtown Garage',
        distance: '3.2 miles',
        lat: 12.9222285,
        lng: 100.8640967,
      ),
      Car(
        name: 'Toyota Hilux',
        image: 'assets/images/hilux.jpg',
        price: '\$180/day',
        location: 'Midtown Garage',
        distance: '3.2 miles',
        lat: 37.4519983,
        lng: -122.1234,
        unavailabilityPeriods: [
          UnavailabilityPeriod(
            startDate: DateTime(2024, 11, 1),
            startTime: const TimeOfDay(hour: 10, minute: 0),
            endDate: DateTime(2024, 11, 10),
            endTime: const TimeOfDay(hour: 18, minute: 0),
          ),
        ],
      ),
      Car(
        name: 'MG 5',
        image: 'assets/images/mg5.jpg',
        price: '\$180/day',
        location: 'Midtown Garage',
        distance: '3.2 miles',
        lat: 37.4219983,
        lng: -122.084,
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
}
