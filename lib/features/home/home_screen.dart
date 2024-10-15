import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ezcars/services/impl/location_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/i_location_service.dart';
import '../../services/i_vehicle_service.dart';
import 'widgets/vehicle_list_item.dart';
import 'package:ezcars/models/vehicle.dart';
import 'package:ezcars/services/impl/vehicle_service.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final IVehicleService vehicleService; // Service to fetch the list of vehicles
  final ILocationService locationService; // Service to handle location fetching

  const HomeScreen({
    super.key,
    required this.vehicleService,
    required this.locationService,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedVehicleIndex; // Keeps track of the currently selected vehicle to show details
  Future<List<Vehicle>>? _vehiclesFuture; // Cache the future to avoid refetching
  Position? _userPosition; // Stores the user's current position
  List<Vehicle> _filteredVehicles = []; // Store filtered vehicles based on location

  static const double walkingDistanceRadiusMeters = 1250; // ~15 minutes walking distance

  @override
  void initState() {
    super.initState();
    // Cache the future to avoid refetching on every rebuild.
    _vehiclesFuture = widget.vehicleService.getVehicles();
  }

  /// Function to toggle the selected vehicle's details visibility.
  void _toggleVehicleDetails(int index) {
    setState(() {
      _selectedVehicleIndex = (_selectedVehicleIndex == index) ? null : index;
    });
  }

  /// Refresh the vehicle list when the user pulls to refresh.
  Future<void> _refreshVehicles() async {
    // Reset the filtered vehicle list and fetch all vehicles again.
    setState(() {
      _filteredVehicles = []; // Clear the filtered list, showing all vehicles.
      _vehiclesFuture = widget.vehicleService.getVehicles();
    });
  }

  /// Fetch the user's location and filter vehicles within a 15-minute walking distance.
  Future<void> _fetchUserLocation() async {
    try {
      Position? position = await widget.locationService.fetchUserLocation(context);
      if (position != null) {
        setState(() {
          _userPosition = position;
        });
        _filterVehiclesByProximity();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location fetched: ${position.latitude}, ${position.longitude}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  /// Filter vehicles based on proximity to the user's current location (within a 15-minute walk)
  void _filterVehiclesByProximity() async {
    if (_userPosition == null) return;

    final vehicles = await widget.vehicleService.getVehicles(); // Get the vehicles
    final userLat = _userPosition!.latitude;
    final userLon = _userPosition!.longitude;

    setState(() {
      _filteredVehicles = vehicles.where((vehicle) {
        final distance = _calculateDistance(userLat, userLon, vehicle.latitude, vehicle.longitude);
        return distance <= walkingDistanceRadiusMeters;
      }).toList();
    });
  }

  /// Calculate the distance between two lat/lon coordinates using the Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusMeters = 6371000; // Radius of the Earth in meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c; // Distance in meters
  }

  /// Helper function to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Display the title using localized text with fallback
        title: Text(AppLocalizations.of(context)?.vehicles_list ?? 'Vehicle List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fetchUserLocation, // Fetch user location on button press
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVehicles, // Handle pull-to-refresh
        child: FutureBuilder<List<Vehicle>>(
          future: _vehiclesFuture, // Use the cached future to avoid multiple fetches
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading message while fetching vehicles
              return Center(child: Text(AppLocalizations.of(context)?.loading_vehicles ?? 'Loading vehicles...'));
            }
            if (snapshot.hasError) {
              // Show an error message if something went wrong during the fetch
              return Center(child: Text(AppLocalizations.of(context)?.error_fetching_vehicles ?? 'Failed to load vehicles. Please try again.'));
            }

            final vehicleList = _filteredVehicles.isNotEmpty
                ? _filteredVehicles
                : snapshot.data ?? []; // Use filtered list if available

            if (vehicleList.isEmpty) {
              // Show a message if there are no vehicles available
              return Center(child: Text(AppLocalizations.of(context)?.no_vehicles_available ?? 'No vehicles available.'));
            }

            // Build the list of vehicles
            return ListView.builder(
              itemCount: vehicleList.length, // Number of vehicles in the list
              itemBuilder: (context, index) {
                Vehicle vehicle = vehicleList[index]; // Get the vehicle at the current index
                bool isSelected = _selectedVehicleIndex == index; // Check if this vehicle is selected

                // Use the modularized VehicleListItem component
                return VehicleListItem(
                  vehicle: vehicle,
                  isSelected: isSelected,
                  onTap: () => _toggleVehicleDetails(index), // Toggle visibility of details
                  locationService: widget.locationService, // Pass locationService to VehicleListItem
                );
              },
            );
          },
        ),
      ),
    );
  }
}
