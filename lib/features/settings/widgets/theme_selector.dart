import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../providers/theme_provider.dart';

/// ThemeSelector is responsible for displaying and handling theme changes.
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Localized theme label
              Text(
                '${AppLocalizations.of(context)!.theme.capitalize()}: ', // Localized "Theme"
                style: const TextStyle(fontSize: 18),
              ),
              DropdownButton<ThemeMode>(
                value: Provider.of<ThemeProvider>(context).themeMode, // Current theme mode
                items: [
                  const DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'), // Light theme option
                  ),
                  const DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'), // Dark theme option
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(
                      AppLocalizations.of(context)!.system_default.capitalize(), // System default option with localized text
                    ),
                  ),
                ],
                onChanged: (ThemeMode? newTheme) {
                  if (newTheme != null) {
                    Provider.of<ThemeProvider>(context, listen: false).setTheme(newTheme);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context)!.theme_changed_to.capitalize()} ${newTheme.toString().split('.').last}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0), // Spacing before reset button
          ElevatedButton(
            onPressed: () {
              // Reset theme to system default
              Provider.of<ThemeProvider>(context, listen: false).resetTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.theme_reset_default.capitalize()),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.reset_default_theme.capitalize()), // Button label
          ),
        ],
      ),
    );
  }
}
