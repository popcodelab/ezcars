import 'package:flutter/material.dart';

class DistanceUnitProvider with ChangeNotifier {
  String _distanceUnit = 'miles'; // Default to miles

  String get distanceUnit => _distanceUnit;

  void updateDistanceUnit(String newUnit) {
    _distanceUnit = newUnit;
    notifyListeners(); // Notify listeners about the change
  }
}
