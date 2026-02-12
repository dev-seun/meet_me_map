import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'common/marker_creator.dart';
import 'location_permission.dart';

class HomeMap1 extends StatefulWidget {
  const HomeMap1({super.key});

  @override
  State<HomeMap1> createState() => _HomeMap1State();
}

class _HomeMap1State extends State<HomeMap1> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> markers = {};
  Marker? userMarker;

  Position? position;
  LatLng? _lastUserPosition;

  StreamSubscription<Position>? _positionSub;
  AnimationController? _moveController;

  Circle? _userBeacon;

  final double zoomLevel = 16;
  final LatLng _initialLocation = const LatLng(0, 0);

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _startTrackingUser();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _moveController?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // USER TRACKING
  // ------------------------------------------------------------

  Future<void> _startTrackingUser() async {
    await requestLocationPermission();

    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 1,
          ),
        ).listen((pos) async {
          position = pos;
          final LatLng latLng = LatLng(pos.latitude, pos.longitude);

          if (userMarker == null) {
            _lastUserPosition = latLng;
            await _createUserMarker(pos);

            final controller = await _controller.future;
            controller.animateCamera(
              CameraUpdate.newLatLngZoom(latLng, zoomLevel),
            );
          } else {
            _animateUserMarker(latLng, pos.heading);
          }
        });
  }

  // ------------------------------------------------------------
  // USER MARKER UI
  // ------------------------------------------------------------

  Widget _userDirectionMarker() {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            child: Triangle.isosceles(
              edge: Edge.TOP,
              child: Container(width: 8, height: 8, color: Colors.pink),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CREATE MARKER
  // ------------------------------------------------------------

  Future<void> _createUserMarker(Position pos) async {
    final LatLng latLng = LatLng(pos.latitude, pos.longitude);

    _lastUserPosition = latLng;

    final icon = await widgetToMarker(context, _userDirectionMarker());

    userMarker = Marker(
      markerId: const MarkerId('user'),
      position: latLng,
      icon: icon,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      rotation: pos.heading.isNaN ? 0 : pos.heading,
    );

    markers
      ..removeWhere((m) => m.markerId.value == 'user')
      ..add(userMarker!);

    _updateBeacon(latLng);

    setState(() {});
  }

  // ------------------------------------------------------------
  // ANIMATE MOVEMENT + HEADING
  // ------------------------------------------------------------

  void _animateUserMarker(LatLng to, double newHeading) {
    if (_lastUserPosition == null || userMarker == null) return;

    final from = _lastUserPosition!;
    _lastUserPosition = to;

    _moveController?.dispose();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final animation = CurvedAnimation(
      parent: _moveController!,
      curve: Curves.easeOut,
    );

    animation.addListener(() {
      if (!mounted) return;

      final lat =
          from.latitude + (to.latitude - from.latitude) * animation.value;
      final lng =
          from.longitude + (to.longitude - from.longitude) * animation.value;

      final heading = newHeading.isNaN ? userMarker!.rotation : newHeading;

      userMarker = userMarker!.copyWith(
        positionParam: LatLng(lat, lng),
        rotationParam: heading,
      );

      markers
        ..removeWhere((m) => m.markerId.value == 'user')
        ..add(userMarker!);

      _updateBeacon(LatLng(lat, lng));

      setState(() {});
    });

    _moveController!.forward();
  }

  // ------------------------------------------------------------
  // BEACON
  // ------------------------------------------------------------

  void _updateBeacon(LatLng center) {
    _userBeacon = Circle(
      circleId: const CircleId('user_beacon'),
      center: center,
      radius: 60,
      fillColor: Colors.pink.withOpacity(0.25),
      strokeColor: Colors.pink,
      strokeWidth: 1,
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: zoomLevel,
        ),
        onMapCreated: (controller) => _controller.complete(controller),
        markers: markers,
        circles: _userBeacon != null ? {_userBeacon!} : {},
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
