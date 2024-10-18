import 'dart:async'; // For managing asynchronous tasks like fetching data
import 'dart:typed_data'; // For handling binary data such as image bytes

import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps plugin for Flutter
import 'package:provider/provider.dart'; // State management (global state)

import '../../models/vehicle.dart'; // Vehicle model class
import '../../providers/walking_radiius_provider.dart';
import 'models/place.dart'; // Place model class
import 'providers/location_provider.dart';
import 'providers/rental_period_provider.dart';
import 'services/i_map_service.dart';
import '../../services/impl/vehicle_service.dart'; // Implementation of vehicle service
import '../../services/impl/location_service.dart'; // Implementation of location service
import 'services/impl/map_circle_label_service.dart'; // Implementation of circle label service
import 'services/impl/map_service.dart';
import 'services/impl/map_transparent_circle_service.dart'; // New transparent circle service
import 'utilities/date_time_formatter.dart';
import 'widgets/date_time/custom_date_range_picker.dart';
import 'widgets/date_time/date_time_picker_tile.dart';
import 'widgets/location_picker_tile.dart';
import 'widgets/places_autocompletion_with_history.dart'; // Utility for formatting dates

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'widgets/vehicules_list_widget.dart';

import 'dart:ui' as ui;

/// This screen shows a Google Map displaying vehicle markers and allows the user to
/// filter vehicles based on their location and rental period.
class SearchScreen extends StatefulWidget {
  final LatLng? vehicleLocation; // Add this to accept a vehicle's location
  const SearchScreen({Key? key, this.vehicleLocation}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  GoogleMapController? mapController; // Controller for Google Map
  final Completer<GoogleMapController> _controller = Completer(); // Async controller for map

  LatLng? _currentLatLng; // Stores the user's current location
  bool _loadingLocation = true; // Indicates if user location is loading
  bool _loadingCars = true; // Indicates if vehicle data is loading
  double mapZoomLevel = 16; // Map zoom level

  List<Vehicle> vehicles = []; // List of all available vehicles
  Set<Circle> boundsCircle = {}; // Set of transparent circles drawn on the map
  Set<Marker> markers = {}; // Set of markers displayed on the map
  List<Vehicle> visibleCars = []; // List of vehicles visible within the map bounds

  // The map service that contains all the business logic
  late IMapService _mapService;

  @override
  void initState() {
    super.initState();

    // Initialize the map service with required dependencies
    _mapService = MapService(
      carService: VehicleService(),
      locationService: LocationService(),
      mapCircleLabelService: MapCircleLabelService(),
      circlesService: MapTransparentCircleService(),
    );

    _fetchVehicules(); // Fetch vehicle data on initialization
    _fetchUserLocation(); // Fetch user location on initialization

    // If initial vehicle location is provided, move the map to that location
    if (widget.vehicleLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateOrMoveToLocation(widget.vehicleLocation!, mapZoomLevel, instantMove: true);
      });
    }
  }

  /// Fetches vehicle data from the map service and adds vehicle markers to the map.
  /// Converts a Material Icon to a BitmapDescriptor, with adjustable size and color.
  Future<BitmapDescriptor> _bitmapDescriptorFromIconData(IconData iconData, Color color, double size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0.0, 0.0));

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(pngBytes);
  }

  /// Fetches vehicle data and applies different Material Icons as the marker icon based on vehicle type.
  Future<void> _fetchVehicules() async {
    try {
      final fetchedCars = await _mapService.fetchVehicules(); // Fetch vehicles using service

      setState(() async {
        vehicles = fetchedCars; // Update the list of vehicles
        _loadingCars = false; // Set loading to false after data is loaded

        // Create markers for each vehicle using a different icon based on the vehicle type
        markers.addAll(await Future.wait(vehicles.map((vehicle) async {
          BitmapDescriptor vehicleIcon;

          // Select icon based on vehicle type
          if (vehicle.type == 'electric') {
            vehicleIcon = await _bitmapDescriptorFromIconData(Icons.electric_car, Colors.green, 80.0);
          } else if (vehicle.type == 'gas') {
            vehicleIcon = await _bitmapDescriptorFromIconData(Icons.car_rental, Colors.blue, 80.0);
          } else {
            vehicleIcon = await _bitmapDescriptorFromIconData(Icons.directions_car, Colors.black, 80.0); // Default icon for other types
          }

          // Return a marker for each vehicle
          return Marker(
            markerId: MarkerId(vehicle.model), // Unique ID for each marker
            position: LatLng(vehicle.latitude, vehicle.longitude), // Position of the vehicle
            icon: vehicleIcon, // Set the custom icon based on vehicle type
            infoWindow: InfoWindow(title: vehicle.model, snippet: vehicle.price), // Info window with model and price
          );
        }).toList()));
      });
    } catch (e) {
      setState(() {
        _loadingCars = false; // Stop loading even on error
      });
      _showErrorSnackBar(AppLocalizations.of(context)!.error_fetching_vehicles); // Display error message
    }
  }


  /// Fetches the user's current location using the map service and updates the map.
  Future<void> _fetchUserLocation() async {
    setState(() {
      _loadingLocation = true; // Show loading while fetching location
    });

    final position = await _mapService.fetchUserLocation(context); // Fetch user location
    if (mounted && position != null) {
      setState(() {
        _currentLatLng = position; // Update the user's location
        _loadingLocation = false; // Stop loading

        // Draw transparent circle around user's location
        _updateCircles(mapZoomLevel);
      });

      // Move camera to the user's location
      _animateOrMoveToLocation(_currentLatLng!, mapZoomLevel);

      // Add custom label marker after location is fetched
      _addCustomLabelMarker();
    } else {
      setState(() {
        _loadingLocation = false; // Stop loading if location fails
      });
      _showErrorSnackBar(AppLocalizations.of(context)!.error_fetching_location); // Display error message
    }
  }

  /// Updates the transparent circles drawn on the map based on the user's location.
  void _updateCircles(double zoomLevel) {
    if (_currentLatLng != null) {
      setState(() {
        // Use the walking radius from the provider instead of the hardcoded value
        double walkingRadius = context.read<WalkingRadiusProvider>().walkingRadius;

        boundsCircle = _mapService.updateCircles(
          _currentLatLng!, // User's current location
          walkingRadius, // Walking radius in meters
          0.4, // Opacity of the circle
        );
      });
    }
  }

  /// Filters the vehicles visible on the map based on the map's bounds and rental period.
  void _filterVisibleVehicules() async {
    if (mounted && mapController != null) {
      // Get the bounds of the visible map area
      LatLngBounds bounds = await mapController!.getVisibleRegion();

      // Access the rental period from the global state (via Provider)
      final rentalPeriodState = context.read<RentalPeriodProvider>();

      // Filter the visible vehicles using the map service
      setState(() {
        visibleCars = _mapService.filterVisibleVehicules(vehicles, bounds, rentalPeriodState);
      });
    }
  }

  /// Adds a custom label marker (e.g., "15 mins") to the map above the user's location.
  Future<void> _addCustomLabelMarker() async {
    if (_currentLatLng != null) {
      // Use the walking radius from the provider
      double walkingRadius = context.read<WalkingRadiusProvider>().walkingRadius;

      // Create custom marker for walking time label
      final Uint8List markerIcon = await _mapService.addCustomLabelMarker(_currentLatLng!, walkingRadius);
      setState(() {
        // Add the custom marker to the map
        markers.add(
          Marker(
            markerId: const MarkerId('customLabel'), // Unique ID for the label marker
            position: LatLng(_currentLatLng!.latitude + (walkingRadius / 111000.0),
                _currentLatLng!.longitude), // Position above user's location
            icon: BitmapDescriptor.bytes(markerIcon), // Custom icon
          ),
        );
      });
    }
  }

  /// Moves or animates the camera to the target location on the map.
  Future<void> _animateOrMoveToLocation(LatLng target, double zoomLevel, {bool instantMove = false}) async {
    final controller = await _controller.future;

    if (instantMove) {
      controller.moveCamera(
        CameraUpdate.newLatLngZoom(target, zoomLevel), // Move camera without animation
      );
    } else {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(target, zoomLevel), // Animate camera movement
      );
    }
  }

  Future<void> animateOrMoveToVehicleLocation(LatLng target, {bool instantMove = false}) async {
    final controller = await _controller.future;

    if (instantMove) {
      controller.moveCamera(
        CameraUpdate.newLatLngZoom(target, mapZoomLevel), // Move camera without animation
      );
    } else {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(target, mapZoomLevel), // Animate camera movement
      );
    }
  }

  /// Displays an error snackbar with a given message.
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)), // Show error message
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rentalPeriodProvider = context.watch<RentalPeriodProvider>();
    final locationProvider = context.watch<LocationProvider>();

    // Format start and end date-time for display
    DateTimeFormatter.getFormattedDateTime(
        rentalPeriodProvider.startDate, rentalPeriodProvider.startTime);
    DateTimeFormatter.getFormattedDateTime(
        rentalPeriodProvider.endDate, rentalPeriodProvider.endTime);

    // Listen for changes in the selected location and update the map
    if (locationProvider.selectedPlace != null) {
      _currentLatLng = LatLng(locationProvider.selectedPlace!.latitude,
          locationProvider.selectedPlace!.longitude);

      // Move the map to the new location
      if (mapController != null) {
        _animateOrMoveToLocation(_currentLatLng!, mapZoomLevel, instantMove: true);
      }

      // Update circles and visible vehicles when location changes
      _updateCircles(mapZoomLevel);
      _filterVisibleVehicules();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Show a loading spinner while the user's location is being fetched
          _loadingLocation
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: (controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller); // Complete the controller on map creation
              }
              mapController = controller;
              if (_currentLatLng != null) {
                _animateOrMoveToLocation(_currentLatLng!, mapZoomLevel, instantMove: true);
              }
            },
            initialCameraPosition: CameraPosition(
              target: widget.vehicleLocation ??
                  _currentLatLng ?? const LatLng(34.0522, -118.2437), // Default to LA or the selected vehicle location
              zoom: mapZoomLevel,
            ),
            onCameraMove: (position) {
              setState(() {
                mapZoomLevel = position.zoom; // Update zoom level when camera moves
              });
            },
            onCameraIdle: () {
              _filterVisibleVehicules(); // Filter visible vehicles when the camera stops moving
            },
            circles: boundsCircle, // Draw transparent circles
            markers: markers, // Display vehicle markers
            myLocationEnabled: true, // Enable user's location button
            myLocationButtonEnabled: false, // Hide the location button
            zoomControlsEnabled: false, // Hide the zoom buttons
          ),

          // Overlay for selecting location and date-time
          Positioned(
            top: 10.0,
            left: 10.0,
            right: 10.0,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: LocationPickerTile(
                      selectedPlace: locationProvider.selectedPlace,
                      onLocationTap: () async {
                        var selectedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const PlacesAutocompletionWithHistoryScreen(),
                          ),
                        );
                        if (selectedLocation != null &&
                            selectedLocation is Place) {
                          locationProvider.updateLocation(selectedLocation); // Update the location
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    height: 30.0,
                    width: 1.0,
                    color: theme.dividerColor, // Divider between location and date-time picker
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: DateTimePickerTile(
                      startDate: rentalPeriodProvider.startDate,
                      endDate: rentalPeriodProvider.endDate,
                      startTime: rentalPeriodProvider.startTime,
                      endTime: rentalPeriodProvider.endTime,
                      onDateTap: () {
                        // Open custom date picker when user taps
                        showCustomDateRangePicker(
                          context,
                          dismissible: true,
                          minimumDate: DateTime.now().subtract(const Duration(days: 30)),
                          maximumDate: DateTime.now().add(const Duration(days: 30)),
                          startDate: rentalPeriodProvider.startDate,
                          endDate: rentalPeriodProvider.endDate,
                          startTime: rentalPeriodProvider.startTime,
                          endTime: rentalPeriodProvider.endTime,
                          backgroundColor: Colors.white,
                          primaryColor: Colors.green,
                          onApplyClick: (selectedStartDate, selectedEndDate,
                              selectedStartTime, selectedEndTime) {
                            // Update rental period when applied
                            rentalPeriodProvider.updateDates(
                              startDate: selectedStartDate,
                              endDate: selectedEndDate,
                              startTime: selectedStartTime,
                              endTime: selectedEndTime,
                            );

                            // Refresh visible vehicles after updating dates
                            _filterVisibleVehicules();
                          },
                          onCancelClick: () {
                            rentalPeriodProvider.clearDates(); // Clear dates if canceled
                            _filterVisibleVehicules(); // Refresh visible vehicles
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of visible vehicles at the bottom of the screen
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            height: 220, // Fixed height for vehicle list
            child: VehiculesListWidget(
              vehicles: visibleCars, // Show filtered vehicles
              isLoading: _loadingCars, // Show loading spinner if vehicles are still loading
              onCarTap: (LatLng location) {
                _animateOrMoveToLocation(location, mapZoomLevel); // Move map to the selected vehicle
              },
            ),
          ),
        ],
      ),
    );
  }
}
