import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'model/animal.dart';
import 'services/impl/animal_service.dart';

// HomeScreen with Animal List and In-Place Details
class HomeScreen extends StatefulWidget {
  final AnimalService animalService;

  const HomeScreen({super.key, required this.animalService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedAnimalIndex;

  @override
  Widget build(BuildContext context) {
    List<Animal> animals = widget.animalService.getAnimals();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.animalListTitle),
      ),
      body: ListView.builder(
        itemCount: animals.length,
        itemBuilder: (context, index) {
          Animal animal = animals[index];
          return Card(
            child: Column(
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      animal.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to a default image if the specified asset is missing
                        return Image.asset(
                          'assets/images/animals/default_animal.png', // Default image path
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  title: Text(animal.name),
                  subtitle: Text(
                    '${AppLocalizations.of(context)!.location}: ${animal.latitude.toStringAsFixed(4)}, ${animal.longitude.toStringAsFixed(4)}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Toggle details visibility
                        _selectedAnimalIndex =
                            (_selectedAnimalIndex == index) ? null : index;
                      });
                    },
                    child: Text(
                      _selectedAnimalIndex == index
                          ? AppLocalizations.of(context)!.hideDetails
                          : AppLocalizations.of(context)!.showDetails,
                    ),
                  ),
                ),
                if (_selectedAnimalIndex == index)
                  AnimalDetails(animal: animal), // Extracted details widget
              ],
            ),
          );
        },
      ),
    );
  }
}

// Extracted widget for displaying animal details
class AnimalDetails extends StatelessWidget {
  final Animal animal;

  const AnimalDetails({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              animal.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to a default image if the specified asset is missing
                return Image.asset(
                  'assets/images/animals/default_animal.png', // Default image path
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            animal.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            '${AppLocalizations.of(context)!.latitude}: ${animal.latitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${AppLocalizations.of(context)!.longitude}: ${animal.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
