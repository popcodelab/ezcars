import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../i_map_transparent_circle_service.dart';


/// Service that draws a transparent circle with customizable opacity on a map.
/// Implements [IMapTransparentCircleService] to provide the functionality
/// of drawing a circle with a specified center, radius, opacity, and color.
class MapTransparentCircleService implements IMapTransparentCircleService {

  /// Creates a transparent circle with the specified parameters.
  /// 
  /// This method generates a [Circle] with customizable fill color, border
  /// color, border width, and opacity, and places it on the map.
  /// 
  /// - [center]: The geographic center of the circle, given as a [LatLng] coordinate.
  /// - [radiusInMeters]: The radius of the circle in meters.
  /// - [opacity]: The opacity level of the circle's fill color. Must be between 0.0 (fully transparent) and 1.0 (fully opaque).
  /// - [fillColor]: The fill color of the circle.
  /// - [strokeWidth]: The width of the circle's border in pixels.
  /// - [strokeColor]: The color of the circle's border.
  /// 
  /// Returns a [Set] of [Circle] objects containing the transparent circle.
  @override
  Set<Circle> createTransparentCircle({
    required LatLng center,
    required double radiusInMeters,
    required double opacity,
    required Color fillColor,
    required int strokeWidth,
    required Color strokeColor,
  }) {
    Set<Circle> circles = {};

    // Ensure opacity is within valid bounds [0.0, 1.0]
    opacity = opacity.clamp(0.0, 1.0);

    // Apply opacity to the fill color using the `withOpacity` method.
    Color transparentFillColor = fillColor.withOpacity(opacity);

    // Create a Circle object with the specified parameters.
    circles.add(
      Circle(
        circleId: const CircleId('transparent_circle'),
        center: center,
        radius: radiusInMeters,
        fillColor: transparentFillColor, // Fill color with applied opacity.
        strokeColor: strokeColor, // Border color.
        strokeWidth: strokeWidth, // Border width.
        zIndex: 1, // Z-index to ensure visibility over other map elements.
      ),
    );

    return circles;
  }
}
