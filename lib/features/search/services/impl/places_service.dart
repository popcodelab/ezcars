// places_service.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../i_places_service.dart';


class PlacesService implements IPlacesService {
  final String apiKey;

  PlacesService({required this.apiKey});

  

  @override
  Future<List<dynamic>> getPlaceSuggestions(String input) async {
    if (input.isEmpty) return [];

    final String requestUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['predictions'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      // Handle errors (e.g., network issues)
      return [];
    }
  }

  // Function to fetch place details from Google Places API using placeId
  @override
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final String requestUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      // Handle errors (e.g., network issues)
      debugPrint(e.toString());
      return null;
    }
  }
}
