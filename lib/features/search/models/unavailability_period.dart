
/// Defines an unavaibility period for a vehicule.
/// The vehicule owner could block some dates for his own vehicule use
library;

import 'package:flutter/material.dart';

class UnavailabilityPeriod {
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime endDate;
  final TimeOfDay endTime;

  UnavailabilityPeriod({
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
  });
}

