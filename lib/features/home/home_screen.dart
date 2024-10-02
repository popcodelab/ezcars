import 'package:flutter/material.dart';

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
    //List<Animal> animals = widget.animalService.getAnimals().take(5).toList();
    List<Animal> animals = widget.animalService.getAnimals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal List'),
      ),
      body: ListView.builder(
        itemCount: animals.length,
        itemBuilder: (context, index) {
          Animal animal = animals[index];
          return Card(
            child: Column(
              children: [
                ListTile(
                  leading:  Image.asset(animal.imageUrl, width: 50, height: 50), // Use Image.asset
                  title: Text(animal.name),
                  subtitle: Text(
                      'Location: ${animal.latitude.toStringAsFixed(4)}, ${animal.longitude.toStringAsFixed(4)}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedAnimalIndex = (_selectedAnimalIndex == index)
                            ? null
                            : index; // Toggle details visibility
                      });
                    },
                    child: Text(_selectedAnimalIndex == index ? 'Hide Details' : 'Show Details'),
                  ),
                ),
                if (_selectedAnimalIndex == index)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          animal.imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          animal.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Latitude: ${animal.latitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Longitude: ${animal.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}