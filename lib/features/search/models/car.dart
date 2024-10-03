// car model

class Car {
  final String name;
  final String image;
  final String price;
  final String location;
  final String distance;
  final double lat;
  final double lng;

  Car({
    required this.name,
    required this.image,
    required this.price,
    required this.location,
    required this.distance,
    required this.lat,
    required this.lng,
  });

  static List<Car> getCars() {
    return [
      Car(
        name: 'Tesla Model 3',
        image: 'assets/images/tesla.jpeg',
        price: '\$45/day',
        location: 'Downtown Garage',
        distance: '2.5 miles',
        lat: 34.0522,
        lng: -118.2437,
      ),
      Car(
        name: 'BMW i8',
        image: 'assets/images/bmw.jpeg',
        price: '\$120/day',
        location: 'Uptown Parking Lot',
        distance: '4.8 miles',
        lat: 34.0530,
        lng: -118.2420,
      ),
      Car(
        name: 'Audi A7',
        image: 'assets/images/audi.jpg',
        price: '\$80/day',
        location: 'Midtown Garage',
        distance: '3.2 miles',
        lat: 12.9122285,
        lng: 100.8640967,
      ),
    ];
  }
}
