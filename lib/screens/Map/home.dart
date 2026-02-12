// import 'dart:async';

// import 'package:custom_info_window/custom_info_window.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:meet_me/screens/Map/location_map.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => HomeState();
// }

// class HomeState extends State<Home> {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();

//   Position? position;
//   @override
//   void initState() {
//     customMaker();
//     displayMarkers();
//     super.initState();
//     getLocation();
//   }

//   int sizeIcon = 35;
//   getLocation() async {
//     // position = await currentPosition();
//     // final GoogleMapController controller = await _controller.future;
//     // await controller.animateCamera(
//     //   CameraUpdate.newCameraPosition(
//     //     CameraPosition(
//     //       target: LatLng(position!.latitude, position!.longitude),
//     //       zoom: 19.151926040649414,
//     //     ),
//     //   ),
//     // );
//     setState(() {});
//   }

//   BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
//   void customMaker() {
//     BitmapDescriptor.asset(
//       ImageConfiguration(size: Size(30, 30)),
//       'assets/images/mark.png',
//     ).then((x) {
//       setState(() {
//         bitmapDescriptor = x;
//       });
//     });
//   }
//   // static CameraPosition _kGooglePlex = ;

//   // static const CameraPosition _kLake = CameraPosition(
//   //   bearing: 192.8334901395799,
//   //   target: LatLng(37.43296265331129, -122.08832357078792),
//   //   tilt: 59.440717697143555,
//   //   zoom: 19.151926040649414,
//   // );

//   get myLocation => LatLng(37.43296265331129, -122.08832357078792);
//   //LatLng(position?.latitude ?? 0, position?.longitude ?? 0);
//   get location1 => LatLng(6.692521, 3.324442);
//   get location2 => LatLng(37.43296265331129, -122.08832357078792);

//   List locations = [
//     [6.692521, 3.324442],
//     [6.690944, 3.329592],
//     [6.688983, 3.335772],
//     [6.688344, 3.341136],
//   ];

//   Set<Marker> markers = {};

//   displayMarkers() {
//     for (var item in data) {
//       final dataItem = DataModel.fromJson(item);
//       markers.add(
//         Marker(
//           markerId: MarkerId(dataItem.latt.toString()),
//           position: LatLng(dataItem.latt, dataItem.long),
//           flat: true,
//           rotation: 0,
//           onTap: () {
//             customInfoWindowController.hideInfoWindow;
//             customInfoWindowController.addInfoWindow!(
//               Container(color: Colors.white, child: Text(dataItem.desc)),
//               LatLng(dataItem.latt, dataItem.long),
//             );
//           },
//           // visible: position?.latitude != null,
//           // infoWindow: InfoWindow(
//           //   anchor: Offset(0, 0),
//           //   title: "Your location",
//           //   snippet: "Just at this point",
//           // ),
//           // icon: bitmapDescriptor,
//         ),
//       );
//     }
//   }

//   CustomInfoWindowController customInfoWindowController =
//       CustomInfoWindowController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             mapType: MapType.normal,
//             initialCameraPosition: CameraPosition(
//               target: location1,
//               zoom: 14.4746,
//             ),
//             onMapCreated: (GoogleMapController controller) {
//               customInfoWindowController.googleMapController = controller;
//               _controller.complete(controller);
//             },
//             markers: markers,
//           ),
//           CustomInfoWindow(
//             controller: customInfoWindowController,
//             height: 100,
//             width: 100,
//           ),

//           Positioned(
//             top: 100,
//             child: CustomMarkerContainer(
//               child: Row(
//                 children: [
//                   Icon(Icons.fastfood, color: Colors.white),
//                   SizedBox(width: 4),
//                   Text("Cass Mama"),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),

//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: _goToTheLake,
//       //   label: const Text('To the lake!'),
//       //   icon: const Icon(Icons.directions_boat),
//       // ),
//     );
//   }

//   // Future<void> _goToTheLake() async {
//   //   final GoogleMapController controller = await _controller.future;
//   //   await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   // }

//   var data = [
//     {
//       "name": 'O.B.O Foods',
//       'long': 6.692521,
//       'latt': 3.324442,
//       'category': "Restaurant",
//       'desc': "Rich food is a king food",
//       'price': "N200",
//       'others': ['Yam', 'Fufu', 'Rice'],
//     },
//     {
//       "name": 'Eat like king',
//       'long': 6.690944,
//       'latt': 3.329592,
//       'desc': "Best Place to fill up",
//       'price': "N200",
//       'category': "Restaurant",
//       'others': ['Salad', 'chicken', 'pizza'],
//     },
//     {
//       "name": 'Ayo Foods',
//       'long': 6.688983,
//       'latt': 3.335772,
//       'desc': "Best Place to fill your tommy with some good meal",
//       'price': "N200",
//       'category': "Restaurant",
//       'others': ['Rice', 'Amala', 'Iyan'],
//     },
//     {
//       "name": 'Mama Uche',
//       'long': 6.688344,
//       'latt': 3.341136,
//       'desc': "Best Igbo food",
//       'price': "N200",
//       'category': "Restaurant",
//       'others': ['Mix Potato', 'Ogbono', 'Banga'],
//     },
//   ];
// }

// class CustomMarkerContainer extends StatelessWidget {
//   const CustomMarkerContainer({
//     super.key,
//     this.width,
//     this.height,
//     this.color,
//     this.child,
//   });

//   final double? width;
//   final double? height;
//   final Color? color;
//   final Widget? child;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Container(
//           height: height,
//           decoration: BoxDecoration(
//             color: color ?? Colors.amber,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           width: width,
//           child: child,
//         ),
//         Positioned(
//           bottom: -10,
//           child: SizedBox(
//             width: width,
//             child: Center(
//               child: Transform.rotate(
//                 angle: 40,
//                 child: Container(
//                   color: color ?? Colors.amber,
//                   height: height ?? 20,
//                   width: height ?? 20,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class DataModel {
//   final String name;
//   final double long;
//   final double latt;
//   final String desc;
//   final String price;
//   final String category;
//   final List<String> others;

//   DataModel({
//     required this.long,
//     required this.latt,
//     required this.desc,
//     required this.price,
//     required this.others,
//     required this.category,
//     required this.name,
//   });

//   static DataModel fromJson(Map<String, dynamic> json) => DataModel(
//     long: json['long'],
//     desc: json['desc'],
//     latt: json['latt'],
//     name: json['name'],
//     others: json['others'],
//     category: json['category'],
//     price: json['price'],
//   );
// }
