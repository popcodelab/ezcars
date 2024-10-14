import 'package:flutter/material.dart';

class RentalPeriodProvider extends ChangeNotifier {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _startTime;
  DateTime? _endTime;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  void updateDates({
    required DateTime? startDate,
    required DateTime? endDate,
    required DateTime? startTime,
    required DateTime? endTime,
  }) {
    _startDate = startDate;
    _endDate = endDate;
    _startTime = startTime;
    _endTime = endTime;
    notifyListeners();
  }

  void clearDates() {
    _startDate = null;
    _endDate = null;
    _startTime = null;
    _endTime = null;
    notifyListeners();
  }
}
