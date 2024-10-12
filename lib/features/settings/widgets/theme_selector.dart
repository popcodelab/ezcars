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
                '${AppLocalizations.of(context)!.themeLabel}: ', // Localized "Theme"
                style: const TextStyle(fontSize: 18),
              ),
              DropdownButton<ThemeMode>(
                value: Provider.of<ThemeProvider>(context).themeMode, // Current theme mode
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'), // Light theme option
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'), // Dark theme option
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Default'), // System default option
                  ),
                ],
                onChanged: (ThemeMode? newTheme) {
                  if (newTheme != null) {
                    Provider.of<ThemeProvider>(context, listen: false).setTheme(newTheme);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Theme changed to ${newTheme.toString().split('.').last}',
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
                const SnackBar(
                  content: Text('Theme reset to System Default'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reset to System Default Theme'), // Button label
          ),
        ],
      ),
    );
  }
}
