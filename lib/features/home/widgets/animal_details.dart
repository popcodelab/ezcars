import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/animal.dart';


/// Widget to display additional details about the selected animal.
/// It shows a larger image and detailed information like latitude and longitude.
class AnimalDetails extends StatelessWidget {
  final Animal animal; // The animal for which details are shown

  const AnimalDetails({super.key, required this.animal});

  /// Builds the detailed view of the animal.
  ///
  /// The UI shows a larger image and additional details such as the animal's
  /// name, latitude, and longitude.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the details for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start of the column
        children: [
          // Animal's larger image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // Rounded corners for the image
            child: Image.asset(
              animal.imageUrl,
              height: 150, // Larger image height
              width: double.infinity, // Full width of the available space
              fit: BoxFit.cover, // Ensure the image fills the allocated space
              errorBuilder: (context, error, stackTrace) {
                // Fallback image in case the provided animal image cannot be loaded
                return Image.asset(
                  'assets/images/animals/default_animal.png', // Default image path
                  height: 150, // Larger image height
                  width: double.infinity, // Full width of the available space
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 8.0), // Spacing between image and text
          // Animal's name with larger, bold font
          Text(
            animal.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0), // Small spacing between the name and details
          // Display the animal's latitude with localized text
          Text(
            '${AppLocalizations.of(context)!.latitude}: ${animal.latitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
          // Display the animal's longitude with localized text
          Text(
            '${AppLocalizations.of(context)!.longitude}: ${animal.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}