import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meet_me/constant.dart';

import '../model.dart';

class MarkerDetailSheet extends StatelessWidget {
  const MarkerDetailSheet({
    super.key,
    required this.item,
    required this.onDirection,
    required this.startPoint,
    required this.endPoint,
    required this.distance,
  });

  final DataModel item;
  final LatLng startPoint;
  final double distance;
  final LatLng endPoint;
  final Function() onDirection;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      height: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Header row with image + title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: const NetworkImage(Const.image),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.price,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "${distance.toPrecision(2)} m",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  "Away",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 5),
                            SizedBox(
                              child: IconButton.filled(
                                onPressed: onDirection,
                                icon: Icon(Icons.directions),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  item.desc,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 16),

                // Extras
                Text(
                  'Services',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: item.others
                      .map(
                        (e) => Chip(
                          label: Text(e),
                          backgroundColor: Colors.blue.shade50,
                          labelStyle: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //   return DraggableScrollableSheet(
  //     snapSizes: [0.05, .5, .85],
  //     initialChildSize: 0.05,
  //     minChildSize: 0.05,
  //     maxChildSize: 0.85,
  //     builder: (_, controller) {
  //       return Container(
  //         height: 100,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //         ),
  //         padding: const EdgeInsets.all(16),
  //         child: ListView(
  //           controller: controller,
  //           children: [
  //             Text(item.name, style: Theme.of(context).textTheme.titleLarge),
  //             const SizedBox(height: 8),
  //             Text(item.desc),
  //             const SizedBox(height: 12),
  //             Text('Price from: ${item.price}'),
  //             const SizedBox(height: 12),
  //             Wrap(
  //               spacing: 8,
  //               children: item.others.map((e) => Chip(label: Text(e))).toList(),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
