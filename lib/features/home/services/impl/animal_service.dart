
import '../../model/animal.dart';
import '../i_animal_service.dart';

// Animal Service with Local Asset Image Paths
class AnimalService implements IAnimalService {
  final List<Animal> _animals = [
    Animal(
      name: 'Lion',
      imageUrl: 'assets/images/lion.jpg',
      latitude: 12.9236,
      longitude: 100.8825,
    ),
    Animal(
      name: 'Elephant',
      imageUrl: 'assets/images/elephant.jpg',
      latitude: 12.9210,
      longitude: 100.8800,
    ),
    Animal(
      name: 'Giraffe',
      imageUrl: 'assets/images/giraffe.jpg',
      latitude: 12.9241,
      longitude: 100.8835,
    ),
    Animal(
      name: 'Zebra',
      imageUrl: 'assets/images/zebra.jpg',
      latitude: 12.9205,
      longitude: 100.8842,
    ),
    Animal(
      name: 'Tiger',
      imageUrl: 'assets/images/tiger.jpg',
      latitude: 12.9239,
      longitude: 100.8817,
    ),
    Animal(
      name: 'Bear',
      imageUrl: 'assets/images/bear.jpg',
      latitude: 12.9223,
      longitude: 100.8799,
    ),
    Animal(
      name: 'Wolf',
      imageUrl: 'assets/images/wolf.jpg',
      latitude: 12.9260,
      longitude: 100.8781,
    ),
    Animal(
      name: 'Monkey',
      imageUrl: 'assets/images/monkey.jpg',
      latitude: 12.9255,
      longitude: 100.8829,
    ),
    Animal(
      name: 'Panda',
      imageUrl: 'assets/images/panda.jpg',
      latitude: 12.9247,
      longitude: 100.8811,
    ),
    Animal(
      name: 'Kangaroo',
      imageUrl: 'assets/images/kangaroo.jpg',
      latitude: 12.9218,
      longitude: 100.8797,
    ),
  ];

  @override
  List<Animal> getAnimals() {
    return _animals;
  }
}
