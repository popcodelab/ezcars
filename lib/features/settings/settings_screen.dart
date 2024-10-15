import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/walking_radiius_provider.dart';
import 'widgets/language_selector.dart';
import 'widgets/theme_selector.dart';

/// The `SettingsScreen` allows the user to change the app's language, theme,
/// and adjust the walking distance radius used for calculating proximity.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.nav_settings ?? 'Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector widget
            const LanguageSelector(),
            const SizedBox(height: 16.0),
            // Theme selector widget
            const ThemeSelector(),
            const SizedBox(height: 16.0),
            // Walking radius setting with a slider
            Text(
              AppLocalizations.of(context)?.walking_radius_label ?? 'Walking Radius (meters)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Consumer<WalkingRadiusProvider>(
              builder: (context, walkingRadiusProvider, child) {
                return Column(
                  children: [
                    Slider(
                      value: walkingRadiusProvider.walkingRadius,
                      min: 500,
                      max: 6000,
                      divisions: 20,
                      label: '${walkingRadiusProvider.walkingRadius.round()} meters',
                      onChanged: (double value) {
                        walkingRadiusProvider.updateRadius(value);
                      },
                    ),
                    Text(
                      '${AppLocalizations.of(context)?.current_radius ?? 'Current radius'}: ${walkingRadiusProvider.walkingRadius.round()} meters',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
