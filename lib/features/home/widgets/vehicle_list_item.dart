import 'package:flutter/material.dart';
import 'package:ezcars/models/vehicle.dart';
import 'vehicle_details.dart';
import 'package:ezcars/services/i_location_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;
  final ILocationService locationService; // Add this if needed for fetching the location

  const VehicleListItem({
    Key? key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
    required this.locationService, // Pass the location service
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: onTap, // Handles toggling details when tapping the entire ListTile

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
            subtitle: Text(
              '${AppLocalizations.of(context)?.price ?? 'Price'}: ${vehicle.price}',
            ),
            trailing: Icon(isSelected ? Icons.expand_less : Icons.expand_more),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: VehicleDetails(
                vehicle: vehicle,
                locationService: locationService, // Pass the location service if required
              ),
            ),
        ],
      ),
    );
  }
}
