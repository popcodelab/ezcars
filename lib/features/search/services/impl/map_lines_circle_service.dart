import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../i_map_circle_service.dart';

/// Service that creates a circular pattern using line segments.
/// Implements [IMapCircleService] to provide the functionality for creating
/// lines around a specified center point, with each line following the circle's outline.
class MapLinesCircleService implements IMapCircleService {

  /// Creates a set of line segments arranged in a circular pattern around a given center point.
  /// 
  /// The method places line segments around a central coordinate, forming a circle.
  /// Each line segment is tangent to the circle's circumference.
  /// 
  /// - [center]: The geographic center of the circle, given as a [LatLng] coordinate.
  /// - [radiusInMeters]: The radius of the circle in meters.
  /// - [gapBetweenLines]: The gap between consecutive lines around the circle. Larger values will increase the spacing.
  /// - [lineLength]: The length of each individual line segment in meters.
  /// - [lineThickness]: The thickness of each line segment, typically an integer value.
  /// - [lineColor]: The color of the line segments.
  ///
  /// Returns a [Set] of [Polyline] objects that represent the line segments forming the circular pattern.
  @override
  Set<Polyline> createCircleWithLines({
    required LatLng center,
    required double radiusInMeters,
    required double gapBetweenLines,
    required double lineLength,
    required double lineThickness,
    required Color lineColor,
  }) {
    Set<Polyline> polylines = {};

    // Precompute the conversion factor from meters to degrees for latitude.
    // This factor is used to approximate the conversion since one degree of latitude is roughly 111 km.
    const double latConversionFactor = 1 / 111000; // Approximate conversion factor for meters to degrees.
    
    // Adjust longitude conversion factor based on the latitude of the center.
    final double lonConversionFactor = latConversionFactor / cos(center.latitude * pi / 180);

    // Calculate the number of line segments that fit in the circle's circumference.
    double circumference = 2 * pi * radiusInMeters;
    int numSegments = (circumference / gapBetweenLines).floor();

    // Ensure the number of segments is reasonable for visual clarity.
    if (numSegments < 3) {
      numSegments = 3; // Set a minimum number of segments to avoid visual errors.
    }

    // Precompute sin and cos values for each segment to reduce computational load in the loop.
    double angleStep = 2 * pi / numSegments;
    List<double> sinValues = List.generate(numSegments, (i) => sin(i * angleStep));
    List<double> cosValues = List.generate(numSegments, (i) => cos(i * angleStep));

    // Loop through the number of segments and create polylines.
    for (int i = 0; i < numSegments; i++) {
      // Calculate the x and y offsets from the center using trigonometric values.
      double dx = radiusInMeters * cosValues[i];
      double dy = radiusInMeters * sinValues[i];

      // Start point of the line (on the circumference)
      double lineStartLat = center.latitude + (dy * latConversionFactor);
      double lineStartLon = center.longitude + (dx * lonConversionFactor);

      // Calculate the tangent direction to extend the line segment outward.
      double tangentDx = -dy; // Tangent direction is perpendicular to radius: (-y, x)
      double tangentDy = dx;

      // Normalize tangent direction to have unit length, and scale by lineLength/2.
      double tangentLength = sqrt(tangentDx * tangentDx + tangentDy * tangentDy);
      double normalizedTangentDx = (tangentDx / tangentLength) * (lineLength / 2);
      double normalizedTangentDy = (tangentDy / tangentLength) * (lineLength / 2);

      // Calculate start and end points for the line along the tangent direction.
      double lineEndLat1 = lineStartLat + (normalizedTangentDy * latConversionFactor);
      double lineEndLon1 = lineStartLon + (normalizedTangentDx * lonConversionFactor);
      double lineEndLat2 = lineStartLat - (normalizedTangentDy * latConversionFactor);
      double lineEndLon2 = lineStartLon - (normalizedTangentDx * lonConversionFactor);

      // Add a polyline representing the line segment to the set of polylines.
      polylines.add(
        Polyline(
          polylineId: PolylineId('polyline_$i'),
          points: [
            LatLng(lineEndLat1, lineEndLon1),
            LatLng(lineEndLat2, lineEndLon2),
          ],
          color: lineColor,
          width: lineThickness.toInt(), // Convert thickness to integer pixels.
          zIndex: 1, // Define stacking order to ensure the lines are visible over other elements if needed.
        ),
      );
    }

    return polylines;
  }

  /// Not implemented for this service, as this class focuses on creating circles with lines.
  @override
  Set<Circle> createCirclesWithDots({
    required LatLng center,
    required double radiusInMeters,
    required double gapBetweenElements,
    required double dotRadius,
    required Color color,
  }) {
    throw UnimplementedError(); // This method is not used in this service.
  }
}
