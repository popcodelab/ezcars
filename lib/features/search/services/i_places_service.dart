abstract class IPlacesService {
  Future<List<dynamic>> getPlaceSuggestions(String input);
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId);
}
