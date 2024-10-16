import 'package:geolocator/geolocator.dart';
import '../../models/vehicle.dart';
import '../../providers/walking_radiius_provider.dart';

abstract class IVehicleService {
  Future<List<Vehicle>> getVehicles();

  /// Calculate the distances for all vehicles and sort them by proximity to the user's location.
  Future<List<Vehicle>> calculateVehicleDistances(List<Vehicle> vehicles, Position userPosition, {String unit});

  /// Filter vehicles by proximity using a walking radius and return the filtered list.
  Future<List<Vehicle>> filterVehiclesByProximity(
      List<Vehicle> vehicles, Position userPosition, WalkingRadiusProvider radiusProvider, {String unit});
}
