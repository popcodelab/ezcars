import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../i_map_circle_label_service.dart';


class MapCircleLabelService implements IMapCircleLabelService {
  @override
  Future<Uint8List> createCustomMarker(String text, Size markerSize) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Set the dimensions of the marker
    final double iconSize = markerSize.height * 0.5; // Adjust icon size relative to the marker height
    final double textFontSize = markerSize.height * 0.4; // Adjust text size relative to the marker height
    final double padding = markerSize.width * 0.05; // Padding as a percentage of the marker width

    // Draw a rounded rectangle background
    final paint = Paint()..color = Colors.white;
    final radius = Radius.circular(markerSize.height * 0.2); // Radius is a fraction of the height
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0.0, 0.0, markerSize.width, markerSize.height), radius);
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
    final double iconVerticalOffset = (markerSize.height - iconPainter.height) / 2; // Center vertically
    iconPainter.paint(canvas, Offset(padding, iconVerticalOffset));

    // Draw the text to the right of the icon
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
      maxWidth: markerSize.width - (iconSize + 3 * padding), // Reserve space for the icon and padding
    );
    final double textVerticalOffset = (markerSize.height - textPainter.height) / 2; // Center vertically
    textPainter.paint(canvas, Offset(iconSize + 2 * padding, textVerticalOffset));

    // Convert the canvas into an image and get the bytes
    final picture = recorder.endRecording();
    final img = await picture.toImage(markerSize.width.toInt(), markerSize.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
