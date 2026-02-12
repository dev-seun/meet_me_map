import 'dart:async';
import 'dart:developer';

import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:meet_me/screens/Map/common/bottom_sheet.dart';
import 'common/marker_container.dart';
import 'common/marker_creator.dart';
import 'functions.dart';
import 'location_permission.dart';
import 'model.dart';

class NewMapHome extends StatefulWidget {
  const NewMapHome({super.key});

  @override
  State<NewMapHome> createState() => NewMapHomeState();
}

class NewMapHomeState extends State<NewMapHome> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();

  final TextEditingController search = TextEditingController();

  AnimationController? _animationController;

  Circle? _userBeacon;
  AnimationController? _beaconController;

  Position? position;
  late List<DataModel> mainData;

  bool loading = false;

  final Set<Marker> markers = {};
  Marker? userMarker;

  final double zoomLevel = 14;
  final LatLng _initialLocation = const LatLng(0, 0);

  // ------------------------------------------------------------
  // START BEACON
  // ------------------------------------------------------------

  void _startBeacon(LatLng center) {
    _beaconController?.dispose();

    // _beaconController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 2),
    // )..repeat();

    // _beaconController!.addListener(() {
    //   if (!mounted) return;

    //   // final progress = _beaconController!.value;

    //   setState(() {
    _userBeacon = Circle(
      circleId: const CircleId('user_beacon'),
      center: center,
      radius: 100, //20 + (progress * 80), // meters
      fillColor: Colors.pink.shade200.withAlpha(100),
      strokeColor: Colors.pink,
      // fillColor: Colors.blue.withOpacity(0.25 * (1 - progress)),
      // strokeColor: Colors.blue.withOpacity(0.4 * (1 - progress)),
      strokeWidth: 1,
    );
    // });
    // });
  }

  // ------------------------------------------------------------
  // LIFECYCLE
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final markerIcon = await loadIcons();
    await getCurrentLocation(markerIcon);
    Future.delayed(const Duration(seconds: 10)).then((_) {
      log('animating the icon');
      _animateUserMarker(LatLng(position!.latitude, position!.longitude));
      // final data = generateData(position!);
      // displayMarkers(data);
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    search.dispose();
    customInfoWindowController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // USER LOCATION & MARKER
  // ------------------------------------------------------------
  LatLng? _lastUserPosition;

  Future<void> getCurrentLocation(BitmapDescriptor markerIcon) async {
    if (!mounted) return;

    setState(() => loading = true);

    position = await currentPosition();
    final mapController = await _controller.future;

    if (userMarker == null) {
      _createUserMarker();
    } else {
      _animateUserMarker(LatLng(position!.latitude, position!.longitude));
    }

    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position!.latitude, position!.longitude),
          zoom: zoomLevel,
        ),
      ),
    );

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Widget userDirectionMarker() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Direction wedge
          Positioned(
            top: 3,
            child: Triangle.isosceles(
              edge: Edge.TOP,
              child: Container(width: 8, height: 8, color: Colors.pink),
            ),
          ),

          // User disk
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  double heading = 0;

  Future<void> _createUserMarker() async {
    final pos = LatLng(position!.latitude, position!.longitude);

    heading = position!.heading.isNaN ? 0 : position!.heading;

    final icon = await widgetToMarker(context, userDirectionMarker());

    userMarker = Marker(
      markerId: const MarkerId('user'),
      position: pos,
      icon: icon,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      rotation: heading,
    );

    markers
      ..removeWhere((m) => m.markerId.value == 'user')
      ..add(userMarker!);
    markers.add(userMarker!);
    _startBeacon(pos);
    setState(() {});
  }

  // Future<void> _createUserMarker(BitmapDescriptor icon) async {
  //   final pos = LatLng(position!.latitude, position!.longitude);

  //   _lastUserPosition = pos;

  //   userMarker = Marker(
  //     markerId: const MarkerId("user"),
  //     position: pos,
  //     flat: true,
  //     rotation: position!.heading,
  //     anchor: const Offset(0.5, 0.5),
  //     icon: await widgetToMarker(
  //       context,
  //       Column(
  //         children: [
  //           SizedBox(height: 9),
  //           Triangle.isosceles(
  //             edge: Edge.TOP,
  //             child: Container(color: Colors.pink, width: 7.0, height: 7.0),
  //           ),
  //           SizedBox(height: 3),
  //           Container(
  //             width: 10,
  //             height: 10,
  //             decoration: BoxDecoration(
  //               color: Colors.pink,
  //               borderRadius: BorderRadius.circular(1000),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  //   markers.add(userMarker!);
  //   _startBeacon(pos);
  //   setState(() {});
  // }

  void _animateUserMarker(LatLng to) {
    if (userMarker == null || _lastUserPosition == null) return;
    log('starting to show animation');

    final from = _lastUserPosition!;

    _lastUserPosition = to;

    _animationController?.dispose();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _userBeacon = _userBeacon?.copyWith(
      centerParam: LatLng(from.latitude, from.longitude),
    );

    final animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );

    animation.addListener(() {
      if (!mounted) return;

      final lat =
          from.latitude + (to.latitude - from.latitude) * animation.value;
      final lng =
          from.longitude + (to.longitude - from.longitude) * animation.value;

      final updatedMarker = userMarker!.copyWith(
        positionParam: LatLng(lat, lng),
      );

      setState(() {
        userMarker = updatedMarker;
        markers
          ..removeWhere((m) => m.markerId.value == "user")
          ..add(updatedMarker);
      });
    });

    _animationController!.forward();
  }

  // ------------------------------------------------------------
  // DATA MARKERS
  // ------------------------------------------------------------

  Future<void> displayMarkers(List<DataModel> data) async {
    final Set<Marker> newMarkers = {};

    for (final item in data) {
      final colorData = getColor(item.category);

      final icon = await widgetToMarker(
        context,
        CustomMarkerContainer(
          child: customChild(
            item.name,
            colorData['icon'],
            colorData['textColor'],
          ),
          color: colorData['bgColor'],
        ),
      );

      newMarkers.add(
        Marker(
          markerId: MarkerId(item.id),
          position: LatLng(item.latt, item.long),
          icon: icon,
          onTap: () => _onMarkerTapped(item),
        ),
      );
    }

    setState(() {
      markers.addAll(newMarkers);
    });
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  Future<void> handleSearch(String value) async {
    if (value.isEmpty) return;

    setState(() => loading = true);

    final filtered = mainData
        .where(
          (item) => item.category.toLowerCase().contains(value.toLowerCase()),
        )
        .toList();

    log('Filtered: ${filtered.length}');

    markers.removeWhere((m) => m.markerId.value != "user");

    await displayMarkers(filtered);

    if (position != null) {
      focusCamera(position!, zoomLevel, _controller);
    }

    setState(() => loading = false);
  }

  Future<void> restoreData() async {
    setState(() => loading = true);

    markers.removeWhere((m) => m.markerId.value != "user");

    await displayMarkers(mainData);

    if (position != null) {
      focusCamera(position!, zoomLevel, _controller);
    }

    setState(() => loading = false);
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialLocation,
              zoom: zoomLevel,
            ),
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              customInfoWindowController.googleMapController = controller;
              _controller.complete(controller);
            },
            markers: markers,
            circles: _userBeacon != null ? {_userBeacon!} : {},
          ),

          if (loading) const Center(child: CircularProgressIndicator()),

          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: search,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search e.g Hospital",
              ),
              onChanged: (value) async {
                if (value.isEmpty) {
                  await Future.delayed(const Duration(seconds: 2));
                  if (search.text.isEmpty) {
                    restoreData();
                  }
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => handleSearch(search.text),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MARKER TAP
  // ------------------------------------------------------------

  void _onMarkerTapped(DataModel item) {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (_) => MarkerDetailSheet(item: item),
    // );
  }
}
