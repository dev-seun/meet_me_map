import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:meet_me/map_style/style_model_active.dart';

enum MapStyleName { nightFullView, night, lightFullView, light }

Future<MapStyleModel> loadMapStyleManager() async {
  final raw = await rootBundle.loadString(
    'assets/jsons/map_style.json',
    cache: true,
  );
  final jsonMap = jsonDecode(raw);
  return MapStyleModel.fromJson(jsonMap);
}
