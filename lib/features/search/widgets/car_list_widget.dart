import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/car.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CarListWidget extends StatelessWidget {
  final List<Car> cars;
  final bool isLoading;
  final Function(LatLng) onCarTap;

  const CarListWidget({
    super.key,
    required this.cars,
    required this.isLoading,
    required this.onCarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator if cars are still being fetched
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Loading available cars..."),
          ],
        ),
      );
    }

    if (cars.isEmpty) {
      // Show message if no cars are available
      return Container(
        height: 20, // Set a specific height for the container
        color: Colors.white.withOpacity(0.8), // Set background color with 80% opacity
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.no_cars_available.capitalize(),
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center, // Center align the text
          ),
        ),
      );
    }

    // Display car cards as horizontal list
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: cars.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            onCarTap(LatLng(cars[index].lat, cars[index].lng)); // Call the function passed from parent
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
                        cars[index].image,
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
                          cars[index].name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(cars[index].price),
                        const SizedBox(height: 5),
                        Text(cars[index].location),
                        const SizedBox(height: 5),
                        Text(cars[index].distance),
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
