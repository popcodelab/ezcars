import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

import '../../../models/vehicle.dart';
import 'vehicle_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A modularized component for displaying a vehicle in a list item.
class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleListItem({
    Key? key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            // Tap the entire ListTile to show/hide vehicle details
            onTap: onTap, // Handles toggling details
            // Display the vehicle's image from the assets folder
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                vehicle.imageUrl, // Asset path for the image
                width: 50,
                height: 50,
                fit: BoxFit.cover, // Ensure the image fits within the box
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to an icon if the image fails to load
                  return const Icon(Icons.car_rental, size: 50, color: Colors.grey);
                },
              ),
            ),
            // Display the vehicle model using theme-based styling
            title: Text(
              vehicle.model,
              style: Theme.of(context).textTheme.titleMedium, // Use theme's subtitle style
            ),
            // Display the vehicle price using localized text
            subtitle: Text(
              '${AppLocalizations.of(context)?.price.capitalize()??'Price'}: ${vehicle.price}',
            ),
            // Show an expand/collapse icon based on the selected state
            trailing: Icon(isSelected ? Icons.expand_less : Icons.expand_more),
          ),
          // Show vehicle details if this item is selected
          if (isSelected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              // Display the detailed information of the vehicle
              child: VehicleDetails(vehicle: vehicle),
            ),
        ],
      ),
    );
  }
}