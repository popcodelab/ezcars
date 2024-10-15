import 'package:ezcars/models/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ezcars/services/i_location_service.dart'; // Import the location service

/// Widget to display additional details about the selected vehicle.
/// It shows a larger image and detailed information like latitude, longitude, and address.
class VehicleDetails extends StatefulWidget {
  final Vehicle vehicle; // The vehicle for which details are shown
  final ILocationService locationService; // The service to fetch the address

  const VehicleDetails({
    super.key,
    required this.vehicle,
    required this.locationService,
  });

  @override
  _VehicleDetailsState createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  String? _address; // To store the fetched address
  bool _isLoading = true; // To show a loading indicator while fetching the address

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  /// Fetches the address using the latitude and longitude of the vehicle.
  Future<void> _fetchAddress() async {
    try {
      final address = await widget.locationService.getPlaceName(
        widget.vehicle.latitude,
        widget.vehicle.longitude, context
      );

      setState(() {
        _address = address ?? AppLocalizations.of(context)?.unknown_location ?? 'Unknown location';
        _isLoading = false; // Stop loading after fetching the address
      });
    } catch (error) {
      setState(() {
        _address = AppLocalizations.of(context)?.error_fetching_location ?? 'Failed to fetch location';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context); // Safe access to localizations

    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the details for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start of the column
        children: [
          // Vehicle's larger image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // Rounded corners for the image
            child: Image.asset(
              widget.vehicle.imageUrl,
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
            widget.vehicle.model,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0), // Small spacing between the name and details

          // Display the location with fallback text for localization
          Text(
            '${localizations?.location ?? 'Location'}: ${widget.vehicle.location}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4.0), // Spacing between location and address

          // Display the address fetched from the latitude and longitude
          _isLoading
              ? Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 10), // Spacing between the spinner and text
              Text(AppLocalizations.of(context)?.fetching_location_name ?? 'Fetching address...'),
            ],
          )
              : Text(
            _address ?? 'Unknown address',
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 4.0), // Small spacing between the address and latitude

          // Display the vehicle's latitude with localized text
          Text(
            '${localizations?.latitude ?? 'Latitude'}: ${widget.vehicle.latitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4.0),

          // Display the vehicle's longitude with localized text
          Text(
            '${localizations?.longitude ?? 'Longitude'}: ${widget.vehicle.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
