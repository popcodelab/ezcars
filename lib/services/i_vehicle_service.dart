

import '../models/vehicle.dart';

abstract class IVehicleService {
  Future<List<Vehicle>> getVehicles();
}