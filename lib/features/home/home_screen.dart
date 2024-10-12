import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'model/animal.dart';
import 'services/impl/animal_service.dart';

// HomeScreen with a list of animals and the ability to toggle in-place details for each animal
class HomeScreen extends StatefulWidget {
  final AnimalService animalService;

  const HomeScreen({super.key, required this.animalService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedAnimalIndex; // Keeps track of which animal's details are currently visible

  @override
  Widget build(BuildContext context) {
    // Get list of animals from the service
    List<Animal> animals = widget.animalService.getAnimals();

    // Check if AppLocalizations is available to prevent accessing it too early
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // If localization is still null, show a loading spinner
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.animalListTitle), // Set the title from localizations
      ),
      body: ListView.builder(
        itemCount: animals.length, // The number of items is the length of the animals list
        itemBuilder: (context, index) {
          Animal animal = animals[index]; // Get the current animal
          return Card(
            child: Column(
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                    child: Image.asset(
                      animal.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover, // Ensure the image fits the space
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback image in case the animal image cannot be loaded
                        return Image.asset(
                          'assets/images/animals/default_animal.png', // Default image path
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  title: Text(animal.name), // Display the animal's name
                  subtitle: Text(
                    '${localizations.location}: ${animal.latitude.toStringAsFixed(4)}, ${animal.longitude.toStringAsFixed(4)}', // Display location coordinates
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Toggle the visibility of details: if this animal's details are visible, hide them, otherwise show
                        _selectedAnimalIndex = (_selectedAnimalIndex == index) ? null : index;
                      });
                    },
                    child: Text(
                      _selectedAnimalIndex == index
                          ? localizations.hideDetails // Show 'Hide Details' if the details are visible
                          : localizations.showDetails, // Show 'Show Details' if the details are hidden
                    ),
                  ),
                ),
                // Display animal details if the selected index matches the current animal
                if (_selectedAnimalIndex == index) AnimalDetails(animal: animal),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Extracted widget for displaying detailed information about the animal
class AnimalDetails extends StatelessWidget {
  final Animal animal;

  const AnimalDetails({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Add padding around the details
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // Rounded corners for the larger image
            child: Image.asset(
              animal.imageUrl,
              height: 150,
              width: double.infinity, // Full width of the screen
              fit: BoxFit.cover, // Ensure the image covers the space
              errorBuilder: (context, error, stackTrace) {
                // Fallback image in case the animal image cannot be loaded
                return Image.asset(
                  'assets/images/animals/default_animal.png', // Default image path
                  height: 150,
                  width: double.infinity, // Full width of the screen
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 8.0), // Add spacing between the image and text
          Text(
            animal.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Animal name with larger, bold font
          ),
          const SizedBox(height: 4.0), // Small spacing between name and details
          Text(
            '${AppLocalizations.of(context)!.latitude}: ${animal.latitude.toStringAsFixed(4)}', // Display the animal's latitude
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${AppLocalizations.of(context)!.longitude}: ${animal.longitude.toStringAsFixed(4)}', // Display the animal's longitude
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
