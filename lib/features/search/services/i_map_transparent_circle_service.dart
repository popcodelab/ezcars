import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Interface for creating circles with customizable opacity on a map.
abstract class IMapTransparentCircleService {
  
  /// Creates a transparent circle on a map.
  /// 
  /// - [center]: The geographic center of the circle, given as a [LatLng] coordinate.
  /// - [radiusInMeters]: The radius of the circle in meters.
  /// - [opacity]: The opacity level of the circle, ranging from 0.0 (completely transparent) to 1.0 (completely opaque).
  /// - [fillColor]: The fill color of the circle.
  /// - [strokeWidth]: The width of the circle's border in pixels.
  /// - [strokeColor]: The color of the circle's border.
  Set<Circle> createTransparentCircle({
    required LatLng center,
    required double radiusInMeters,
    required double opacity,
    required Color fillColor,
    required int strokeWidth,
    required Color strokeColor,
  });
}
