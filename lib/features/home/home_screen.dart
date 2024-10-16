import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle.dart';
import '../../providers/walking_radiius_provider.dart';
import '../../providers/distance_unit_provider.dart';
import '../../services/i_location_service.dart';
import '../../services/i_vehicle_service.dart';
import 'widgets/vehicle_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final IVehicleService vehicleService;
  final ILocationService locationService;

  const HomeScreen({
    super.key,
    required this.vehicleService,
    required this.locationService,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedVehicleIndex;
  Position? _userPosition;
  List<Vehicle> _vehicles = [];
  bool _loadingFiltered = false;
  bool _useRadiusFilter = false; // Flag to determine if radius filter is used

  @override
  void initState() {
    super.initState();
    _fetchUserLocation(); // Fetch the user's location upon initialization
  }

  void _toggleVehicleDetails(int index) {
    setState(() {
      _selectedVehicleIndex = (_selectedVehicleIndex == index) ? null : index;
    });
  }

  /// Fetch user location when the screen loads
  Future<void> _fetchUserLocation() async {
    try {
      setState(() {
        _loadingFiltered = true;
      });
      Position? position = await widget.locationService.fetchUserLocation(context);
      if (position != null) {
        setState(() {
          _userPosition = position;
        });
        await _loadAllVehicles(); // Load all vehicles initially
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location fetched: ${position.latitude}, ${position.longitude}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.error_fetching_location ?? 'Failed to fetch location.')),
      );
    } finally {
      setState(() {
        _loadingFiltered = false;
      });
    }
  }

  /// Load all vehicles and sort them by distance from the user's location
  Future<void> _loadAllVehicles() async {
    if (_userPosition == null) return;

    final distanceUnitProvider = Provider.of<DistanceUnitProvider>(context, listen: false);

    // Fetch all vehicles and calculate their distances from the user's location
    final vehicles = await widget.vehicleService.getVehicles();
    final vehiclesWithDistance = await widget.vehicleService.calculateVehicleDistances(
      vehicles,
      _userPosition!,
      unit: distanceUnitProvider.distanceUnit,
    );

    // Sort vehicles by distance
    vehiclesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {
      _vehicles = vehiclesWithDistance;
      _useRadiusFilter = false; // No radius filter applied
    });
  }

  /// Filter vehicles by proximity using the WalkingRadiusProvider
  Future<void> _loadFilteredVehicles() async {
    if (_userPosition == null) return;

    final radiusProvider = Provider.of<WalkingRadiusProvider>(context, listen: false);
    final distanceUnitProvider = Provider.of<DistanceUnitProvider>(context, listen: false);

    // Fetch and filter vehicles by proximity (walking radius)
    final filteredVehicles = await widget.vehicleService.filterVehiclesByProximity(
      await widget.vehicleService.getVehicles(),
      _userPosition!,
      radiusProvider,
      unit: distanceUnitProvider.distanceUnit,
    );

    setState(() {
      _vehicles = filteredVehicles;
      _useRadiusFilter = true; // Radius filter is applied
    });
  }

  /// Remove radius filter and display all vehicles again
  Future<void> _removeRadiusFilterAndLoadAllVehicles() async {
    setState(() {
      _useRadiusFilter = false; // Disable radius filter
    });
    await _loadAllVehicles(); // Reload all vehicles without filter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.vehicles_list ?? 'Vehicle List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadFilteredVehicles, // Load vehicles filtered by walking radius
          ),
          Consumer<DistanceUnitProvider>(
            builder: (context, distanceUnitProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  distanceUnitProvider.updateDistanceUnit(value); // Update the distance unit
                  if (_userPosition != null) {
                    if (_useRadiusFilter) {
                      _loadFilteredVehicles(); // Recalculate distances after changing unit, with filter
                    } else {
                      _loadAllVehicles(); // Recalculate distances after changing unit, without filter
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'miles',
                    child: Text('Miles'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'kilometers',
                    child: Text('Kilometers'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _removeRadiusFilterAndLoadAllVehicles, // Reload all vehicles without filter
        child: _loadingFiltered
            ? const Center(child: CircularProgressIndicator()) // Show loading spinner while loading
            : ListView.builder(
          itemCount: _vehicles.length, // List of vehicles (filtered or not)
          itemBuilder: (context, index) {
            Vehicle vehicle = _vehicles[index];
            bool isSelected = _selectedVehicleIndex == index;

            return VehicleListItem(
              vehicle: vehicle,
              isSelected: isSelected,
              onTap: () => _toggleVehicleDetails(index), // Toggle details when tapped
              locationService: widget.locationService, // Pass locationService to each list item
              distanceUnit: Provider.of<DistanceUnitProvider>(context, listen: false).distanceUnit, // Pass distance unit from provider
            );
          },
        ),
      ),
    );
  }
}
