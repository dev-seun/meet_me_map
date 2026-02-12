import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meet_me/constant.dart';
import 'package:meet_me/screens/Map/data_generator.dart';
import 'location_permission.dart';

generateData(Position position) {
  return generateMockData(
      count: 10,
      bLat: position.latitude,
      bLng: position.longitude,
      proximity: 0.001,
    )
    // Medium (~150m)
    ..addAll(
      generateMockData(
        count: 10,
        bLat: position.latitude,
        bLng: position.longitude,
        proximity: 0.0015,
      ),
    )
    // Medium (~250m)
    ..addAll(
      generateMockData(
        count: 10,
        bLat: position.latitude,
        bLng: position.longitude,
        proximity: 0.0025,
      ),
    )
    // Very scattered (~450km)
    ..addAll(
      generateMockData(
        count: 20,
        bLat: position.latitude,
        bLng: position.longitude,
        proximity: 0.0045,
      ),
    )
    // Very scattered (~700km)
    ..addAll(
      generateMockData(
        count: 20,
        bLat: position.latitude,
        bLng: position.longitude,
        proximity: 0.070,
      ),
    )
    // Very scattered (~850km)
    ..addAll(
      generateMockData(
        count: 20,
        bLat: position.latitude,
        bLng: position.longitude,
        proximity: 0.01,
      ),
    )
    // Very scattered (~1km)
    ..addAll(
      generateMockData(
        count: 20,
        bLat: position.latitude,
        bLng: position.longitude,
        proximity: 0.020,
      ),
    )
    // Very scattered (~4km)
    ..addAll(
      generateMockData(
        count: 20,
        bLat: position.latitude,
        bLng: position.longitude,
        proximity: 0.040,
      ),
    );
}

focusCamera(
  Position position,
  double zoomLevel,
  Completer<GoogleMapController> controller,
) async {
  position = await currentPosition();
  final GoogleMapController googleController = await controller.future;
  await googleController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: zoomLevel,
      ),
    ),
  );
}

getColor(String cat) {
  switch (cat) {
    case 'Restaurant':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.amber,
        'icon': Icons.restaurant_menu_rounded,
      };
    case 'Cafe':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.orange,
        'icon': Icons.local_cafe,
      };
    case 'Pharmacy':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.green,
        'icon': Icons.local_pharmacy_rounded,
      };
    case 'Supermarket':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.purple,
        'icon': Icons.shopping_cart,
      };
    case 'Bakery':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.pink,
        'icon': Icons.bakery_dining,
      };
    case 'Fast Food':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.black,
        'icon': Icons.food_bank_outlined,
      };
    case 'Bar':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.blue,
        'icon': Icons.local_drink_outlined,
      };
    case 'Hospital':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.brown,
        'icon': Icons.local_hospital,
      };
    case 'School':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.grey,
        'icon': Icons.school,
      };
    case 'Fuel Station':
      return {
        "textColor": Colors.white,
        'bgColor': Colors.red,
        'icon': Icons.local_gas_station_rounded,
      };
    default:
      return {
        "textColor": Colors.white,
        'bgColor': Colors.amber,
        'icon': Icons.ac_unit_rounded,
      };
  }
}

customChild(String name, IconData icon, Color textColor) => Padding(
  padding: const EdgeInsets.all(4.0),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: textColor, size: 18),
      SizedBox(width: 4),
      Flexible(
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: textColor,
          ),
        ),
      ),
    ],
  ),
);

BitmapDescriptor? userIcon;

Future<BitmapDescriptor> loadIcons() async {
  return await BitmapDescriptor.asset(
    const ImageConfiguration(size: Size(15, 15)),
    'assets/images/disk.png',
  );
}

double _degToRad(double degrees) {
  return degrees * (pi / 180);
}

double distanceInMeters(LatLng a, LatLng b) {
  const earthRadius = 6371000; // meters

  final dLat = _degToRad(b.latitude - a.latitude);
  final dLng = _degToRad(b.longitude - a.longitude);

  final lat1 = _degToRad(a.latitude);
  final lat2 = _degToRad(b.latitude);

  final h =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

  final res = 2 * earthRadius * asin(sqrt(h));
  // log('$res ------ calculation');
  return res;
}

// ------------------------------------------------------------
// POLYLINE (Real Route)
// ------------------------------------------------------------

Future<Set<Polyline>> drawRoutePolyline(
  PointLatLng start,
  PointLatLng end, {
  TravelMode mode = TravelMode.driving,
}) async {
  dev.log('start: $start end: $end');
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Const.googleKey);
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    // ignore: deprecated_member_use
    request: PolylineRequest(
      origin: start,
      destination: PointLatLng(end.latitude, end.longitude),
      mode: mode,
    ),
  );
  dev.log('Result Data: $result - result ');
  dev.log('Points returned: ${result.points.length}');

  if (result.points.isEmpty) return {};

  List<LatLng> polylineCoords = result.points
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList();
  return {
    Polyline(
      polylineId: const PolylineId('route'),
      points: polylineCoords,
      color: Colors.blue,
      width: 5,
    ),
  };
}
