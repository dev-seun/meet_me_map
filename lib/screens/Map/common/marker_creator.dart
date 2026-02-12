import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> widgetToMarke22r(
  BuildContext context,
  Widget widget, {
  Size size = const Size(80, 50),
  double pixelRatio = 3,
}) async {
  final boundaryKey = GlobalKey();

  final overlay = Overlay.of(context);
  // if (overlay == null) {
  //   throw Exception('Overlay not found in context');
  // }

  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -1000,
      top: -1000,
      child: RepaintBoundary(
        key: boundaryKey,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Material(color: Colors.transparent, child: widget),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  // ✅ Wait until the boundary exists and has a size
  RenderRepaintBoundary? boundary;
  for (int i = 0; i < 10; i++) {
    await Future.delayed(const Duration(milliseconds: 16)); // one frame
    final context = boundaryKey.currentContext;
    if (context != null) {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderRepaintBoundary &&
          !renderObject.debugNeedsPaint) {
        boundary = renderObject;
        break;
      }
    }
  }

  if (boundary == null) {
    entry.remove();
    throw Exception('Failed to capture marker widget');
  }

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final bytes = await image.toByteData(format: ImageByteFormat.png);

  entry.remove();

  return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
}

Future<BitmapDescriptor> widgetToMarker(
  BuildContext context,
  Widget widget, {
  Size size = const Size(100, 50),
  double pixelRatio = 3,
}) async {
  final boundaryKey = GlobalKey();

  final overlay = Overlay.of(context);

  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -1000, // push offscreen
      top: -1000,
      child: RepaintBoundary(
        key: boundaryKey,
        child: MarkerCapture(size: size, child: widget),
      ),
    ),
  );

  overlay.insert(entry);

  await Future.delayed(const Duration(milliseconds: 30));

  RenderRepaintBoundary? boundary;
  for (int i = 0; i < 10; i++) {
    await Future.delayed(const Duration(milliseconds: 16)); // one frame
    final context = boundaryKey.currentContext;
    if (context != null) {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderRepaintBoundary &&
          !renderObject.debugNeedsPaint) {
        boundary = renderObject;
        break;
      }
    }
  }

  // final boundary =
  //     boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

  if (boundary == null) {
    entry.remove();
    throw Exception('Failed to capture marker widget');
  }

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final bytes = await image.toByteData(format: ImageByteFormat.png);

  entry.remove();

  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}

class MarkerCapture extends StatelessWidget {
  const MarkerCapture({
    super.key,
    required this.child,
    this.size = const Size(80, 50),
  });

  final Widget child;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Material(color: Colors.transparent, child: child),
    );
  }
}
