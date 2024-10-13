import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/car.dart';
import 'services/i_car_service.dart';
import 'services/i_location_service.dart';
import 'services/i_map_circle_label_service.dart';
import 'services/i_map_transparent_circle_service.dart';
import 'services/impl/car_service.dart';
import 'services/impl/location_service.dart';
import 'services/impl/map_circle_label_service.dart';
import 'services/impl/map_transparent_circle_service.dart';
import 'widgets/car_list_widget.dart';

/// Screen that displays the user's location on a Google Map,
/// along with car markers, a walking radius, and custom markers.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GoogleMapController? mapController; // Controller to interact with Google Map
  final Completer<GoogleMapController> _controller = Completer();

  LatLng? _currentLatLng; // Stores user's current location
  bool _loadingLocation = true; // Indicates whether the user location is being loaded
  bool _loadingCars = true; // Indicates whether car data is being loaded
  double walkingRadius = 1250; // Radius around user location for walking distance in meters
  double mapZoomLevel = 16; // Initial map zoom level

  // Service instances for fetching data and creating markers
  final ICarService _carService = CarService();
  final ILocationService _locationService = LocationService();
  final IMapCircleLabelService _mapCircleLabelService = MapCircleLabelService();
  final IMapTransparentCircleService _circlesService = MapTransparentCircleService(); // Transparent circle service for drawing circles on the map

  List<Car> cars = []; // List to store car data
  Set<Circle> boundsCircle = {}; // Set to store transparent circle objects
  Set<Marker> markers = {}; // Set to store map markers
  List<Car> visibleCars = []; // List to store only the cars that are visible on the map

  Timer? _debounce; // Timer used to debounce map camera idle events

  @override
  void initState() {
    super.initState();
    _fetchCars(); // Fetch car data on initialization
    _fetchUserLocation(); // Fetch user location on initialization
  }

  /// Fetches car data from the car service and adds markers to the map.
  Future<void> _fetchCars() async {
    try {
      final fetchedCars = await _carService.getCars();
      setState(() {
        cars = fetchedCars;
        _loadingCars = false;

        // Add car markers to the map
        markers.addAll(cars.map((car) {
          return Marker(
            markerId: MarkerId(car.name),
            position: LatLng(car.lat, car.lng),
            infoWindow: InfoWindow(title: car.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue), // Use a default marker if no image available
          );
        }));
      });
    } catch (e) {
      setState(() {
        _loadingCars = false;
      });
      _showErrorSnackBar("Error fetching cars. Please try again.");
    }
  }

  /// Fetches user's current location and updates the map accordingly.
  Future<void> _fetchUserLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      final position = await _locationService.fetchUserLocation();
      if (mounted && position != null) {
        setState(() {
          _currentLatLng = LatLng(position.latitude, position.longitude);
          _loadingLocation = false;

          // Create initial polylines with the given zoom level
          _updateCircles(mapZoomLevel);
        });

        // Animate to the user's location
        _animateToLocation(_currentLatLng!, mapZoomLevel);
        _addCustomLabelMarker(); // Add label marker once location is fetched
      } else {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
          });
        }
        _showErrorSnackBar("Error fetching location. Please try again.");
      }
    } catch (e) {
      setState(() {
        _loadingLocation = false;
      });
      _showErrorSnackBar("Error fetching location. Please try again.");
    }
  }

  /// Updates transparent circles around the user's current location based on zoom level.
  void _updateCircles(double zoomLevel) {
    setState(() {
      boundsCircle = _circlesService.createTransparentCircle(
        center: _currentLatLng!, // Center the circle on user's location
        radiusInMeters: walkingRadius, // Walking radius in meters
        opacity: 0.4, // Circle opacity (40% transparent)
        fillColor: Colors.green, // Fill color for the circle
        strokeWidth: 2, // Stroke width for the circle border
        strokeColor: Colors.greenAccent, // Border color for the circle
      );
    });
  }

  /// Filters the cars based on the current visible region of the map.
  /// Debounced to avoid performance issues when rapidly panning the map.
  void _filterVisibleCars() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (mounted && mapController != null) {
        LatLngBounds bounds = await mapController!.getVisibleRegion();

        setState(() {
          visibleCars = cars.where((car) {
            return car.lat >= bounds.southwest.latitude &&
                car.lat <= bounds.northeast.latitude &&
                car.lng >= bounds.southwest.longitude &&
                car.lng <= bounds.northeast.longitude;
          }).toList();
        });
      }
    });
  }

  /// Animates the map to the target location with the specified zoom level.
  Future<void> _animateToLocation(LatLng target, double zoomLevel) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(target, zoomLevel));
  }

  /// Shows a snackbar with the specified error message.
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Adds a custom marker with a label to the map.
  /// The marker is positioned above the user's location, indicating the estimated walking time.
  Future<void> _addCustomLabelMarker() async {
    if (_currentLatLng != null) {
      // Calculate the new latitude using the walkingRadius to shift the marker vertically
      final double newLatitude =
          _currentLatLng!.latitude + (walkingRadius / 111000.0);

      // Define the marker size (e.g., width 150, height 60)
      const Size markerSize = Size(150, 60);

      try {
        // Use the service to create the custom marker with the specified size
        final Uint8List markerIcon =
            await _mapCircleLabelService.createCustomMarker('15 mins', markerSize);

        // Add the marker to the set of markers
        setState(() {
          markers.add(
            Marker(
              markerId: const MarkerId('customLabel'),
              position: LatLng(newLatitude, _currentLatLng!.longitude),
              icon: BitmapDescriptor.fromBytes(markerIcon),
            ),
          );
        });
      } catch (e) {
        // Handle error by showing a default marker instead
        markers.add(
          Marker(
            markerId: const MarkerId('customLabelFallback'),
            position: LatLng(newLatitude, _currentLatLng!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed), // Default fallback marker
          ),
        );
        _showErrorSnackBar("Error adding custom marker. Using default marker.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Show a loading spinner while location is being loaded
          _loadingLocation
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GoogleMap(
                  onMapCreated: (controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                    mapController = controller;
                    if (_currentLatLng != null) {
                      _animateToLocation(_currentLatLng!, mapZoomLevel);
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng ??
                        const LatLng(34.0522,
                            -118.2437), // Default to Los Angeles if location not yet available
                    zoom: mapZoomLevel,
                  ),
                  onCameraMove: (position) {
                    setState(() {
                      mapZoomLevel = position.zoom;
                    });
                  },
                  onCameraIdle: _filterVisibleCars,
                  circles: boundsCircle, // Display transparent circles around user's location
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
          // Display a list of visible cars at the bottom of the screen
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            height: 220,
            child: CarListWidget(
              cars: visibleCars,
              isLoading: _loadingCars,
              onCarTap: (LatLng location) {
                _animateToLocation(location, mapZoomLevel);
              },
            ),
          ),
        ],
      ),
    );
  }
}
