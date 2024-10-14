

import '../models/vehicule.dart';

abstract class IVehiculeService {
  Future<List<Vehicule>> getCars();
}