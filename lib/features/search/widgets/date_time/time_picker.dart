import 'package:flutter/material.dart';
/// user for DateTime formatting
import 'package:intl/intl.dart';

/// Time picker widget
class TimePickerWidget extends StatelessWidget {
  final List<DateTime> timeIntervals;
  final DateTime? selectedTime;
  final Function(DateTime) onTimeSelected;

  const TimePickerWidget({
    super.key,
    required this.timeIntervals,
    this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: timeIntervals.map((time) {
          return GestureDetector(
            onTap: () {
              onTimeSelected(time);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedTime == time ? Colors.amber[200]: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  DateFormat.Hm().format(time),
                  style: TextStyle(
                    color: selectedTime == time ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}