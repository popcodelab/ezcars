import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart'; // Import provider
import '../../providers/walking_radiius_provider.dart';
import '../../services/i_location_service.dart';
import '../../services/i_vehicle_service.dart';
import 'widgets/vehicle_list_item.dart';
import 'package:ezcars/models/vehicle.dart';
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
  Future<List<Vehicle>>? _vehiclesFuture;
  Position? _userPosition;
  List<Vehicle> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = widget.vehicleService.getVehicles();
  }

  void _toggleVehicleDetails(int index) {
    setState(() {
      _selectedVehicleIndex = (_selectedVehicleIndex == index) ? null : index;
    });
  }

  Future<void> _refreshVehicles() async {
    setState(() {
      _filteredVehicles = [];
      _vehiclesFuture = widget.vehicleService.getVehicles();
    });
  }

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

  void _filterVehiclesByProximity() async {
    if (_userPosition == null) return;

    final radiusProvider = Provider.of<WalkingRadiusProvider>(context, listen: false);

    final vehicles = await widget.vehicleService.getVehicles();
    final filteredVehicles = await widget.vehicleService.filterVehiclesByProximity(
      vehicles,
      _userPosition!,
      radiusProvider,
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
            onPressed: _fetchUserLocation,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVehicles,
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
