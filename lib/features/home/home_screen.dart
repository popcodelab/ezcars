import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ezcars/services/i_location_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/i_vehicle_service.dart';
import 'widgets/vehicle_list_item.dart';
import 'package:ezcars/models/vehicle.dart';

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
    _vehiclesFuture = widget.vehicleService.getVehicles(); // Fetch the initial vehicle list
  }

  /// Toggle the selected vehicle's details visibility
  void _toggleVehicleDetails(int index) {
    setState(() {
      _selectedVehicleIndex = (_selectedVehicleIndex == index) ? null : index;
    });
  }

  /// Refresh the vehicle list when the user pulls to refresh
  Future<void> _refreshVehicles() async {
    setState(() {
      _filteredVehicles = []; // Clear the filtered list, showing all vehicles
      _vehiclesFuture = widget.vehicleService.getVehicles(); // Fetch all vehicles
    });
  }

  /// Fetch the user's location and filter vehicles within a 15-minute walking distance
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

  /// Filter vehicles based on proximity using `VehicleService`
  void _filterVehiclesByProximity() async {
    if (_userPosition == null) return;

    final vehicles = await widget.vehicleService.getVehicles();
    final filteredVehicles = await widget.vehicleService.filterVehiclesByProximity(
      vehicles,
      _userPosition!,
      walkingDistanceRadiusMeters,
    );

    setState(() {
      _filteredVehicles = filteredVehicles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          future: _vehiclesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text(AppLocalizations.of(context)?.loading_vehicles ?? 'Loading vehicles...'));
            }
            if (snapshot.hasError) {
              return Center(child: Text(AppLocalizations.of(context)?.error_fetching_vehicles ?? 'Failed to load vehicles. Please try again.'));
            }

            final vehicleList = _filteredVehicles.isNotEmpty
                ? _filteredVehicles
                : snapshot.data ?? [];

            if (vehicleList.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)?.no_vehicles_available ?? 'No vehicles available.'));
            }

            return ListView.builder(
              itemCount: vehicleList.length,
              itemBuilder: (context, index) {
                Vehicle vehicle = vehicleList[index];
                bool isSelected = _selectedVehicleIndex == index;

                return VehicleListItem(
                  vehicle: vehicle,
                  isSelected: isSelected,
                  onTap: () => _toggleVehicleDetails(index),
                  locationService: widget.locationService,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
