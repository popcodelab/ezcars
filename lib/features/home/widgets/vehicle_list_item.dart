import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng class
import 'package:ezcars/extensions/string_extensions.dart';
import 'package:ezcars/models/vehicle.dart';
import 'package:provider/provider.dart';
import '../../../providers/distance_unit_provider.dart';
import 'vehicle_details.dart';
import 'package:ezcars/services/i_location_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;
  final ILocationService locationService;
  String distanceUnit;
  final Function(LatLng) onDoubleTapNavigate; // Function to handle double-tap and navigate

  VehicleListItem({
    super.key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
    required this.locationService,
    required this.distanceUnit,
    required this.onDoubleTapNavigate, // Pass the function for double-tap navigation
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        // Navigate to the vehicle's location on double-tap
        onDoubleTapNavigate(LatLng(vehicle.latitude, vehicle.longitude));
      },
      child: Card(
        child: Column(
          children: [
            ListTile(
              onTap: onTap, // Toggle the expanded details when tapped
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  vehicle.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.car_rental, size: 50, color: Colors.grey);
                  },
                ),
              ),
              title: Text(
                vehicle.model,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context)?.price.capitalize() ?? 'Price'}: ${vehicle.price}',
                  ),
                  // Use Consumer to listen for changes in DistanceUnitProvider
                  Consumer<DistanceUnitProvider>(
                    builder: (context, distanceUnitProvider, child) {
                      final displayUnit = (distanceUnitProvider.distanceUnit == 'kilometers') ? 'km' : 'miles';
                      return Text(
                        '${AppLocalizations.of(context)?.distance.capitalize() ?? 'Distance'}: '
                            '${vehicle.distance.toStringAsFixed(2)} $displayUnit',
                      );
                    },
                  ),
                ],
              ),
              trailing: Icon(isSelected ? Icons.expand_less : Icons.expand_more),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: VehicleDetails(
                  vehicle: vehicle,
                  locationService: locationService,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
