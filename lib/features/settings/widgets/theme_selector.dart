import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../providers/theme_provider.dart';

/// The `ThemeSelector` widget provides the user interface for selecting
/// the app's theme (light, dark, or system default) and allows resetting
/// it to the system default.
///
/// It uses the `ThemeProvider` for handling the current theme and changing it based on the user's selection.
/// The widget ensures responsiveness by using a flexible layout to avoid overflow issues.
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  /// Builds the user interface for the theme selector.
  ///
  /// The layout adapts to various screen sizes and avoids overflow by using
  /// the `Wrap` widget, which wraps elements to the next line when there is
  /// insufficient horizontal space.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Adds padding around the entire widget for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the left
        children: [
          // Wrap widget ensures that the content can wrap to the next line if necessary
          Wrap(
            alignment: WrapAlignment.spaceBetween, // Aligns child widgets within the available space
            spacing: 8.0, // Spacing between the text and the dropdown button
            children: [
              // Theme label with localized text.
              // The `capitalize()` method is used to ensure the first letter is capitalized.
              Text(
                '${AppLocalizations.of(context)!.theme.capitalize()}: ',
                style: const TextStyle(fontSize: 18), // Sets the font size for the label
              ),
              // Dropdown button for selecting the theme mode.
              // Uses `Expanded` to make sure it takes up the remaining space.
              SizedBox(
                width: 200, // Sets a fixed width for the dropdown button to ensure proper layout
                child: DropdownButton<ThemeMode>(
                  value: Provider.of<ThemeProvider>(context).themeMode, // Gets the current theme mode from the provider
                  isExpanded: true, // Ensures the dropdown button expands to fill the available width
                  items: [
                    // Dropdown menu items for selecting different themes
                    const DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    const DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                    // System default theme option with localized text
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(
                        AppLocalizations.of(context)!.system_default.capitalize(),
                      ),
                    ),
                  ],
                  // This method is called when the user selects a new theme from the dropdown
                  onChanged: (ThemeMode? newTheme) {
                    if (newTheme != null) {
                      // Updates the theme in the ThemeProvider
                      Provider.of<ThemeProvider>(context, listen: false).setTheme(newTheme);

                      // Shows a snackbar to notify the user that the theme has changed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${AppLocalizations.of(context)!.theme_changed_to.capitalize()} ${newTheme.toString().split('.').last}',
                          ),
                          duration: const Duration(seconds: 2), // Duration for which the snackbar is displayed
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0), // Spacing between the dropdown and the reset button

          // Button to reset the theme to the system default
          ElevatedButton(
            onPressed: () {
              // Resets the theme to the system default in the ThemeProvider
              Provider.of<ThemeProvider>(context, listen: false).resetTheme();

              // Shows a snackbar to notify the user that the theme has been reset
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.theme_reset_default.capitalize()),
                  duration: const Duration(seconds: 2), // Duration for which the snackbar is displayed
                ),
              );
            },
            // Label for the reset button with localized text
            child: Text(AppLocalizations.of(context)!.reset_default_theme.capitalize()),
          ),
        ],
      ),
    );
  }
}
