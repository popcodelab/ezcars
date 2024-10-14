import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:ezcars/models/vehicle.dart';
import 'package:ezcars/services/impl/vehicle_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'widgets/vehicle_list_item.dart';

class HomeScreen extends StatefulWidget {
  final VehicleService vehicleService; // Service to fetch the list of vehicles

  const HomeScreen({super.key, required this.vehicleService});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Display the title using localized text with fallback
        title: Text(AppLocalizations.of(context)?.vehicles_list.capitalize() ?? 'Vehicle List'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVehicles, // Handle pull-to-refresh
        child: FutureBuilder<List<Vehicle>>(
          future: _vehiclesFuture, // Use the cached future to avoid multiple fetches
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading message while fetching vehicles
              return Center(child: Text(AppLocalizations.of(context)?.loading_vehicles.capitalize() ??'Loading vehicles...'));
            }
            if (snapshot.hasError) {
              // Show an error message if something went wrong during the fetch
              return Center(child: Text(AppLocalizations.of(context)?.error_fetching_vehicles.capitalize() ??'Failed to load vehicles. Please try again.'));
            }

            final vehicleList = snapshot.data ?? [];
            if (vehicleList.isEmpty) {
              // Show a message if there are no vehicles available
              return Center(child: Text(AppLocalizations.of(context)?.no_vehicles_available.capitalize() ??'No vehicles available.'));
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}