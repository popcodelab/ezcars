import 'package:ezcars/features/search/providers/rental_period_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/location_provider.dart';
import 'date_time/custom_date_range_picker.dart';
import 'places_autocompletion_with_history.dart';

/// The `LocationDateSelectors` widget allows users to select a location and date-time range
/// for rental services. It also shows the selected date-time when available.
class LocationDateSelectors extends StatelessWidget {
  const LocationDateSelectors({super.key});

  /// Formats the given date and time into a user-friendly string like "Oct 7 7:30 PM".
  String getFormattedDateTime(DateTime? date, DateTime? time) {
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

  @override
  Widget build(BuildContext context) {
    // Access the current theme for consistent styling
    final theme = Theme.of(context);

    // Access the global rental period state to retrieve or update date and time selections
    final rentalPeriodState = context.watch<RentalPeriodProvider>();

    // Access the global location state to retrieve or update location selection
    final locationState = context.watch<LocationProvider>();

    // Retrieve the formatted pickup and return date-time details
    final pickupDateTime = getFormattedDateTime(
        rentalPeriodState.startDate, rentalPeriodState.startTime);
    final returnDateTime = getFormattedDateTime(
        rentalPeriodState.endDate, rentalPeriodState.endTime);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Container for location and date selection
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme
                    .dividerColor, // Use theme's divider color for consistency
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Location selection tile
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: theme.colorScheme
                          .primary, // Use primary color from the theme
                      size: 20.0, // Reduced icon size for better fit
                    ),
                    title: Text(
                      locationState.selectedPlace?.name ??
                          'Current location', // Display the selected location name or default text
                      style: theme
                          .textTheme.bodyMedium, // Use theme-defined text style
                    ),
                    onTap: () async {
                      // Handle location selection by navigating to the PlacesAutocompletionScreen
                      var selectedLocation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PlacesAutocompletionWithHistoryScreen(),
                        ),
                      );
                      if (selectedLocation != null &&
                          selectedLocation is Place) {
                        // Update the global location state with the new location
                        locationState.updateLocation(selectedLocation);
                      }
                    },
                  ),
                ),
                // Separator between location and date tiles
                Container(
                  height: 50.0,
                  width: 1.0,
                  color: theme.dividerColor, // Use theme's divider color
                ),
                // Date selection tile
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme
                          .primary, // Use primary color from the theme
                      size: 20.0, // Reduced icon size for better fit
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rentalPeriodState.startDate == null &&
                                  rentalPeriodState.endDate == null
                              ? 'When?' // Default text when no date is selected
                              : pickupDateTime, // Display pickup date and time
                          style: theme
                              .textTheme.bodyMedium, // Use theme text style
                        ),
                        if (rentalPeriodState.startDate != null &&
                            rentalPeriodState.endDate != null)
                          Text(
                            returnDateTime, // Display return date and time
                            style: theme
                                .textTheme.bodyMedium, // Use theme text style
                          ),
                      ],
                    ),
                    onTap: () {
                      // Handle date selection by showing the custom date range picker
                      showCustomDateRangePicker(
                        context,
                        dismissible: true,
                        minimumDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        maximumDate:
                            DateTime.now().add(const Duration(days: 30)),
                        startDate: rentalPeriodState
                            .startDate, // Providing initial start date
                        endDate: rentalPeriodState
                            .endDate, // Providing initial end date
                        startTime: rentalPeriodState
                            .startTime, // Providing initial start time
                        endTime: rentalPeriodState
                            .endTime, // Providing initial end time
                        backgroundColor: Colors.white,
                        primaryColor: Colors.green,
                        onApplyClick: (selectedStartDate, selectedEndDate,
                            selectedStartTime, selectedEndTime) {
                          // Update rental period state with new selections
                          rentalPeriodState.updateDates(
                            startDate: selectedStartDate,
                            endDate: selectedEndDate,
                            startTime: selectedStartTime,
                            endTime: selectedEndTime,
                          );
                        },
                        onCancelClick: () {
                          // Clear dates if the user cancels the selection
                          rentalPeriodState.clearDates();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0), // Spacing between widgets
          // Placeholder message when no results are found
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme
                      .surface, // Use theme surface color for the background
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No results\nPlease widen your search',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(
                        0.6), // Use a lighter color for the placeholder text
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
