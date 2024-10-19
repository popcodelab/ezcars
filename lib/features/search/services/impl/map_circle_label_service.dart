import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../i_map_circle_label_service.dart';


import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../i_map_circle_label_service.dart';

class MapCircleLabelService implements IMapCircleLabelService {

  @override
  Future<Uint8List> createCustomMarker(String text, Size markerSize) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Custom marker settings
    const double iconSizeFactor = 0.5;
    const double textSizeFactor = 0.4;
    const double paddingFactor = 0.05;
    const double borderRadiusFactor = 0.2;

    // Set dimensions based on factors
    final double iconSize = markerSize.height * iconSizeFactor;
    final double textFontSize = markerSize.height * textSizeFactor;
    final double padding = markerSize.width * paddingFactor;

    // Draw a rounded rectangle background
    final paint = Paint()..color = Colors.white;
    final radius = Radius.circular(markerSize.height * borderRadiusFactor);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.0, 0.0, markerSize.width, markerSize.height),
      radius,
    );
    canvas.drawRRect(rect, paint);

    // Draw the walking icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.directions_walk.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: Icons.directions_walk.fontFamily,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    final double iconVerticalOffset = (markerSize.height - iconPainter.height) / 2;
    iconPainter.paint(canvas, Offset(padding, iconVerticalOffset));

    // Draw the text next to the icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: textFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: markerSize.width - (iconSize + 3 * padding),
    );
    final double textVerticalOffset = (markerSize.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(iconSize + 2 * padding, textVerticalOffset));

    // Convert the canvas into an image and get the bytes
    final picture = recorder.endRecording();
    final img = await picture.toImage(markerSize.width.toInt(), markerSize.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception("Failed to generate marker image.");
    }

    return byteData.buffer.asUint8List();
  }

  @override
  Future<Marker> relocateCustomMarker(LatLng currentLatLng, double walkingRadius, Uint8List markerIcon) async {
    // Calculate the new latitude by adding the walking radius as an offset
    double newLatitude = currentLatLng.latitude + (walkingRadius / 111000.0);

    // Create and return the relocated marker
    return Marker(
      markerId: const MarkerId('userCircleMarker'), // Unique ID for the label marker
      position: LatLng(newLatitude, currentLatLng.longitude), // Updated position based on the walking radius
      icon: BitmapDescriptor.bytes(markerIcon), // Custom icon
    );
  }

}

