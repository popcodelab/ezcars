import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/distance_unit_provider.dart';
import '../../../models/vehicle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VehiculesListWidget extends StatelessWidget {
  final List<Vehicle> vehicles;
  final bool isLoading;
  final Function(LatLng) onCarTap;

  const VehiculesListWidget({
    super.key,
    required this.vehicles,
    required this.isLoading,
    required this.onCarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator if vehicles are still being fetched
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Loading available vehicles..."),
          ],
        ),
      );
    }

    if (vehicles.isEmpty) {
      // Show message if no vehicles are available
      return Container(
        height: 20, // Set a specific height for the container
        color: Colors.white.withOpacity(0.8), // Set background color with 80% opacity
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.no_vehicles_available.capitalize(),
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center, // Center align the text
          ),
        ),
      );
    }

    // Display vehicle cards as horizontal list
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            onCarTap(LatLng(vehicles[index].latitude, vehicles[index].longitude)); // Call the function passed from parent
          },
          child: Container(
            width: 250,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      child: Image.asset(
                        vehicles[index].imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicles[index].model,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(vehicles[index].price),
                        const SizedBox(height: 5),
                        Text(vehicles[index].location),
                        const SizedBox(height: 5),
                        // Use Consumer to dynamically update distance display with the correct unit
                        Consumer<DistanceUnitProvider>(
                          builder: (context, distanceUnitProvider, child) {
                            final displayUnit = (distanceUnitProvider.distanceUnit == 'kilometers') ? 'km' : 'miles';
                            return Text(
                              '${vehicles[index].distance.toStringAsFixed(2)} $displayUnit',
                              style: const TextStyle(fontSize: 14),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
