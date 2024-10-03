import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class IMapCircleService {
  // Method for creating circles with dots
  Set<Circle> createCirclesWithDots({
    required LatLng center,
    required double radiusInMeters,
    required double gapBetweenElements,
    required double dotRadius,
    required Color color,
  });

  // Method for creating circles with lines
  Set<Polyline> createCircleWithLines({
    required LatLng center,
    required double radiusInMeters,
    required double gapBetweenLines,
    required double lineLength,
    required double lineThickness,
    required Color lineColor,
  });
}
