import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

import '../../utilities/date_time_formatter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget for Date-Time Picker Tile.
/// Displays selected start and end dates and times in a formatted way.
/// If no dates are selected, it shows a default 'When?' message.
class DateTimePickerTile extends StatelessWidget {
  final DateTime? startDate; // The selected start date, or null if not selected.
  final DateTime? endDate; // The selected end date, or null if not selected.
  final DateTime? startTime; // The selected start time, or null if not selected.
  final DateTime? endTime; // The selected end time, or null if not selected.
  final Function onDateTap; // Callback when the user taps to pick a date.

  const DateTimePickerTile({
    super.key,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    required this.onDateTap, // The date tap callback is required.
  });

  @override
  Widget build(BuildContext context) {
    // Use the theme of the app to style the text and icon.
    final theme = Theme.of(context);

    // Format the pickup (start) and return (end) date-times.
    final pickupDateTime = DateTimeFormatter.getFormattedDateTime(startDate, startTime);
    final returnDateTime = DateTimeFormatter.getFormattedDateTime(endDate, endTime);

    return InkWell(
      onTap: () => onDateTap(), // Call the callback when the tile is tapped.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Align icon and text vertically.
        children: [
          Icon(
            Icons.calendar_today, // Calendar icon for date selection.
            color: theme.colorScheme.primary, // Primary theme color for icon.
            size: 14.0, // Icon size set to 14 for consistency.
          ),
          const SizedBox(width: 4.0), // Reduce space between the icon and text.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start.
              children: [
                // Show 'When?' if no date is selected, otherwise show formatted pickup date-time.
                Text(
                  startDate == null && endDate == null ? '${AppLocalizations.of(context)!.when.capitalize()}?' : pickupDateTime,
                  style: theme.textTheme.bodyMedium, // Use medium body text style from the theme.
                ),
                // If both start and end dates are selected, show the formatted return date-time.
                if (startDate != null && endDate != null)
                  Text(
                    returnDateTime,
                    style: theme.textTheme.bodyMedium, // Use medium body text style for consistency.
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
