import 'package:flutter/material.dart';

/// A simple ChangeNotifier that stores and updates the walking radius value.
class WalkingRadiusProvider extends ChangeNotifier {
  double _walkingRadius = 1250; // Default radius is 1250 meters (~15 min walk)

  double get walkingRadius => _walkingRadius;

  /// Updates the walking radius and notifies listeners.
  void updateRadius(double newRadius) {
    _walkingRadius = newRadius;
    notifyListeners();
  }
}
