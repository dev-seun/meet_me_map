import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'model.dart';

final _rand = Random();

LatLng randomNearbyLatLng(
  double baseLat,
  double baseLng, {
  double maxDistance = 0.002,
}) {
  final latOffset = (_rand.nextDouble() - 0.5) * maxDistance * 2;
  final lngOffset = (_rand.nextDouble() - 0.5) * maxDistance * 2;

  return LatLng(baseLat + latOffset, baseLng + lngOffset);
}

_generateID() => Random().nextInt(999999999).toString();

List<DataModel> generateMockData({
  int count = 100,
  double? bLat,
  double? bLng,
  double proximity = 0.002,
}) {
  double baseLat = bLat ?? 0;
  double baseLng = bLng ?? 0;

  return List.generate(count, (index) {
    final category = categories[index % categories.length];
    final location = randomNearbyLatLng(
      baseLat,
      baseLng,
      maxDistance: proximity,
    );

    return DataModel(
      id: _generateID(),
      name: '$category ${index + 1}',
      latt: location.latitude,
      long: location.longitude,
      category: category,
      desc: 'Popular $category serving locals around this area.',
      price: '₦${(500 + _rand.nextInt(3000))}',
      others: _sampleExtras(category),
    );
  });
}

List<String> _sampleExtras(String category) {
  switch (category) {
    case 'Restaurant':
    case 'Fast Food':
      return ['Rice', 'Chicken', 'Swallow'];
    case 'Cafe':
      return ['Coffee', 'Tea', 'Snacks'];
    case 'Pharmacy':
      return ['Drugs', 'First Aid', 'Vitamins'];
    case 'Supermarket':
      return ['Groceries', 'Drinks', 'Household items'];
    case 'Fuel Station':
      return ['Petrol', 'Diesel', 'Air'];
    case 'Hospital':
      return ['Emergency', 'Consultation', 'Lab'];
    case 'School':
      return ['Classes', 'Library', 'Sports'];
    default:
      return ['Service A', 'Service B'];
  }
}

const categories = [
  'Restaurant',
  'Cafe',
  'Pharmacy',
  'Supermarket',
  'Bakery',
  'Fast Food',
  'Bar',
  'Hospital',
  'School',
  'Fuel Station',
];


// List<DataModel> data = [
//   DataModel.fromJson({
//     "id": '1',
//     "name": 'O.B.O Foods',
//     'latt': 6.692521,
//     'long': 3.324442,
//     'category': "Restaurant",
//     'desc': "Rich food is a king food",
//     'price': "N200",
//     'others': ['Yam', 'Fufu', 'Rice'],
//   }),
//   DataModel.fromJson({
//     "id": '2',
//     "name": 'Eat like king',
//     'latt': 6.690944,
//     'long': 3.329592,
//     'desc': "Best Place to fill up",
//     'price': "N200",
//     'category': "Restaurant",
//     'others': ['Salad', 'chicken', 'pizza'],
//   }),
//   DataModel.fromJson({
//     "id": '2',
//     "name": 'Ayo Foods canteen',
//     'latt': 6.688983,
//     'long': 3.335772,
//     'desc': "Best Place to fill your tommy with some good meal",
//     'price': "N200",
//     'category': "Restaurant",
//     'others': ['Rice', 'Amala', 'Iyan'],
//   }),
//   DataModel.fromJson({
//     "id": '3',
//     "name": 'Mama Uche',
//     'latt': 6.688344,
//     'long': 3.341136,
//     'desc': "Best Igbo food",
//     'price': "N200",
//     'category': "Restaurant",
//     'others': ['Mix Potato', 'Ogbono', 'Banga'],
//   }),
// ];



// LatLng randomNearbyLatLng(double baseLat, double baseLng) {
//   // ~0.002 ≈ 200–250m
//   final latOffset = (_rand.nextDouble() - 0.5) * 0.114;
//   final lngOffset = (_rand.nextDouble() - 0.5) * 0.114;

//   return LatLng(baseLat + latOffset, baseLng + lngOffset);
// }

// // List<DataModel> generateMockData() {
// //   const baseLat = 6.6905;
// //   const baseLng = 3.3320;

// //   return List.generate(100, (index) {
// //     final category = categories[index % categories.length];
// //     final location = randomNearbyLatLng(baseLat, baseLng);

// //     return DataModel(
// //       id: (index + 1).toString(),
// //       name: '$category ${index + 1}',
// //       latt: location.latitude,
// //       long: location.longitude,
// //       category: category,
// //       desc: 'Popular $category serving locals around this area.',
// //       price: '₦${(500 + _rand.nextInt(3000))}',
// //       others: _sampleExtras(category),
// //     );
// //   });
// // }