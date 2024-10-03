
import '../../models/place.dart';
import '../i_recent_places_service_interface.dart';

// recent_places_service.dart


class RecentPlacesService implements IRecentPlacesService {
  final int maxPlaces;
  final List<Place> _recentPlaces = [];

  RecentPlacesService({required this.maxPlaces});

  @override
  void addPlace(String name, double latitude, double longitude) {
    final newPlace = Place(
      name: name,
      address: '', // Add an address if available.
      latitude: latitude,
      longitude: longitude,
    );

    _recentPlaces.add(newPlace);

    // Ensure we don't exceed maxPlaces.
    if (_recentPlaces.length > maxPlaces) {
      _recentPlaces.removeAt(0); // Remove the oldest place.
    }
  }

  @override
  List<Place> getRecentPlaces() {
    return _recentPlaces;
  }
}

