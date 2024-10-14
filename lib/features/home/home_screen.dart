import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'model/animal.dart';
import 'services/impl/animal_service.dart';
import 'widgets/animal_details.dart';

/// The `HomeScreen` displays a list of animals fetched from the `AnimalService`.
/// Each animal is shown with its image, name, and location (latitude and longitude).
/// The user can toggle the visibility of additional details for each animal.
class HomeScreen extends StatefulWidget {
  final AnimalService animalService; // Service to fetch the list of animals

  const HomeScreen({super.key, required this.animalService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedAnimalIndex; // Keeps track of the currently selected animal to show details

  /// Function to toggle the selected animal's details visibility.
  void _toggleAnimalDetails(int index) {
    setState(() {
      _selectedAnimalIndex = (_selectedAnimalIndex == index) ? null : index;
    });
  }

  /// Builds the main UI for the `HomeScreen`.
  ///
  /// The `ListView` displays all animals in a card, with the option to
  /// show more details when the corresponding button is pressed.
  @override
  Widget build(BuildContext context) {
    // Get the list of animals from the service
    List<Animal> animals = widget.animalService.getAnimals();

    // Check if localizations are loaded and available
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // If localizations are not yet available, show a loading indicator
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.animal_list), // Localized title for the app bar
      ),
      body: ListView.builder(
        itemCount: animals.length, // Number of animals to display
        itemBuilder: (context, index) {
          Animal animal = animals[index]; // Get the current animal from the list
          return Card(
            child: Column(
              children: [
                ListTile(
                  // Display the animal's image with rounded corners
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Rounded image corners
                    child: Image.asset(
                      animal.imageUrl, // Animal's image path
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover, // Ensure the image fills the allocated space
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback image in case the provided animal image cannot be loaded
                        return Image.asset(
                          'assets/images/animals/default_animal.png', // Default image path
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  title: Text(animal.name), // Animal's name
                  subtitle: Text(
                    '${localizations.location}: ${animal.latitude.toStringAsFixed(4)}, ${animal.longitude.toStringAsFixed(4)}', // Localized location with latitude and longitude
                  ),
                  // Button to toggle details for the selected animal
                  trailing: ElevatedButton(
                    onPressed: () => _toggleAnimalDetails(index), // Toggle visibility on button press
                    // Button text shows "Show Details" or "Hide Details" based on the visibility state
                    child: Text(
                      _selectedAnimalIndex == index
                          ? localizations.hide_details // Localized text for hiding details
                          : localizations.showDetails, // Localized text for showing details
                    ),
                  ),
                ),
                // Smooth animation for showing/hiding animal details
                AnimatedSize(
                  duration: const Duration(milliseconds: 300), // Animation duration
                  curve: Curves.easeInOut, // Smooth easing animation
                  child: (_selectedAnimalIndex == index)
                      ? AnimalDetails(animal: animal) // Show details if selected
                      : const SizedBox.shrink(), // Hide details when not selected
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
