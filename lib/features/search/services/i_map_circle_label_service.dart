import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

abstract class IMapCircleLabelService {
  Future<Uint8List> createCustomMarker(String text, Size markerSize);
}
