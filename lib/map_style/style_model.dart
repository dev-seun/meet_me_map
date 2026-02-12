// import 'dart:convert';

// import 'package:meet_me/map_style/map_style.dart';

// /// Root container for all styles (dark, night, silver, etc.)
// // class MapStyles {
// //   final Map<String, List<MapStyleRule>> styles;

// //   MapStyles({required this.styles});

// //   factory MapStyles.fromJson(Map<String, dynamic> json) {
// //     return MapStyles(
// //       styles: json.map((key, value) {
// //         final rules = (value as List)
// //             .map((e) => MapStyleRule.fromJson(e))
// //             .toList();
// //         return MapEntry(key, rules);
// //       }),
// //     );
// //   }

// //   /// Convert a specific style to JSON string for GoogleMapController
// //   String toStyleJson(String styleName) {
// //     final rules = styles[styleName];
// //     if (rules == null) return '[]';

// //     return jsonEncode(rules.map((e) => e.toJson()).toList());
// //   }

// //   /// Turn ALL features off for a given style
// //   String withAllHidden(String styleName) {
// //     final rules = styles[styleName];
// //     if (rules == null) return '[]';

// //     final hiddenRules = rules.map((rule) {
// //       return rule.copyWithVisibilityOff();
// //     }).toList();

// //     return jsonEncode(hiddenRules.map((e) => e.toJson()).toList());
// //   }
// // }

// /// One style rule
// class MapStyleRule {
//   final String? featureType;
//   final String? elementType;
//   final List<Styler> stylers;

//   MapStyleRule({this.featureType, this.elementType, required this.stylers});

//   factory MapStyleRule.fromJson(Map<String, dynamic> json) {
//     return MapStyleRule(
//       featureType: json['featureType'],
//       elementType: json['elementType'],
//       stylers: (json['stylers'] as List)
//           .map((e) => Styler.fromJson(e))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{
//       'stylers': stylers.map((e) => e.toJson()).toList(),
//     };

//     if (featureType != null) data['featureType'] = featureType;
//     if (elementType != null) data['elementType'] = elementType;

//     return data;
//   }

//   /// Force visibility off (useful for toggles)
//   MapStyleRule copyWithVisibilityOff() {
//     return MapStyleRule(
//       featureType: featureType,
//       elementType: elementType,
//       stylers: [
//         ...stylers.where((s) => !s.isVisibility),
//         Styler.visibilityOff(),
//       ],
//     );
//   }
// }

// /// Individual styler
// class Styler {
//   final String key;
//   final dynamic value;

//   Styler({required this.key, required this.value});

//   factory Styler.fromJson(Map<String, dynamic> json) {
//     final entry = json.entries.first;
//     return Styler(key: entry.key, value: entry.value);
//   }

//   Map<String, dynamic> toJson() => {key: value};

//   bool get isVisibility => key == 'visibility';

//   factory Styler.visibilityOff() => Styler(key: 'visibility', value: 'off');
// }

// class MapStyleManager {
//   final Map<String, List<MapStyleRule>> _styles;

//   MapStyleManager(this._styles);

//   /// Load from decoded JSON
//   factory MapStyleManager.fromJson(Map<String, dynamic> json) {
//     final styles = <String, List<MapStyleRule>>{};

//     json.forEach((styleName, rules) {
//       styles[styleName] = (rules as List)
//           .map((e) => MapStyleRule.fromJson(e))
//           .toList();
//     });

//     return MapStyleManager(styles);
//   }

//   /// 🔑 This is the method you want
//   /// Load style by name
//   String loadStyle({MapStyleName? styleName}) {
//     final rules = _styles[styleName?.name ?? MapStyleName.light.name];
//     if (rules == null) {
//       return '[]'; // safe fallback
//     }

//     return jsonEncode(rules.map((e) => e.toJson()).toList());
//   }

//   /// Optional: list all available styles
//   List<String> get availableStyles => _styles.keys.toList();
// }
