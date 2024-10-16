import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:ezcars/models/vehicle.dart';
import 'vehicle_details.dart';
import 'package:ezcars/services/i_location_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;
  final ILocationService locationService;
  final String distanceUnit; // The unit for distance (miles or kilometers)

  const VehicleListItem({
    Key? key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
    required this.locationService,
    required this.distanceUnit, // Pass the distance unit (miles or kilometers)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Main ListTile showing vehicle info
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

            // Vehicle Model and Price
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
                // Display the distance with unit
                Text(
                  '${AppLocalizations.of(context)?.distance.capitalize() ?? 'Distance'}: '
                      '${vehicle.distance?.toStringAsFixed(2)} $distanceUnit',
                ),
              ],
            ),

            // Expand/Collapse icon
            trailing: Icon(isSelected ? Icons.expand_less : Icons.expand_more),
          ),

          // Show more details if selected
          if (isSelected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: VehicleDetails(
                vehicle: vehicle,
                locationService: locationService, // Pass the location service to VehicleDetails
              ),
            ),
        ],
      ),
    );
  }
}
