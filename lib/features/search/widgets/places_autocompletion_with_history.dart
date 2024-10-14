import 'dart:async';
import 'dart:io';

import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../keys.dart';
import '../models/place.dart';
import '../providers/location_provider.dart';
import '../providers/recent_places_provider.dart';
import '../services/i_places_service.dart';
import '../services/impl/places_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlacesAutocompletionWithHistoryScreen extends StatefulWidget {
  final int maxRecentPlacesDisplayed;

  const PlacesAutocompletionWithHistoryScreen({
    super.key,
    this.maxRecentPlacesDisplayed = 5,
  });

  @override
  State<PlacesAutocompletionWithHistoryScreen> createState() =>
      _PlacesAutocompletionWithHistoryScreenState();
}

class _PlacesAutocompletionWithHistoryScreenState
    extends State<PlacesAutocompletionWithHistoryScreen> {
  final TextEditingController _autocompleteController = TextEditingController();
  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _isLoading = false;
  late IPlacesService _placesService;

  @override
  void initState() {
    super.initState();
    String apiKey = Platform.isAndroid ? APIKeys.androidPlacesApiKey : APIKeys.iosApiKey;
    _placesService = PlacesService(apiKey: apiKey);
  }

  void _onSuggestionTap(Map<String, dynamic> suggestion) async {
    final locationProvider = context.read<LocationProvider>();
    final recentPlacesProvider = context.read<RecentPlacesProvider>();

    setState(() {
      _isLoading = true;
      _suggestions = [];
    });

    try {
      final placeId = suggestion['place_id'];
      Map<String, dynamic>? placeDetails = await _placesService.getPlaceDetails(placeId);

      if (placeDetails != null) {
        final selectedPlace = Place(
          name: suggestion['description'],
          address: suggestion['description'],
          latitude: placeDetails['geometry']['location']['lat'],
          longitude: placeDetails['geometry']['location']['lng'],
        );

        locationProvider.updateLocation(selectedPlace);
        recentPlacesProvider.addPlace(selectedPlace); // Add to recent places in AppState

        Navigator.of(context).pop(selectedPlace);
      }
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)!.error_fetching_place_details.capitalize(), () => _onSuggestionTap(suggestion));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();
    final recentPlacesProvider = context.read<RecentPlacesProvider>();

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showErrorSnackBar(AppLocalizations.of(context)!.location_permission_required.capitalize(), _handleCurrentLocation);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      String locationName = placemarks.isNotEmpty
          ? '${placemarks.first.locality}, ${placemarks.first.country}'
          : AppLocalizations.of(context)!.unknown_location.capitalize();

      final currentPlace = Place(
        name: locationName,
        address: locationName,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      locationProvider.updateLocation(currentPlace);
      recentPlacesProvider.addPlace(currentPlace); // Add current location to recent places

      Navigator.of(context).pop(currentPlace);
    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)!.error_fetching_current_location.capitalize()}: ${e.toString()}', _handleCurrentLocation);
    }
  }

  void _showErrorSnackBar(String message, VoidCallback retryCallback) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.retry.capitalize(),
          onPressed: retryCallback,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _autocompleteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentPlaces = context.watch<RecentPlacesProvider>().recentPlaces;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _autocompleteController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.autocomplete_location_hint.capitalize(),
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(strokeWidth: 2.0),
                            )
                          : const Icon(Icons.search),
                    ),
                    onChanged: (input) {
                      _onSearchChanged(input);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  if (_autocompleteController.text.isEmpty)
                    _buildListTile(
                      icon: Icons.my_location,
                      title: AppLocalizations.of(context)!.current_location.capitalize(),
                      onTap: _handleCurrentLocation,
                    ),
                  if (_suggestions.isNotEmpty)
                    ..._suggestions.map((suggestion) {
                      return _buildListTile(
                        icon: Icons.location_on,
                        title: suggestion['description'],
                        onTap: () => _onSuggestionTap(suggestion),
                      );
                    }),
                  if (recentPlaces.isNotEmpty)
                    ...recentPlaces.map((recentPlace) {
                      return _buildListTile(
                        icon: Icons.history,
                        title: recentPlace.name,
                        onTap: () {
                          final selectedPlace = recentPlace;
                          context.read<LocationProvider>().updateLocation(selectedPlace);
                          context.read<RecentPlacesProvider>().addPlace(selectedPlace);
                          Navigator.of(context).pop(selectedPlace);
                        },
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      key: ValueKey(title),
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      onTap: onTap,
    );
  }

  void _onSearchChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _getPlaceSuggestions(input);
    });
  }

  Future<void> _getPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<dynamic> suggestions = await _placesService.getPlaceSuggestions(input);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context)!.error_fetching_suggestions.capitalize(), () => _getPlaceSuggestions(input));
        setState(() => _isLoading = false);
      }
    }
  }
}
