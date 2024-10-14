import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'custom_calendar.dart';
import 'time_picker.dart';

/// A custom date range picker widget that allows users to select a range of dates
/// and times (start and end date, start and end time). The picker is designed to show
/// a calendar and time selection options, with apply and cancel buttons.
class CustomDateRangePicker extends StatefulWidget {
  final DateTime minimumDate; // The earliest selectable date
  final DateTime maximumDate; // The latest selectable date
  final bool barrierDismissible; // Whether the picker can be dismissed by tapping outside
  final DateTime? initialStartDate; // Initial start date (optional)
  final DateTime? initialEndDate; // Initial end date (optional)
  final DateTime? initialStartTime; // Initial start time (optional)
  final DateTime? initialEndTime; // Initial end time (optional)
  final Color primaryColor; // Primary color for the picker
  final Color backgroundColor; // Background color for the picker
  final Function(DateTime, DateTime, DateTime, DateTime) onApplyClick; // Callback for the apply action
  final Function() onCancelClick; // Callback for the cancel action

  const CustomDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialStartTime,
    this.initialEndTime,
    required this.primaryColor,
    required this.backgroundColor,
    required this.onApplyClick,
    this.barrierDismissible = true, // Default to dismissible
    required this.minimumDate,
    required this.maximumDate,
    required this.onCancelClick,
  });

  @override
  CustomDateRangePickerState createState() => CustomDateRangePickerState();
}

class CustomDateRangePickerState extends State<CustomDateRangePicker>
    with TickerProviderStateMixin {
  AnimationController? animationController; // Controller for animations in the picker

  DateTime? startDate; // Currently selected start date
  DateTime? endDate; // Currently selected end date
  DateTime? startTime; // Currently selected start time
  DateTime? endTime; // Currently selected end time

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for showing animations
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize the start and end date/time from the widget's initial values
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    startTime = widget.initialStartTime;
    endTime = widget.initialEndTime;

    // Start the animation
    animationController?.forward();
  }

  @override
  void dispose() {
    // Clean up the animation controller when the widget is disposed
    animationController?.dispose();
    super.dispose();
  }

  /// Helper method to check if the selected date range is valid.
  /// Ensures that both dates are set, and the end date is after or the same as the start date.
  bool isDateRangeValid() {
    return startDate != null &&
        endDate != null &&
        (endDate!.isAfter(startDate!) || endDate!.isAtSameMomentAs(startDate!));
  }

  /// Helper method to check if both start and end times are selected.
  bool isTimeRangeValid() {
    return startTime != null && endTime != null;
  }

  /// Helper method to determine if the "Apply" button should be enabled.
  /// Returns true if both the date range and time range are valid.
  bool isApplyEnabled() {
    return isDateRangeValid() && isTimeRangeValid();
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);

    return Center(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            // If the picker is dismissible, allow it to close when tapping outside
            if (widget.barrierDismissible) {
              Navigator.pop(context);
            }
          },
          child: Center(
            child: Padding(
              // Added padding around the picker container
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 24.0, bottom: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: const Offset(4, 4),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                  onTap: () {}, // Prevents interaction when tapping inside
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Sized to content height
                    children: <Widget>[
                      // Date and Time display
                      Row(
                        children: <Widget>[
                          // Left column for start date and time
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)!.from,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Show selected start date or placeholder if null
                                Text(
                                  startDate != null
                                      ? DateFormat('EEE, dd MMM')
                                          .format(startDate!)
                                      : '--/--',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                // Show selected start time or nothing if null
                                startTime != null
                                    ? Text(
                                        DateFormat('h:mm a').format(startTime!),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          // Vertical divider between start and end columns
                          Container(
                            height: 74,
                            width: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                          // Right column for end date and time
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)!.to,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Show selected end date or placeholder if null
                                Text(
                                  endDate != null
                                      ? DateFormat('EEE, dd MMM')
                                          .format(endDate!)
                                      : '--/--',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                // Show selected end time or nothing if null
                                endTime != null
                                    ? Text(
                                        DateFormat('h:mm a').format(endTime!),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 1), // Divider between rows

                      // Custom Calendar widget for selecting dates
                      CustomCalendar(
                        minimumDate: widget.minimumDate,
                        maximumDate: widget.maximumDate,
                        initialEndDate: widget.initialEndDate,
                        initialStartDate: widget.initialStartDate,
                        primaryColor: theme.primaryColor,
                        startEndDateChange:
                            (DateTime startDateData, DateTime? endDateData) {
                          // Update start and end dates when the user selects new values
                          setState(() {
                            startDate = startDateData;
                            endDate = endDateData != null &&
                                    endDateData.isAfter(startDateData)
                                ? endDateData
                                : null;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // Time Picker for Start Time
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(AppLocalizations.of(context)!.pickup_date),
                      ),
                      TimePickerWidget(
                        timeIntervals: generateTimeIntervals(),
                        selectedTime: startTime,
                        onTimeSelected: (DateTime time) {
                          // Update the selected start time when the user picks a time
                          setState(() {
                            startTime = time;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Time Picker for End Time
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(AppLocalizations.of(context)!.return_date),
                      ),
                      TimePickerWidget(
                        timeIntervals: generateTimeIntervals(),
                        selectedTime: endTime,
                        onTimeSelected: (DateTime time) {
                          // Update the selected end time when the user picks a time
                          setState(() {
                            endTime = time;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons (Apply and Cancel)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16, top: 8),
                        child: Row(
                          children: [
                            // Cancel button
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    side: WidgetStateProperty.all(
                                        BorderSide(color: theme.primaryColor)),
                                    shape: WidgetStateProperty.all(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(24.0)),
                                      ),
                                    ),
                                    backgroundColor: WidgetStateProperty.all(
                                        theme.primaryColor),
                                  ),
                                  onPressed: () {
                                    // Trigger the cancel callback and close the picker
                                    widget.onCancelClick();
                                    Navigator.pop(context);
                                  },
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Apply button (enabled only if dates and times are valid)
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    side: WidgetStateProperty.all(BorderSide(
                                        color: isApplyEnabled()
                                            ? theme.primaryColor
                                            : Colors.grey)),
                                    shape: WidgetStateProperty.all(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(24.0)),
                                      ),
                                    ),
                                    backgroundColor: WidgetStateProperty.all(
                                        isApplyEnabled()
                                            ? theme.primaryColor
                                            : Colors.grey),
                                  ),
                                  onPressed: isApplyEnabled()
                                      ? () {
                                          // Trigger the apply callback with selected values and close the picker
                                          widget.onApplyClick(
                                            startDate!,
                                            endDate!,
                                            startTime!,
                                            endTime!,
                                          );
                                          Navigator.pop(context);
                                        }
                                      : null, // Disabled if validation fails
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.apply,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// Generates a list of time intervals with 30-minute gaps for the time picker.
  List<DateTime> generateTimeIntervals() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0);
    List<DateTime> intervals = [];

    for (int i = 0; i < 48; i++) {
      intervals.add(startOfDay.add(Duration(minutes: i * 30)));
    }

    return intervals;
  }
}

/// Shows the `CustomDateRangePicker` as a dialog.
void showCustomDateRangePicker(
  BuildContext context, {
  required bool dismissible,
  required DateTime minimumDate,
  required DateTime maximumDate,
  DateTime? startDate,
  DateTime? endDate,
  DateTime? startTime,
  DateTime? endTime,
  required Function(DateTime startDate, DateTime endDate, DateTime startTime,
          DateTime endTime)
      onApplyClick,
  required Function() onCancelClick,
  required Color backgroundColor,
  required Color primaryColor,
}) {
  FocusScope.of(context).requestFocus(FocusNode());

  showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) => CustomDateRangePicker(
      barrierDismissible: dismissible,
      backgroundColor: backgroundColor,
      primaryColor: primaryColor,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      initialStartDate: startDate,
      initialEndDate: endDate,
      initialStartTime:
          startTime, // Added to initialize start time in the picker
      initialEndTime: endTime, // Added to initialize end time in the picker
      onApplyClick: onApplyClick,
      onCancelClick: onCancelClick,
    ),
  );
}
