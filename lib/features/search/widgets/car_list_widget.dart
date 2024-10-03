import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/car.dart';

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
      return const Center(
        child: Text("No cars available at the moment.", style: TextStyle(fontSize: 16)),
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
                      child: _buildCarImage(cars[index].image),
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

  /// Builds the car image widget, handling missing images by using a default placeholder.
  Widget _buildCarImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 150,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/default_car.png', // Path to default image
          fit: BoxFit.cover,
          width: double.infinity,
          height: 150,
        );
      },
    );
  }
}
