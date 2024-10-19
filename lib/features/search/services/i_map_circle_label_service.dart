import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class IMapCircleLabelService {
  Future<Uint8List> createCustomMarker(String text, Size markerSize);

  Future<Marker> relocateCustomMarker(LatLng currentLatLng, double walkingRadius, Uint8List markerIcon);
}
