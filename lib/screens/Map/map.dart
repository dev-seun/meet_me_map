// import 'dart:async';
// import 'dart:developer';
// import 'package:custom_info_window/custom_info_window.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:meet_me/screens/Map/common/bottom_sheet.dart';
// import 'common/marker_container.dart';
// import 'common/marker_creator.dart';
// import 'functions.dart';
// import 'location_permission.dart';
// import 'model.dart';

// class MapHome extends StatefulWidget {
//   const MapHome({super.key});

//   @override
//   State<MapHome> createState() => MapHomeState();
// }

// class MapHomeState extends State<MapHome> with TickerProviderStateMixin {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();

//   Position? position;
//   late List<DataModel> mainData;
//   AnimationController? animationController;
//   @override
//   void initState() {
//     loadIcons().then((marker) => getCurrentLocation(marker));
//     super.initState();
//   }

//   // createUserMarker() async {
//   //   //add marker
//   //   BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
//   //   await BitmapDescriptor.asset(
//   //     ImageConfiguration(size: Size(30, 30)),
//   //     'assets/images/mark.png',
//   //   ).then((x) {
//   //     setState(() {
//   //       bitmapDescriptor = x;
//   //     });
//   //   });
//   //   markers.add(
//   //     Marker(
//   //       markerId: MarkerId("001"),
//   //       position: LatLng(position!.latitude, position!.longitude),
//   //       flat: true,
//   //       rotation: 0,
//   //       icon: bitmapDescriptor,
//   //     ),
//   //   );
//   // }

//   ////////////////////////////////
//   ///////////////////////////////////
//   Marker? userMarker;
//   Future<void> createUserMarker(BitmapDescriptor bitmapDescriptor) async {
//     userMarker = Marker(
//       markerId: const MarkerId("001"),
//       position: LatLng(position!.latitude, position!.longitude),
//       flat: true,
//       anchor: const Offset(0.5, 0.5),
//       icon: bitmapDescriptor,
//     );

//     markers.add(userMarker!);

//     setState(() {});
//   }

//   void animateUserMarker(LatLng to) {
//     if (userMarker == null) return;
//     animationController?.dispose();
//     final from = userMarker!.position;

//     animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     final animation = CurvedAnimation(
//       parent: animationController!,
//       curve: Curves.easeInOut,
//     );

//     animation.addListener(() {
//       final lat =
//           from.latitude + (to.latitude - from.latitude) * animation.value;
//       final lng =
//           from.longitude + (to.longitude - from.longitude) * animation.value;

//       setState(() {
//         if (!mounted) return;

//         userMarker = userMarker!.copyWith(positionParam: LatLng(lat, lng));
//       });
//     });

//     animationController!.forward().whenComplete(animationController!.dispose);
//   }

//   bool loading = false;
//   // getCurrentLocation() async {
//   //   setState(() => loading = true);
//   //   position = await currentPosition();
//   //   final GoogleMapController controller = await _controller.future;
//   //   //user marker
//   //   await createUserMarker();
//   //   markers.add(userMarker!);

//   //   animateUserMarker(LatLng(position!.latitude, position!.longitude));
//   //   // move cammera to position
//   //   await controller.animateCamera(
//   //     CameraUpdate.newCameraPosition(
//   //       CameraPosition(
//   //         target: LatLng(position!.latitude, position!.longitude),
//   //         zoom: zoomLevel,
//   //       ),
//   //     ),
//   //   );
//   //   // generate fake data
//   //   // mainData = await generateData(position!);
//   //   // await displayMarkers(mainData);
//   //   setState(() => loading = false);
//   // }

//   getCurrentLocation(BitmapDescriptor marker) async {
//     setState(() => loading = true);

//     position = await currentPosition();

//     final mapController = await _controller.future;

//     if (userMarker == null) {
//       await createUserMarker(marker);
//     }

//     animateUserMarker(LatLng(position!.latitude, position!.longitude));

//     await Future.delayed(const Duration(milliseconds: 300));

//     await mapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: LatLng(position!.latitude, position!.longitude),
//           zoom: zoomLevel,
//         ),
//       ),
//     );

//     setState(() => loading = false);
//   }

//   ////////////////////////////////
//   ///////////////////////////////////
//   LatLng myLocation = LatLng(0, 0);

//   Set<Marker> markers = {};
//   double zoomLevel = 12.474;

//   Future<void> displayMarkers(List<DataModel> data) async {
//     final Set<Marker> newMarkers = {};

//     for (var item in data) {
//       var colorData = getColor(item.category);
//       final icon = await widgetToMarker(
//         context,
//         CustomMarkerContainer(
//           child: customChild(
//             item.name,
//             colorData['icon'],
//             colorData['textColor'],
//           ),
//           color: colorData['bgColor'],

//           // color: getColor(item.category),
//         ),
//       );

//       newMarkers.add(
//         Marker(
//           markerId: MarkerId(item.id),
//           position: LatLng(item.latt, item.long),
//           icon: icon,
//           onTap: () => _onMarkerTapped(item),
//         ),
//       );
//     }

//     setState(() {
//       markers.addAll(newMarkers);
//     });
//   }

//   CustomInfoWindowController customInfoWindowController =
//       CustomInfoWindowController();

//   handleSearch(String search) async {
//     setState(() => loading = true);
//     List<DataModel> filtered = mainData
//         .where(
//           (item) => item.category.toLowerCase().contains(search.toLowerCase()),
//         )
//         .toList();
//     log(filtered.length.toString());
//     Marker initMarker = markers.first;
//     markers.clear();
//     markers.add(initMarker);
//     await displayMarkers(filtered);
//     focusCamera(position!, zoomLevel, _controller);
//     setState(() => loading = false);
//   }

//   restoreData() async {
//     setState(() => loading = true);
//     Marker initMarker = markers.first;
//     markers.clear();
//     markers.add(initMarker);
//     await displayMarkers(mainData);
//     focusCamera(position!, zoomLevel, _controller);
//     setState(() => loading = false);
//   }

//   TextEditingController search = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             zoomControlsEnabled: true,
//             mapType: MapType.normal,
//             mapToolbarEnabled: false,
//             initialCameraPosition: CameraPosition(
//               target: myLocation,
//               zoom: zoomLevel,
//             ),
//             onMapCreated: (GoogleMapController controller) {
//               customInfoWindowController.googleMapController = controller;
//               _controller.complete(controller);
//             },
//             markers: markers,
//           ),
//           Visibility(
//             visible: loading,
//             child: Center(child: CircularProgressIndicator()),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//             ),
//             margin: EdgeInsets.only(top: 40, left: 20, right: 20),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     child: TextField(
//                       autofocus: false,
//                       // canRequestFocus: false,
//                       onChanged: (value) async {
//                         if (value == "") {
//                           await Future.delayed(const Duration(seconds: 3)).then(
//                             ((e) {
//                               if (value == "") restoreData();
//                             }),
//                           );
//                         }
//                       },
//                       controller: search,
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hint: Text(
//                           "Search e.g Hospital",
//                           style: TextStyle(color: Colors.blueGrey),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => handleSearch(search.text),
//                   icon: Icon(Icons.search_outlined),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onMarkerTapped(DataModel item) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return MarkerDetailSheet(item: item);
//       },
//     );
//   }
// }
