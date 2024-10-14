import 'package:ezcars/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A customizable calendar widget that allows users to select a range of dates,
/// including cross-month selections, with optional minimum and maximum date constraints.
class CustomCalendar extends StatefulWidget {
  /// The minimum date that can be selected on the calendar.
  final DateTime? minimumDate;

  /// The maximum date that can be selected on the calendar.
  final DateTime? maximumDate;

  /// The initial start date to be shown on the calendar.
  final DateTime? initialStartDate;

  /// The initial end date to be shown on the calendar.
  final DateTime? initialEndDate;

  /// The primary color to be used in the calendar's color scheme.
  final Color primaryColor;

  /// A function to be called when the selected date range changes.
  final Function(DateTime, DateTime)? startEndDateChange;

  const CustomCalendar({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.startEndDateChange,
    this.minimumDate,
    this.maximumDate,
    required this.primaryColor,
  });

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  List<DateTime> dateList = <DateTime>[];  // List of displayed dates for the current view.
  DateTime currentMonthDate = DateTime.now();  // Tracks the current month being displayed.
  DateTime? startDate;  // Start date of the selected range.
  DateTime? endDate;    // End date of the selected range.

  @override
  void initState() {
    setListOfDate(currentMonthDate);  // Initialize the date list for the current month.
    if (widget.initialStartDate != null) {
      startDate = widget.initialStartDate;  // Set initial start date.
    }
    if (widget.initialEndDate != null) {
      endDate = widget.initialEndDate;  // Set initial end date.
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Fills the `dateList` with dates to display in the calendar view,
  /// spanning from the previous month, current month, and some of the next month.
  void setListOfDate(DateTime monthDate) {
    dateList.clear();  // Clear previous dates.

    // Get the first day of the current month.
    final DateTime firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    int firstWeekday = firstDayOfMonth.weekday;  // Get the day of the week for the 1st of the month.

    // Calculate the starting date for the calendar grid, going back to the previous month if needed.
    DateTime startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday));

    // Add 42 dates (6 weeks) to the `dateList`, covering current, previous, and next month.
    for (int i = 0; i < 42; i++) {
      dateList.add(startDate.add(Duration(days: i)));
    }
  }

  /// Builds the main UI for the calendar, which includes the month navigation,
  /// day labels, and the grid of selectable dates.
  @override
  Widget build(BuildContext context) {
    var localeProvider = context.watch<LocaleProvider>();  // Retrieve app state, if necessary for localization.
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 4),
          child: Row(
            children: <Widget>[
              // Left navigation arrow (previous month).
              buildNavArrow(Icons.keyboard_arrow_left, () {
                setState(() {
                  currentMonthDate = DateTime(currentMonthDate.year, currentMonthDate.month - 1);
                  setListOfDate(currentMonthDate);  // Refresh the date list for the previous month.
                });
              }),
              // Display current month and year.
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('MMMM, yyyy', localeProvider.locale.languageCode)
                        .format(currentMonthDate),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              // Right navigation arrow (next month).
              buildNavArrow(Icons.keyboard_arrow_right, () {
                setState(() {
                  currentMonthDate = DateTime(currentMonthDate.year, currentMonthDate.month + 1);
                  setListOfDate(currentMonthDate);  // Refresh the date list for the next month.
                });
              }),
            ],
          ),
        ),
        // Row of day names (Mon, Tue, etc.).
        Padding(
          padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
          child: Row(
            children: getDaysNameUI(localeProvider.locale.languageCode),
          ),
        ),
        // Grid of day numbers.
        Padding(
          padding: const EdgeInsets.only(right: 8, left: 8),
          child: Column(
            children: getDaysNoUI(),
          ),
        ),
      ],
    );
  }

  /// Builds the navigation arrow button.
  Widget buildNavArrow(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            onTap: onPressed,
            child: Icon(icon, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Returns the day name widgets (Mon, Tue, etc.) based on the locale.
  List<Widget> getDaysNameUI(String languageCode) {
    final List<Widget> listUI = <Widget>[];
    for (int i = 0; i < 7; i++) {
      listUI.add(
        Expanded(
          child: Center(
            child: Text(
              DateFormat('EEE', languageCode).format(dateList[i]),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: widget.primaryColor),
            ),
          ),
        ),
      );
    }
    return listUI;
  }

  /// Returns the grid of day numbers, where each day is clickable
  /// and displays the selected date range.
  List<Widget> getDaysNoUI() {
    final List<Widget> noList = <Widget>[];  // List of rows (weeks).
    int count = 0;
    for (int i = 0; i < dateList.length / 7; i++) {
      final List<Widget> listUI = <Widget>[];  // List of day widgets in the current week.
      for (int j = 0; j < 7; j++) {
        final DateTime date = dateList[count];  // The current date to display.
        listUI.add(buildDateUI(date));  // Add a day UI to the week row.
        count += 1;
      }
      noList.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: listUI,
      ));
    }
    return noList;
  }

  /// Builds the UI for a single date cell in the calendar grid.
  Widget buildDateUI(DateTime date) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          children: <Widget>[
            // Highlight for selected date range.
            buildDateHighlight(date),
            // The clickable date itself.
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                onTap: () => onDateClick(date),  // Handle date selection.
                child: buildDateContent(date),
              ),
            ),
            // Dot indicator for today's date.
            buildTodayDot(date),
          ],
        ),
      ),
    );
  }

  /// Handles the logic when a user clicks on a date.
  /// This supports cross-month selection of date ranges.
  void onDateClick(DateTime date) {
    setState(() {
      if (startDate == null) {
        // Set the start date if it's not set.
        startDate = date;
        endDate = null;
      } else if (endDate == null) {
        // Set the end date only if it's after the start date.
        if (date.isAfter(startDate!)) {
          endDate = date;
        } else {
          // Reset the start date if a date earlier than startDate is clicked.
          startDate = date;
          endDate = null;
        }
      } else {
        // If both startDate and endDate are set, reset the selection.
        startDate = date;
        endDate = null;
      }

      // Trigger the callback if both startDate and endDate are selected.
      if (startDate != null && endDate != null) {
        widget.startEndDateChange?.call(startDate!, endDate!);
      }
    });
  }

  /// Builds the background highlight for selected date ranges.
  Widget buildDateHighlight(DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
              top: 2,
              bottom: 2,
              left: isStartDateRadius(date) ? 4 : 0,
              right: isEndDateRadius(date) ? 4 : 0),
          child: Container(
            decoration: BoxDecoration(
              color: startDate != null && endDate != null
                  ? (getIsItStartAndEndDate(date) || getIsInRange(date))
                      ? widget.primaryColor.withOpacity(0.4)
                      : Colors.transparent
                  : Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: isStartDateRadius(date)
                    ? const Radius.circular(24.0)
                    : const Radius.circular(0.0),
                topLeft: isStartDateRadius(date)
                    ? const Radius.circular(24.0)
                    : const Radius.circular(0.0),
                topRight: isEndDateRadius(date)
                    ? const Radius.circular(24.0)
                    : const Radius.circular(0.0),
                bottomRight: isEndDateRadius(date)
                    ? const Radius.circular(24.0)
                    : const Radius.circular(0.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the content (day number) of a date cell.
  Widget buildDateContent(DateTime date) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: getIsItStartAndEndDate(date)
              ? widget.primaryColor
              : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
          border: Border.all(
            color: getIsItStartAndEndDate(date) ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: getIsItStartAndEndDate(date)
              ? <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      blurRadius: 4,
                      offset: const Offset(0, 0)),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
                color: getIsItStartAndEndDate(date)
                    ? Colors.white
                    : currentMonthDate.month == date.month
                        ? widget.primaryColor
                        : Colors.grey.withOpacity(0.6),
                fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                fontWeight: getIsItStartAndEndDate(date)
                    ? FontWeight.bold
                    : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  /// Displays a dot indicator if the date is today.
  Widget buildTodayDot(DateTime date) {
    return Positioned(
      bottom: 9,
      right: 0,
      left: 0,
      child: Container(
        height: 6,
        width: 6,
        decoration: BoxDecoration(
          color: DateTime.now().day == date.day &&
                  DateTime.now().month == date.month &&
                  DateTime.now().year == date.year
              ? getIsInRange(date) ? Colors.white : widget.primaryColor
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Checks if a date is in the selected range between `startDate` and `endDate`.
  bool getIsInRange(DateTime date) {
    if (startDate != null && endDate != null) {
      return date.isAfter(startDate!) && date.isBefore(endDate!);
    }
    return false;
  }

  /// Checks if a date is either the `startDate` or `endDate`.
  bool getIsItStartAndEndDate(DateTime date) {
    return (startDate != null && isSameDay(date, startDate!)) ||
        (endDate != null && isSameDay(date, endDate!));
  }

  /// Helper to check if a date is the `startDate` and should have rounded corners.
  bool isStartDateRadius(DateTime date) {
    if (startDate != null && isSameDay(date, startDate!)) {
      return true;
    } else if (date.weekday == DateTime.monday) {
      return true;
    }
    return false;
  }

  /// Helper to check if a date is the `endDate` and should have rounded corners.
  bool isEndDateRadius(DateTime date) {
    if (endDate != null && isSameDay(date, endDate!)) {
      return true;
    } else if (date.weekday == DateTime.sunday) {
      return true;
    }
    return false;
  }

  /// Checks if two dates represent the same day.
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
