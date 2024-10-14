/// Provides the current location through the "Search" feature
library;

import 'package:flutter/material.dart';

import '../models/place.dart';


class LocationProvider extends ChangeNotifier {
  Place? selectedPlace; // Correct definition of selectedPlace to manage the selected location globally

  // Method to update the selected location
  void updateLocation(Place place) {
    selectedPlace = place;
    notifyListeners(); // Notify listeners about the change
  }

  // Optional: Method to clear the selected location
  void clearLocation() {
    selectedPlace = null;
    notifyListeners();
  }
}
