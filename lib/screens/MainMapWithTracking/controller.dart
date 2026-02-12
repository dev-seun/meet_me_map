import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:meet_me/map_style/style_model_active.dart';
import 'package:meet_me/screens/Map/common/bottom_sheet.dart';
import 'package:meet_me/screens/Map/common/marker_container.dart';
import 'package:meet_me/screens/Map/common/marker_creator.dart';
import 'package:meet_me/screens/Map/data_generator.dart';
import 'package:meet_me/screens/Map/functions.dart';
import 'package:meet_me/screens/Map/model.dart';
import '../Map/location_permission.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:meet_me/map_style/map_style.dart';

class MapController extends GetxController {
  bool visible = false;
  bool isDark = false;
  GoogleMapController? mapController;
  MapStyleModel? styleManager;
  final Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Circle? userBeacon;
  BuildContext? context;

  TextEditingController searchController = TextEditingController();

  dynamic vsync;

  List<DataModel> data = [];
  Marker? userMarker;
  Position? position;
  LatLng? lastUserPosition;

  StreamSubscription<Position>? positionSub;
  AnimationController? moveController;

  final Completer<GoogleMapController> controller = Completer();

  final double zoomLevel = 17;
  final LatLng initialLocation = const LatLng(0, 0);

  bool _shouldReset = false;
  bool _isInit = true;
  bool loadingMarkers = false;
  bool searching = false;
  bool showMarker = true;

  bool isRotated = false;
  bool hasObtainedDirection = false;
  LatLng _lastCameraTarget = const LatLng(0, 0);
  LatLng? lastFetchLocation;

  double directionZoom = 20, directionBearing = 0, directionTilt = 49;

  @override
  void onClose() {
    positionSub?.cancel();
    moveController?.dispose();
    super.dispose();
  }

  @override
  onReady() {
    loadMapStyleManager().then((manager) {
      styleManager = manager;
      log('manager initialized');
      // ignore: deprecated_member_use
      mapController?.setMapStyle(manager.loadStyle(MapStyleName.light));
    });
    _startTrackingUser().then((x) {});
    Future.delayed(const Duration(seconds: 3), () {
      _isInit = false;

      log('position ----- $position ----  ');
      // data = generateData(position!);
      data = generateMockData(
        count: 10,
        bLat: position!.latitude,
        bLng: position!.longitude,
        proximity: 0.0015,
      );
      // displayMarkers(data);
    });
  }

  _checkIsRotated() {
    final lat = position?.latitude.toPrecision ?? 0;
    final checkLat = _lastCameraTarget.latitude.toPrecision;
    final lon = position?.longitude.toPrecision ?? 0;
    final checkLon = _lastCameraTarget.longitude.toPrecision;
    // log('Comparing ---- $lat -- $checkLat &&& $lon -- $checkLon');
    return lat != checkLat || lon != checkLon;
  }

  onCameraMove(CameraPosition camPosition) {
    // log('${camPosition.tilt} ---- tilt ${camPosition.bearing} ---- bearing');
    lastFetchLocation ??= camPosition.target;
    _lastCameraTarget = camPosition.target;
    if (_isInit || isRotated) return;
    // log('${camPosition.target} ---- current positions');
    // log('runnning ---------  $isRotated');
    isRotated = _checkIsRotated();
    onCameraIdle();
    update();
  }

  onCameraIdle() {
    if (_shouldReset) {
      isRotated = false;
      _shouldReset = false;
      update();
    }
  }

  recenterCamera({
    double zoom = 17,
    double bearing = 0,
    double tilt = 0,
  }) async {
    // log('${_lastCameraTarget == position} --- check equal');
    if (mapController == null) return;

    log(position.toString());
    await mapController!
        .animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                position!.latitude,
                position!.longitude,
              ), // current center
              zoom: zoom,
              bearing: bearing,
              tilt: tilt,
            ),
          ),
        )
        .whenComplete(() {
          // log('completed ---------');
          _shouldReset = true;
        });
  }

  gotoMarkedPolylines() {
    hasObtainedDirection = true;
    recenterCamera(
      zoom: directionZoom,
      bearing: directionBearing,
      tilt: directionTilt,
    );
  }

  resetMapToInitailState() {
    hasObtainedDirection = false;
    polylines = {};
    recenterCamera();
  }

  // ------------------------------------------------------------
  // CREATE MARKER
  // ------------------------------------------------------------

  Future<void> _createUserMarker(Position pos) async {
    final LatLng latLng = LatLng(pos.latitude, pos.longitude);

    lastUserPosition = latLng;

    final icon = await widgetToMarker(
      context!,
      Icon(Icons.compass_calibration, color: Colors.pink),
    );
    // _userDirectionMarker());

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

    update();
  }

  // ------------------------------------------------------------
  // USER TRACKING
  // ------------------------------------------------------------

  Future<void> _startTrackingUser() async {
    await requestLocationPermission();

    positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 1,
          ),
        ).listen((pos) async {
          position = pos;
          final LatLng latLng = LatLng(pos.latitude, pos.longitude);

          if (userMarker == null) {
            lastUserPosition = latLng;
            await _createUserMarker(pos);

            final ctr = await controller.future;
            ctr.animateCamera(CameraUpdate.newLatLngZoom(latLng, zoomLevel));
          } else {
            _animateUserMarker(latLng, pos.heading, vsync);
          }
        });
  }

  // ------------------------------------------------------------
  // ANIMATE MOVEMENT + HEADING
  // ------------------------------------------------------------

  void _animateUserMarker(LatLng to, double newHeading, vsync) {
    if (lastUserPosition == null || userMarker == null) return;

    final from = lastUserPosition!;
    lastUserPosition = to;

    moveController?.dispose();

    moveController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 700),
    );

    final animation = CurvedAnimation(
      parent: moveController!,
      curve: Curves.easeOut,
    );

    animation.addListener(() {
      // if (!mounted) return;

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

      update();
    });

    moveController!.forward();
  }

  // ------------------------------------------------------------
  // BEACON
  // ------------------------------------------------------------

  void _updateBeacon(LatLng center) {
    userBeacon = Circle(
      circleId: const CircleId('user_beacon'),
      center: center,
      radius: 60,
      fillColor: Colors.pink.withOpacity(0.25),
      strokeColor: Colors.pink,
      strokeWidth: 1,
    );
  }

  getName(String name) {
    switch (name) {
      case "nightFullView":
        return "Night with City View";
      case "night":
        return "Night Only";
      case "lightFullView":
        return "Light with City View";
      case "light":
        return "Light Only";
      default:
    }
  }

  setTheme(int index) {
    mapController?.setMapStyle(
      styleManager?.loadStyle(MapStyleName.values[index]),
    );
    if (index == 0 || index == 1) {
      isDark = true;
    } else {
      isDark = false;
    }
    // optional: auto-close after selection
    visible = false;
    update();
  }

  showOtherIcon() {
    visible = !visible;
    update();
  }

  toggleShowMarker() {
    if (showMarker) {
      showMarker = false;
      markers.removeWhere((m) => m.markerId.value != "user");
      update();
    } else {
      showMarker = true;
      if (searchController.text.trim().isNotEmpty) {
        return handleSearch();
      }
      _displayMarkers(data);
    }
  }

  // Future<void> _displayMarkers(List<DataModel> data) async {
  //   loadingMarkers = true;
  //   update();
  //   final Set<Marker> newMarkers = {};
  //   for (final item in data) {
  //     final colorData = getColor(item.category);

  //     final icon = await widgetToMarker(
  //       context!,
  //       CustomMarkerContainer(
  //         child: customChild(
  //           item.name,
  //           colorData['icon'],
  //           colorData['textColor'],
  //         ),
  //         color: colorData['bgColor'],
  //       ),
  //     );

  //     newMarkers.add(
  //       Marker(
  //         markerId: MarkerId(item.id),
  //         position: LatLng(item.latt, item.long),
  //         icon: icon,
  //         onTap: () => _onMarkerTapped(item),
  //       ),
  //     );
  //   }

  //   markers.addAll(newMarkers);
  //   loadingMarkers = false;
  //   update();
  // }
  Future<void> _displayMarkers(
    List<DataModel> data, {
    int batchSize = 10,
  }) async {
    loadingMarkers = true;
    update();

    for (int i = 0; i < data.length; i += batchSize) {
      final batch = data.skip(i).take(batchSize);

      final Set<Marker> batchMarkers = {};

      for (final item in batch) {
        final colorData = getColor(item.category);

        final icon = await widgetToMarker(
          context!,
          CustomMarkerContainer(
            child: customChild(
              item.name,
              colorData['icon'],
              colorData['textColor'],
            ),
            color: colorData['bgColor'],
          ),
        );

        batchMarkers.add(
          Marker(
            markerId: MarkerId(item.id),
            position: LatLng(item.latt, item.long),
            icon: icon,
            onTap: () => _onMarkerTapped(item),
          ),
        );
      }

      markers.addAll(batchMarkers);
      update();

      // 👇 give the UI thread time to render
      await Future.delayed(const Duration(milliseconds: 16));
    }

    loadingMarkers = false;
    update();
  }

  Future<void> handleSearch() async {
    if (searchController.text.trim().isEmpty) return;

    searching = true;
    update();

    final filtered = data
        .where(
          (item) => item.category.toLowerCase().contains(
            searchController.text.trim().toLowerCase(),
          ),
        )
        .toList();

    log('Filtered: ${filtered.length}');

    markers.removeWhere((m) => m.markerId.value != "user");

    await _displayMarkers(filtered);

    if (position != null) {
      focusCamera(position!, zoomLevel, controller);
    }

    searching = false;
    update();
  }

  Future<void> restoreData() async {
    // remove all previouse marker
    markers.removeWhere((m) => m.markerId.value != "user");

    await _displayMarkers(data);

    if (position != null) {
      focusCamera(position!, zoomLevel, controller);
    }
  }

  void _onMarkerTapped(DataModel item) {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MarkerDetailSheet(
        item: item,
        distance: distanceInMeters(
          LatLng(position!.latitude, position!.longitude),
          LatLng(item.latt, item.long),
        ),
        startPoint: LatLng(position!.latitude, position!.longitude),
        endPoint: LatLng(item.latt, item.long),
        onDirection: () async {
          polylines = {
            Polyline(
              polylineId: const PolylineId('test'),
              points: [
                LatLng(position!.latitude, position!.longitude),
                LatLng(item.latt, item.long),
              ],
              color: Colors.pink,
              width: 2,
            ),
          };

          // polylines = await drawRoutePolyline(
          //   PointLatLng(position!.latitude, position!.longitude),
          //   PointLatLng(item.latt, item.long),
          // );
          gotoMarkedPolylines();
        },
      ),
    );
  }

  double fetchThresholdMeters = 200;
  void generateMoreMarkers() {
    if (lastFetchLocation == null) return;

    final distance = distanceInMeters(lastFetchLocation!, _lastCameraTarget);

    if (distance >= fetchThresholdMeters) {
      final newData = generateMockData(
        count: 10,
        bLat: _lastCameraTarget.latitude,
        bLng: _lastCameraTarget.longitude,
        proximity: 0.0015,
      );

      data.addAll(newData);
      _displayMarkers(newData);

      lastFetchLocation = _lastCameraTarget;
    }
  }

  clearData() {
    markers.removeWhere((m) => m.markerId.value != "user");
    data = [];
    update();
  }
}
