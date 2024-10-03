import 'package:flutter/material.dart';

import '../../profile_screen.dart';

/// The `LocationDateSelectors` allows users to select
/// a location and a date for an activity or rental, and also displays a placeholder message.
class LocationDateSelectors extends StatelessWidget {
  const LocationDateSelectors({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Container for location and date selection
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme.dividerColor, // Use theme's divider color
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
                      color: theme.colorScheme.primary, // Use primary color from the theme
                    ),
                    title: Text(
                      'Current location',
                      style: theme.textTheme.bodyMedium, // Use theme text style
                    ),
                    onTap: () async {
                      // Handle location selection by navigating to the PlacesAutocompletionScreen
                      var selectedLocation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen() // PlacesAutocompletionScreen(),
                        ),
                      );
                      if (selectedLocation != null) {
                        // Handle the selected location here
                        // e.g., print(selectedLocation);
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
                      color: theme.colorScheme.primary, // Use primary color from the theme
                    ),
                    title: Text(
                      'When?',
                      style: theme.textTheme.bodyMedium, // Use theme text style
                    ),
                    onTap: () {
                      // Handle date selection by showing the RentalPeriodScreen bottom sheet
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return const ProfileScreen(); // RentalPeriodScreen(); // Bottom sheet for date-time selection
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
                  color: theme.colorScheme.surface, // Use theme surface color for the background
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No results\nPlease widen your search',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6), // Use a lighter color
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
