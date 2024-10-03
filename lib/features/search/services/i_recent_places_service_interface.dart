// i_recent_places_service.dart



import '../models/place.dart';

abstract class IRecentPlacesService {
  /// Add a place to the recent places list.
  void addPlace(String name, double latitude, double longitude);

  /// Get a list of recent places.
  List<Place> getRecentPlaces();
}
