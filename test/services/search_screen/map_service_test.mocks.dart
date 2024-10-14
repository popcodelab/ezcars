// Mocks generated by Mockito 5.4.4 from annotations
// in ezcars/test/services/search_screen/map_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:typed_data' as _i7;

import 'package:ezcars/features/search/models/vehicule.dart' as _i4;
import 'package:ezcars/features/search/providers/rental_period_provider.dart'
    as _i6;
import 'package:ezcars/features/search/services/i_map_service.dart' as _i2;
import 'package:google_maps_flutter/google_maps_flutter.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [IMapService].
///
/// See the documentation for Mockito's code generation for more information.
class MockIMapService extends _i1.Mock implements _i2.IMapService {
  MockIMapService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.Vehicule>> fetchVehicules() => (super.noSuchMethod(
        Invocation.method(
          #fetchCars,
          [],
        ),
        returnValue: _i3.Future<List<_i4.Vehicule>>.value(<_i4.Vehicule>[]),
      ) as _i3.Future<List<_i4.Vehicule>>);

  @override
  _i3.Future<_i5.LatLng?> fetchUserLocation() => (super.noSuchMethod(
        Invocation.method(
          #fetchUserLocation,
          [],
        ),
        returnValue: _i3.Future<_i5.LatLng?>.value(),
      ) as _i3.Future<_i5.LatLng?>);

  @override
  Set<_i5.Circle> updateCircles(
    _i5.LatLng? currentLatLng,
    double? walkingRadius,
    double? opacity,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateCircles,
          [
            currentLatLng,
            walkingRadius,
            opacity,
          ],
        ),
        returnValue: <_i5.Circle>{},
      ) as Set<_i5.Circle>);

  @override
  List<_i4.Vehicule> filterVisibleVehicules(
    List<_i4.Vehicule>? vehicules,
    _i5.LatLngBounds? bounds,
    _i6.RentalPeriodProvider? rentalPeriodState,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #filterVisibleCars,
          [
            vehicules,
            bounds,
            rentalPeriodState,
          ],
        ),
        returnValue: <_i4.Vehicule>[],
      ) as List<_i4.Vehicule>);

  @override
  bool isVehiculeWithinBounds(
    _i4.Vehicule? vehicule,
    _i5.LatLngBounds? bounds,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #isCarWithinBounds,
          [
            vehicule,
            bounds,
          ],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isVehiculeAvailableDuringRentalPeriod(
    _i4.Vehicule? vehicule,
    _i6.RentalPeriodProvider? rentalPeriodState,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #isCarAvailableDuringRentalPeriod,
          [
            vehicule,
            rentalPeriodState,
          ],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i3.Future<_i7.Uint8List> addCustomLabelMarker(
    _i5.LatLng? currentLatLng,
    double? walkingRadius,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addCustomLabelMarker,
          [
            currentLatLng,
            walkingRadius,
          ],
        ),
        returnValue: _i3.Future<_i7.Uint8List>.value(_i7.Uint8List(0)),
      ) as _i3.Future<_i7.Uint8List>);
}
