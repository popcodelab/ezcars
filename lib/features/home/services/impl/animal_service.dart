
import '../../model/animal.dart';
import '../i_animal_service.dart';

// Animal Service with Local Asset Image Paths
class AnimalService implements IAnimalService {
  final List<Animal> _animals = [
    Animal(
      name: 'Lion',
      imageUrl: 'assets/images/animals/lion.jpg',
      latitude: 12.9236,
      longitude: 100.8825,
    ),
    Animal(
      name: 'Elephant',
      imageUrl: 'assets/images/animals/elephant.jpg',
      latitude: 12.9210,
      longitude: 100.8800,
    ),
    Animal(
      name: 'Giraffe',
      imageUrl: 'assets/images/animals/giraffe.jpg',
      latitude: 12.9241,
      longitude: 100.8835,
    ),
    Animal(
      name: 'Zebra',
      imageUrl: 'assets/images/animals/zebra.jpg',
      latitude: 12.9205,
      longitude: 100.8842,
    ),
    Animal(
      name: 'Tiger',
      imageUrl: 'assets/images/animals/tiger.jpg',
      latitude: 12.9239,
      longitude: 100.8817,
    ),
    Animal(
      name: 'Bear',
      imageUrl: 'assets/images/animals/bear.jpg',
      latitude: 12.9223,
      longitude: 100.8799,
    ),
    Animal(
      name: 'Wolf',
      imageUrl: 'assets/images/animals/wolf.jpg',
      latitude: 12.9260,
      longitude: 100.8781,
    ),
    Animal(
      name: 'Monkey',
      imageUrl: 'assets/images/animals/monkey.jpg',
      latitude: 12.9255,
      longitude: 100.8829,
    ),
    Animal(
      name: 'Panda',
      imageUrl: 'assets/images/animals/panda.jpg',
      latitude: 12.9247,
      longitude: 100.8811,
    ),
    Animal(
      name: 'Kangaroo',
      imageUrl: 'assets/images/animals/kangaroo.jpg',
      latitude: 12.9218,
      longitude: 100.8797,
    ),
  ];

  @override
  List<Animal> getAnimals() {
    return _animals;
  }
}
