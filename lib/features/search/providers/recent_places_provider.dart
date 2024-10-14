/// Provides history of selected places through the "Search" feature
library;

import 'package:flutter/material.dart';

import '../models/place.dart';


class RecentPlacesProvider extends ChangeNotifier {
  // Recent places management
  final List<Place> _recentPlaces = [];
  final int maxRecentPlaces = 5; // Limit the number of recent places stored

  // Method to add a new place to the recent places list
  void addPlace(Place place) {
    // Check if the place is already in the list to avoid duplicates
    _recentPlaces.removeWhere((existingPlace) => existingPlace.name == place.name);

    // Add the new place to the start of the list
    _recentPlaces.insert(0, place);

    // Limit the number of stored recent places
    if (_recentPlaces.length > maxRecentPlaces) {
      _recentPlaces.removeLast();
    }

    // Notify listeners about the change
    notifyListeners();
  }

  // Getter to retrieve the list of recent places
  List<Place> get recentPlaces => List.unmodifiable(_recentPlaces);

  // Optional: Method to clear recent places
  void clearRecentPlaces() {
    _recentPlaces.clear();
    notifyListeners();
  }
}