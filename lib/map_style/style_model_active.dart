import 'dart:convert';

import 'package:meet_me/map_style/map_style.dart';

class MapStyleModel {
  dynamic nightFullView;
  dynamic night;
  dynamic lightFullView;
  dynamic light;

  MapStyleModel({
    this.nightFullView,
    this.night,
    this.lightFullView,
    this.light,
  });

  factory MapStyleModel.fromJson(Map<String, dynamic> json) {
    final data = MapStyleModel(
      nightFullView: json['nightFullView'],
      night: json['night'],
      lightFullView: json['lightFullView'],
      light: json['light'],
    );

    // log(data.ambient.toString());
    return data;
  }

  String loadStyle(MapStyleName styleName) {
    List<dynamic>? style;
    final name = styleName.name;
    switch (name) {
      case 'nightFullView':
        style = nightFullView;
        break;
      case 'night':
        style = night;
        break;
      case 'lightFullView':
        style = lightFullView;
        break;
      case 'light':
        style = light;
        break;
      default:
        style = null;
    }

    if (style == null) return '[]';

    return jsonEncode(style.map((e) => e).toList());
  }
}
