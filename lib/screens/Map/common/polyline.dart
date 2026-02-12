import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class MapWithRoute extends StatefulWidget {
  const MapWithRoute({super.key});

  @override
  State<MapWithRoute> createState() => _MapWithRouteState();
}

class _MapWithRouteState extends State<MapWithRoute> {
  final Completer<GoogleMapController> _controller = Completer();

  final PolylinePoints _polylinePoints = PolylinePoints(apiKey: googleApiKey);
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  Position? _position;

  static const String googleApiKey = 'AIzaSyCg5bsifLCYf7xhO6mePEnmrXCvNLtoFvw';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    _position = await Geolocator.getCurrentPosition();

    final userLatLng = LatLng(_position!.latitude, _position!.longitude);

    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Example destination marker
    final destination = LatLng(
      userLatLng.latitude + 0.01,
      userLatLng.longitude + 0.01,
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        onTap: () => _drawRoute(destination),
      ),
    );

    setState(() {});
  }

  Future<void> _drawRoute(LatLng destination) async {
    if (_position == null) return;

    final result = await _polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(_position!.latitude, _position!.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
      // googleApiKey: googleApiKey,
    );

    if (result.points.isEmpty) return;

    final routePoints = result.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: routePoints,
      width: 5,
      color: Colors.blue,
    );

    setState(() {
      _polylines
        ..clear()
        ..add(polyline);
    });

    _fitRoute(routePoints);
  }

  Future<void> _fitRoute(List<LatLng> points) async {
    final controller = await _controller.future;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}
