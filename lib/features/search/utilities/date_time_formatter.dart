import 'package:intl/intl.dart';

/// Utility class for formatting date and time.
class DateTimeFormatter {
  /// Formats the given date and time into a user-friendly string like "Oct 7 7:30 PM".
  static String getFormattedDateTime(DateTime? date, DateTime? time) {
    if (date == null || time == null) return '-';
    
    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return DateFormat("MMM d h:mm a").format(combinedDateTime);
  }
}
