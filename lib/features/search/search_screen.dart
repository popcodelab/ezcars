import 'dart:async'; // For managing asynchronous tasks like fetching data
import 'dart:typed_data'; // For handling binary data such as image bytes

import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps plugin for Flutter
import 'package:provider/provider.dart'; // State management (global state)

import 'models/car.dart'; // Car model class
import 'models/place.dart'; // Place model class
import 'providers/location_provider.dart';
import 'providers/rental_period_provider.dart';
import 'services/i_car_service.dart'; // Interface for car service
import 'services/i_location_service.dart'; // Interface for location service
import 'services/i_map_circle_label_service.dart'; // Interface for map circle label service
import 'services/i_map_transparent_circle_service.dart';
import 'services/impl/car_service.dart'; // Implementation of car service
import 'services/impl/location_service.dart'; // Implementation of location service
import 'services/impl/map_circle_label_service.dart'; // Implementation of circle label service
import 'services/impl/map_transparent_circle_service.dart'; // New transparent circle service
import 'utilities/date_time_formatter.dart';
import 'widgets/car_list_widget.dart';
import 'widgets/date_time/custom_date_range_picker.dart';
import 'widgets/date_time/date_time_picker_tile.dart';
import 'widgets/location_picker_tile.dart';
import 'widgets/places_autocompletion_with_history.dart'; // Utility for formatting dates

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Screen that displays the user's location on a Google Map,
/// along with car markers, a walking radius, and custom markers.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GoogleMapController? mapController; // Controller for interacting with Google Map
  final Completer<GoogleMapController> _controller = Completer(); // Completer for GoogleMapController (async)

  LatLng? _currentLatLng; // Stores user's current location as latitude and longitude
  bool _loadingLocation = true; // Indicates if the user location is still loading
  bool _loadingCars = true; // Indicates if car data is still loading
  double walkingRadius = 1250; // Walking distance radius in meters
  double mapZoomLevel = 16; // Initial map zoom level

  // Service instances for fetching data and creating markers and circles
  final ICarService _carService = CarService(); // Service for fetching car data
  final ILocationService _locationService = LocationService(); // Service for fetching user location
  final IMapCircleLabelService _mapCircleLabelService = MapCircleLabelService(); // Service for creating custom markers with labels
  final IMapTransparentCircleService _circlesService = MapTransparentCircleService(); // Transparent circle service for drawing circles on the map

  List<Car> cars = []; // List to store fetched car data
  Set<Circle> boundsCircle = {}; // Set to store transparent circle objects
  Set<Marker> markers = {}; // Set to store map markers
  List<Car> visibleCars = []; // List to store cars visible on the map

  @override
  void initState() {
    super.initState();
    _fetchCars(); // Fetch car data when the screen initializes
    _fetchUserLocation(); // Fetch user location when the screen initializes
  }

  /// Fetches car data from the car service and adds car markers to the map.
  Future<void> _fetchCars() async {
    try {
      final fetchedCars = await _carService.getCars(); // Fetch cars from the service
      setState(() {
        cars = fetchedCars; // Store fetched cars in the list
        _loadingCars = false; // Set loading indicator to false after data is loaded

        // Create car markers and add them to the map
        markers.addAll(cars.map((car) {
          return Marker(
            markerId: MarkerId(car.name), // Unique marker ID for each car
            position: LatLng(car.lat, car.lng), // Car's position on the map
            infoWindow: InfoWindow(title: car.name), // Info window for car marker
          );
        }));
      });
    } catch (e) {
      setState(() {
        _loadingCars = false; // Set loading to false even if there's an error
      });
      _showErrorSnackBar(AppLocalizations.of(context)!.error_fetching_cars); // Show error message
    }
  }

  /// Fetches the user's current location and updates the map accordingly.
  Future<void> _fetchUserLocation() async {
    setState(() {
      _loadingLocation = true; // Set loading indicator for location
    });

    final position = await _locationService.fetchUserLocation(); // Fetch user's current location
    if (mounted && position != null) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude); // Update user's location
        _loadingLocation = false; // Set loading indicator to false

        // Draw a transparent circle around the user's location
        _updateCircles(mapZoomLevel);
      });

      // Move or animate camera to the user's location
      _animateOrMoveToLocation(_currentLatLng!, mapZoomLevel);
      _addCustomLabelMarker(); // Add a custom label marker after location is fetched
    } else {
      if (mounted) {
        setState(() {
          _loadingLocation = false; // Set loading indicator to false even if there's an error
        });
      }
      _showErrorSnackBar(AppLocalizations.of(context)!.error_fetching_location); // Show error message for location fetching
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

/// Filters the cars visible on the map based on location and unavailability periods.
void _filterVisibleCars() async {
  if (mounted && mapController != null) {
    // Get the visible region bounds of the map
    LatLngBounds bounds = await mapController!.getVisibleRegion();

    // Access the rental period from the global state (via Provider)
    final rentalPeriodState = context.read<RentalPeriodProvider>();

    // Perform the filtering of cars based on location and availability
    setState(() {
      visibleCars = _getVisibleCars(cars, bounds, rentalPeriodState);
    });
  }
}

/// Returns a list of cars that are both within the map bounds and available
/// during the selected rental period (if a rental period is provided).
///
/// [cars] is the list of all cars to filter.
/// [bounds] defines the visible region of the map.
/// [rentalPeriodState] holds the user's selected rental period.
List<Car> _getVisibleCars(List<Car> cars, LatLngBounds bounds, RentalPeriodProvider rentalPeriodState) {
  return cars.where((car) {
    // First filter by location
    bool isWithinBounds = _isCarWithinBounds(car, bounds);

    // If no rental dates are selected, only filter by location
    if (rentalPeriodState.startDate == null || rentalPeriodState.endDate == null) {
      return isWithinBounds;
    }

    // If rental dates are selected, also filter by unavailability
    bool isAvailable = _isCarAvailableDuringRentalPeriod(car, rentalPeriodState);
    return isWithinBounds && isAvailable;
  }).toList();
}

/// Checks if the car is located within the visible map bounds.
///
/// [car] is the car to check.
/// [bounds] defines the visible region of the map.
bool _isCarWithinBounds(Car car, LatLngBounds bounds) {
  return car.lat >= bounds.southwest.latitude &&
      car.lat <= bounds.northeast.latitude &&
      car.lng >= bounds.southwest.longitude &&
      car.lng <= bounds.northeast.longitude;
}

/// Checks if the car is available during the selected rental period.
/// A car is available if none of its unavailability periods overlap with the rental period.
///
/// [car] is the car to check.
/// [rentalPeriodState] holds the user's selected rental period.
bool _isCarAvailableDuringRentalPeriod(Car car, RentalPeriodProvider rentalPeriodState) {
  DateTime selectedStartDate = rentalPeriodState.startDate!;
  DateTime selectedEndDate = rentalPeriodState.endDate!;

  // Check if any of the car's unavailability periods overlap with the selected rental period
  return !car.unavailabilityPeriods.any((period) {
    return selectedStartDate.isBefore(period.endDate) &&
        selectedEndDate.isAfter(period.startDate);
  });
}


  /// Animates or moves the map to the target location based on user preference.
  Future<void> _animateOrMoveToLocation(LatLng target, double zoomLevel,
      {bool instantMove = false}) async {
    final controller = await _controller.future;

    if (instantMove) {
      // Instant move to location without animation
      controller.moveCamera(
        CameraUpdate.newLatLngZoom(target, zoomLevel),
      );
    } else {
      // Animate camera movement to the target location
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(target, zoomLevel),
      );
    }
  }

  /// Displays a snackbar with the specified error message.
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)), // Display the error message
      );
    }
  }

  /// Adds a custom marker with a label to the map.
  /// The marker is positioned above the user's location, indicating the estimated walking time.
  Future<void> _addCustomLabelMarker() async {
    if (_currentLatLng != null) {
      // Adjust the label's latitude to be slightly above the current location
      final double newLatitude =
          _currentLatLng!.latitude + (walkingRadius / 111000.0);
      const Size markerSize = Size(150, 60); // Define the size of the label marker

      // Create a custom marker with a label ("15 mins")
      final Uint8List markerIcon = await _mapCircleLabelService
          .createCustomMarker('15 mins', markerSize);

      setState(() {
        markers.add(
          Marker(
            markerId: const MarkerId('customLabel'), // Unique ID for the label marker
            position: LatLng(newLatitude, _currentLatLng!.longitude), // Position of the marker
            icon: BitmapDescriptor.fromBytes(markerIcon), // Set the custom marker icon
          ),
        );
      });
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

    // Listen to changes in LocationState to update the map and data accordingly
    if (locationProvider.selectedPlace != null) {
      _currentLatLng = LatLng(locationProvider.selectedPlace!.latitude,
          locationProvider.selectedPlace!.longitude);

      // Animate or move the map to the new location
      if (mapController != null) {
        _animateOrMoveToLocation(_currentLatLng!, mapZoomLevel, instantMove: true);
      }

      // Update circles, markers, and visible cars after location change
      _updateCircles(mapZoomLevel);
      _filterVisibleCars();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Show a loading spinner while the user's location is being loaded
          _loadingLocation
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller); // Complete the controller when the map is created
                    }
                    mapController = controller;
                    if (_currentLatLng != null) {
                      _animateOrMoveToLocation(_currentLatLng!, mapZoomLevel,
                          instantMove: true); // Move camera to user's location
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng ?? const LatLng(34.0522, -118.2437), // Default to LA if location is not available
                    zoom: mapZoomLevel, // Initial zoom level
                  ),
                  onCameraMove: (position) {
                    setState(() {
                      mapZoomLevel = position.zoom; // Update zoom level when the map moves
                    });
                  },
                  onCameraIdle: () {
                    _filterVisibleCars(); // Filter visible cars when the camera stops moving
                  },
                  circles: boundsCircle, // Display transparent circles around user's location
                  markers: markers, // Display car markers and custom markers
                  myLocationEnabled: true, // Enable the "My Location" button on the map
                  myLocationButtonEnabled: true, // Show the button for user's current location
                ),

          // Overlay for location and date-time selection
          Positioned(
            top: 10.0,
            left: 10.0,
            right: 10.0,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white.withOpacity(0.7), // Set a transparent white background (70% opacity)
                    child: LocationPickerTile(
                      selectedPlace: locationProvider.selectedPlace, // Show selected place
                      onLocationTap: () async {
                        var selectedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PlacesAutocompletionWithHistoryScreen(), // Navigate to place picker
                          ),
                        );
                        if (selectedLocation != null &&
                            selectedLocation is Place) {
                          locationProvider.updateLocation(selectedLocation); // Update selected location in the state
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, left: 10.0), // Add margin to the right
                  child: Container(
                    height: 30.0,
                    width: 1.0,
                    color: theme.dividerColor, // Divider between location and date-time picker
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white.withOpacity(0.7), // Set a transparent white background (70% opacity)
                    child: DateTimePickerTile(
                      startDate: rentalPeriodProvider.startDate, // Selected start date
                      endDate: rentalPeriodProvider.endDate, // Selected end date
                      startTime: rentalPeriodProvider.startTime, // Selected start time
                      endTime: rentalPeriodProvider.endTime, // Selected end time
                      onDateTap: () {
                        // Show the custom date range picker when the user taps on the date tile
                        showCustomDateRangePicker(
                          context,
                          dismissible: true,
                          minimumDate: DateTime.now().subtract(const Duration(days: 30)), // Minimum date for selection
                          maximumDate: DateTime.now().add(const Duration(days: 30)), // Maximum date for selection
                          startDate: rentalPeriodProvider.startDate,
                          endDate: rentalPeriodProvider.endDate,
                          startTime: rentalPeriodProvider.startTime,
                          endTime: rentalPeriodProvider.endTime,
                          backgroundColor: Colors.white,
                          primaryColor: Colors.green,
                          onApplyClick: (selectedStartDate, selectedEndDate,
                              selectedStartTime, selectedEndTime) {
                            // Update the selected rental period in the state
                            rentalPeriodProvider.updateDates(
                              startDate: selectedStartDate,
                              endDate: selectedEndDate,
                              startTime: selectedStartTime,
                              endTime: selectedEndTime,
                            );

                            // Refresh the visible cars after the date range is updated
                            _filterVisibleCars();
                          },
                          onCancelClick: () {
                            rentalPeriodProvider.clearDates(); // Clear the selected rental dates

                            // Refresh the visible cars after the dates are cleared
                            _filterVisibleCars();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of visible cars at the bottom of the screen
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            height: 220, // Set a fixed height for the car list
            child: CarListWidget(
              cars: visibleCars, // Display filtered visible cars
              isLoading: _loadingCars, // Show loading indicator if cars are still loading
              onCarTap: (LatLng location) {
                _animateOrMoveToLocation(location, mapZoomLevel); // Move the map to the selected car's location
              },
            ),
          ),
        ],
      ),
    );
  }
}
