import 'package:ezcars/features/search/models/vehicule.dart';
import 'package:ezcars/features/search/models/unavailability_period.dart';
import 'package:ezcars/features/search/providers/rental_period_provider.dart';
import 'package:ezcars/features/search/services/i_map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'map_service_test.mocks.dart';

/// Generates mock classes for IMapService using Mockito
@GenerateMocks([IMapService])
void main() {
  late MockIMapService mockMapService; // Mocked instance of the IMapService
  late RentalPeriodProvider rentalPeriodProvider; // Provider to simulate rental period states

  /// Setup runs before each test case to initialize mocks and objects
  setUp(() {
    mockMapService = MockIMapService();
    rentalPeriodProvider = RentalPeriodProvider();
  });

  group('MapService Tests', () {

    /// Test: isCarWithinBounds checks whether a vehicule is within map bounds
    test('isCarWithinBounds identifies if a vehicule is inside bounds', () {
      // Arrange: Define map bounds and a vehicule within those bounds
      final bounds = LatLngBounds(
        southwest: LatLng(34.0, -119.0), // Bottom-left corner
        northeast: LatLng(35.0, -117.0), // Top-right corner
      );
      final vehicule = Vehicule(
        name: 'Tesla Model 3',
        image: 'image_url',
        price: '\$100/day',
        location: 'Los Angeles',
        distance: '5 miles away',
        lat: 34.5,
        lng: -118.0, // Inside bounds
      );

      // Stub the isCarWithinBounds method to return true for vehicules within bounds
      when(mockMapService.isVehiculeWithinBounds(any, any)).thenAnswer((invocation) {
        final Vehicule vehicule = invocation.positionalArguments[0];
        final LatLngBounds bounds = invocation.positionalArguments[1];
        return vehicule.lat >= bounds.southwest.latitude &&
            vehicule.lat <= bounds.northeast.latitude &&
            vehicule.lng >= bounds.southwest.longitude &&
            vehicule.lng <= bounds.northeast.longitude;
      });

      // Act: Call the isCarWithinBounds method
      final isWithinBounds = mockMapService.isVehiculeWithinBounds(vehicule, bounds);

      // Assert: Ensure the vehicule is identified as being inside the bounds
      expect(isWithinBounds, true);
    });

    /// Test: isCarAvailableDuringRentalPeriod verifies if a vehicule is available during the rental period
    test('isCarAvailableDuringRentalPeriod returns true if vehicule is available', () {
      // Arrange: Define unavailability period for the vehicule
      final unavailabilityPeriod = UnavailabilityPeriod(
        startDate: DateTime(2024, 10, 15),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endDate: DateTime(2024, 10, 20),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      );

      final vehicule = Vehicule(
        name: 'Tesla Model S',
        image: 'image_url',
        price: '\$150/day',
        location: 'Santa Monica',
        distance: '10 miles away',
        lat: 34.5,
        lng: -118.0,
        unavailabilityPeriods: [unavailabilityPeriod],
      );

      // Set rental period that doesn't overlap with the vehicule's unavailability
      rentalPeriodProvider.updateDates(
        startDate: DateTime(2024, 10, 10),
        endDate: DateTime(2024, 10, 14),
        startTime: DateTime(2024, 10, 10, 10, 0),
        endTime: DateTime(2024, 10, 14, 18, 0),
      );

      // Stub the isCarAvailableDuringRentalPeriod method
      when(mockMapService.isVehiculeAvailableDuringRentalPeriod(any, any)).thenAnswer((invocation) {
        final Vehicule vehicule = invocation.positionalArguments[0];
        final RentalPeriodProvider rentalPeriod = invocation.positionalArguments[1];
        final DateTime? startDate = rentalPeriod.startDate;
        final DateTime? endDate = rentalPeriod.endDate;

        // Check if the vehicule is available during the selected rental period
        return vehicule.unavailabilityPeriods.every((period) {
          return startDate == null ||
              endDate == null ||
              (startDate.isAfter(period.endDate) || endDate.isBefore(period.startDate));
        });
      });

      // Act: Check if the vehicule is available during the rental period
      final isAvailable = mockMapService.isVehiculeAvailableDuringRentalPeriod(vehicule, rentalPeriodProvider);

      // Assert: Ensure the vehicule is available for the rental period
      expect(isAvailable, true);
    });

  });
}

