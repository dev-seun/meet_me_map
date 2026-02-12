import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meet_me/constant.dart';
import 'package:meet_me/map_style/map_style.dart';
import 'package:meet_me/screens/Map/data_generator.dart';
import 'package:meet_me/screens/profile/profile.dart';
import 'controller.dart';

class MapWithPolyline extends StatefulWidget {
  const MapWithPolyline({super.key});

  @override
  State<MapWithPolyline> createState() => _MapWithPolylineState();
}

class _MapWithPolylineState extends State<MapWithPolyline>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(
      init: MapController(),
      initState: (_) {},
      builder: (ctx) {
        ctx.vsync ??= this;
        ctx.context ??= context;
        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () => ctx.loadingMarkers || ctx.searching
                    ? null
                    : ctx.clearData(),
                backgroundColor: Colors.red,
                child: ctx.loadingMarkers
                    ? CircularProgressIndicator()
                    : Icon(Icons.delete_sweep_sharp, color: Colors.white),
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () => ctx.loadingMarkers || ctx.searching
                    ? null
                    : ctx.generateMoreMarkers(),
                backgroundColor: ctx.isDark ? Colors.white : Colors.black,
                child: ctx.loadingMarkers
                    ? CircularProgressIndicator()
                    : Icon(
                        Icons.location_city_rounded,
                        color: ctx.isDark ? Colors.black : Colors.white,
                      ),
              ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: ctx.initialLocation,
                  zoom: ctx.zoomLevel,
                ),
                onMapCreated: (controller) {
                  ctx.controller.complete(controller);
                  ctx.mapController = controller;
                },
                minMaxZoomPreference: MinMaxZoomPreference(13, 19),
                onCameraMove: ctx.onCameraMove,
                onCameraIdle: ctx.onCameraIdle,
                markers: ctx.markers,
                trafficEnabled: true,
                mapToolbarEnabled: false,
                mapType: MapType.normal,
                rotateGesturesEnabled: true,
                circles: ctx.userBeacon != null ? {ctx.userBeacon!} : {},
                polylines: ctx.polylines,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
              ),

              _buildSearchBar(),

              Positioned(
                top: 100,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ctx.isRotated
                        ? IconButton(
                            icon: const Icon(Icons.location_searching_sharp),
                            onPressed: ctx.recenterCamera,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (state) =>
                                    ctx.isDark ? Colors.white : Colors.black12,
                              ),
                            ),
                          )
                        : SizedBox(height: 48),

                    IconButton(
                      onPressed: ctx.loadingMarkers
                          ? null
                          : ctx.toggleShowMarker,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (state) => ctx.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      icon: Icon(
                        ctx.showMarker
                            ? Icons.location_off_rounded
                            : Icons.location_on,
                        color: ctx.isDark ? Colors.black : Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: ctx.showOtherIcon,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (state) => ctx.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      icon: Icon(
                        ctx.isDark ? Icons.nights_stay : Icons.stream_rounded,
                        color: ctx.isDark ? Colors.black : Colors.white,
                      ),
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: ctx.visible ? 1.0 : 0.0,
                        child: ctx.visible
                            ? _toggleThemeDropdown()
                            : const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 100,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() => ProfileScreen()),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(Const.image),
                      ),
                    ),
                    ctx.hasObtainedDirection
                        ? IconButton(
                            icon: const Icon(Icons.restore_outlined),
                            onPressed: ctx.gotoMarkedPolylines,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (state) =>
                                    ctx.isDark ? Colors.white : Colors.black12,
                              ),
                            ),
                          )
                        : SizedBox(height: 48),
                    ctx.hasObtainedDirection
                        ? IconButton(
                            icon: const Icon(Icons.reset_tv_rounded),
                            onPressed: ctx.resetMapToInitailState,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (state) =>
                                    ctx.isDark ? Colors.white : Colors.black12,
                              ),
                            ),
                          )
                        : SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  FocusNode searchNode = FocusNode();
  Widget _buildSearchBar() {
    return GetBuilder<MapController>(
      initState: (_) {},
      builder: (ctx) {
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
                  controller: ctx.searchController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search e.g Hospital",
                  ),
                  autofocus: false,
                  focusNode: searchNode,
                  autofillHints: categories,
                  enableSuggestions: true,
                  onTapOutside: (event) => searchNode.canRequestFocus = false,
                  onTap: () {
                    searchNode.canRequestFocus = true;
                    searchNode.requestFocus();
                  },
                  onChanged: (value) async {
                    if (value.isEmpty) {
                      await Future.delayed(const Duration(seconds: 2));
                      if (ctx.searchController.text.isEmpty) {
                        ctx.restoreData();
                      }
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search_outlined),
                onPressed: ctx.handleSearch,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _toggleThemeDropdown() {
    return GetBuilder<MapController>(
      initState: (_) {},
      builder: (ctx) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: ctx.visible ? 1.0 : 0.0,
            child: ctx.visible
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      MapStyleName.values.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () => ctx.setTheme(index),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: ctx.isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      ctx.getName(
                                        MapStyleName.values[index].name,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ctx.isDark
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    [
                                      Icon(
                                        Icons.night_shelter,
                                        size: 18,
                                        color: ctx.isDark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      Icon(
                                        Icons.nightlight_round,
                                        size: 16,
                                        color: ctx.isDark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      Icon(
                                        Icons.light_mode,
                                        size: 18,
                                        color: ctx.isDark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      Icon(
                                        Icons.light,
                                        size: 18,
                                        color: ctx.isDark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ][index],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        );
      },
    );
  }
}
