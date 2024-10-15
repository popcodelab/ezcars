import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ezcars/services/impl/location_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'widgets/vehicle_list_item.dart';
import 'package:ezcars/models/vehicle.dart';
import 'package:ezcars/services/impl/vehicle_service.dart';

class HomeScreen extends StatefulWidget {
  final VehicleService vehicleService; // Service to fetch the list of vehicles
  final LocationService locationService; // Service to handle location fetching

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
  Future<List<Vehicle>>? _vehiclesFuture; // Memoize the future to avoid refetching

  @override
  void initState() {
    super.initState();
    // Cache the future to avoid refetching on every rebuild.
    _vehiclesFuture = widget.vehicleService.getVehicles();
  }

  /// Function to toggle the selected vehicle's details visibility.
  void _toggleVehicleDetails(int index) {
    setState(() {
      // If the same vehicle is selected again, hide the details.
      _selectedVehicleIndex = (_selectedVehicleIndex == index) ? null : index;
    });
  }

  /// Refresh the vehicle list when the user pulls to refresh.
  Future<void> _refreshVehicles() async {
    // Trigger a re-fetch of the vehicle data.
    setState(() {
      _vehiclesFuture = widget.vehicleService.getVehicles();
    });
  }

  /// Fetch the user's location and handle errors
  Future<void> _fetchUserLocation() async {
    try {
      Position? position = await widget.locationService.fetchUserLocation(context);
      if (position != null) {
        // Show the position in a snackbar (you can update the logic as needed)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location fetched: ${position.latitude}, ${position.longitude}')),
        );
      }
    } catch (error) {
      // Show the error message in a snackbar using the localized message from LocationService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
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

            final vehicleList = snapshot.data ?? [];
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
