import 'package:geolocator/geolocator.dart';
import '../models/vehicle.dart';
import '../providers/walking_radiius_provider.dart';

abstract class IVehicleService {
  Future<List<Vehicle>> getVehicles();

  /// Filters vehicles by their proximity to the user's current location.
  Future<List<Vehicle>> filterVehiclesByProximity(
      List<Vehicle> vehicles,
      Position userPosition,
      WalkingRadiusProvider radiusProvider
      );
}
