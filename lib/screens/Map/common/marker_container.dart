import 'package:clippy_flutter/triangle.dart';
import 'package:flutter/material.dart';

class CustomMarkerContainer extends StatelessWidget {
  const CustomMarkerContainer({
    super.key,
    this.width,
    this.height,
    this.color,
    this.child,
  });

  final double? width;
  final double? height;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color ?? Colors.amber,
            borderRadius: BorderRadius.circular(4),
          ),
          width: width,
          child: child,
        ),

        Triangle.isosceles(
          edge: Edge.BOTTOM,
          child: Container(
            color: color ?? Colors.amber,
            width: 20.0,
            height: 10.0,
          ),
        ),
      ],
    );
  }
}
