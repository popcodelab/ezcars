import 'package:ezcars/models/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


/// Widget to display additional details about the selected vehicle.
/// It shows a larger image and detailed information like latitude and longitude.
class VehicleDetails extends StatelessWidget {
  final Vehicle vehicle; // The vehicle for which details are shown

  const VehicleDetails({super.key, required this.vehicle});

  /// Builds the detailed view of the vehicle.
  ///
  /// The UI shows a larger image and additional details such as the vehicle's
  /// name, latitude, and longitude.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the details for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start of the column
        children: [
          // Vehicle's larger image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // Rounded corners for the image
            child: Image.asset(
              vehicle.imageUrl,
              height: 150, // Larger image height
              width: double.infinity, // Full width of the available space
              fit: BoxFit.cover, // Ensure the image fills the allocated space
              errorBuilder: (context, error, stackTrace) {
                // Fallback image in case the provided vehicle image cannot be loaded
                return Image.asset(
                  'assets/images/default_car.png', // Default image path
                  height: 150, // Larger image height
                  width: double.infinity, // Full width of the available space
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 8.0), // Spacing between image and text
          // Vehicle's name with larger, bold font
          Text(
            vehicle.model,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0), // Small spacing between the name and details
          Text(
            '${AppLocalizations.of(context)!.location}: ${vehicle.location}',
            style: const TextStyle(fontSize: 16),
          ),
          // Display the vehicle's latitude with localized text
          Text(
            '${AppLocalizations.of(context)!.latitude}: ${vehicle.latitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
          // Display the vehicle's longitude with localized text
          Text(
            '${AppLocalizations.of(context)!.longitude}: ${vehicle.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}