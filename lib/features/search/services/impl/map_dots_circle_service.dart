import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../i_map_circle_service.dart';

class MapDotsCircleService implements IMapCircleService {
  @override
  Set<Circle> createCirclesWithDots({
    required LatLng center,
    required double radiusInMeters,
    required double gapBetweenElements,
    required double dotRadius,
    required Color color,
  }) {
    Set<Circle> circles = {};
    int circleIdCounter = 0;

    // Precompute the conversion factor from meters to degrees for latitude
    const double latConversionFactor = 1 / 111000; // Approximate conversion factor
    final double lonConversionFactor = latConversionFactor / cos(center.latitude * pi / 180);

    // Calculate the number of dots that fit in the circle's circumference
    double circumference = 2 * pi * radiusInMeters;
    int numDots = (circumference / gapBetweenElements).floor();

    // Precompute sin and cos values to reduce computation in the loop
    double angleStep = 2 * pi / numDots;
    List<double> sinValues = List.generate(numDots, (i) => sin(i * angleStep));
    List<double> cosValues = List.generate(numDots, (i) => cos(i * angleStep));

    // Place dots around the circle using precomputed sin and cos values
    for (int i = 0; i < numDots; i++) {
      double dx = radiusInMeters * cosValues[i];
      double dy = radiusInMeters * sinValues[i];

      double newLatitude = center.latitude + (dy * latConversionFactor);
      double newLongitude = center.longitude + (dx * lonConversionFactor);

      circles.add(
        Circle(
          circleId: CircleId('circle_$i'),
          center: LatLng(newLatitude, newLongitude),
          radius: dotRadius,
          strokeWidth: 0,
          fillColor: color,
          zIndex: 1,
        ),
      );
    }

    return circles;
  }

  @override
  Set<Polyline> createCircleWithLines({
    required LatLng center,
    required double radiusInMeters,
    required double gapBetweenLines,
    required double lineLength,
    required double lineThickness,
    required Color lineColor,
  }) {
    throw UnimplementedError(); // Not used in this class
  }
}
