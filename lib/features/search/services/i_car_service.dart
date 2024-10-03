

import '../models/car.dart';

abstract class ICarService {
  Future<List<Car>> getCars();
}