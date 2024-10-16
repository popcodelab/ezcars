import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/walking_radiius_provider.dart';
import '../../providers/distance_unit_provider.dart'; // Import the distance unit provider
import 'widgets/language_selector.dart';
import 'widgets/theme_selector.dart';

/// The `SettingsScreen` allows the user to change the app's language, theme,
/// adjust the walking distance radius, and set the distance unit.
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
            const SizedBox(height: 16.0),

            // Distance unit setting
            Text(
              AppLocalizations.of(context)?.distance_unit ?? 'Distance Unit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Consumer<DistanceUnitProvider>(
              builder: (context, distanceUnitProvider, child) {
                return Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(AppLocalizations.of(context)?.miles ?? 'Miles'),
                      value: 'miles',
                      groupValue: distanceUnitProvider.distanceUnit,
                      onChanged: (String? value) {
                        if (value != null) {
                          distanceUnitProvider.updateDistanceUnit(value);
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(AppLocalizations.of(context)?.kilometers ?? 'Kilometers'),
                      value: 'kilometers',
                      groupValue: distanceUnitProvider.distanceUnit,
                      onChanged: (String? value) {
                        if (value != null) {
                          distanceUnitProvider.updateDistanceUnit(value);
                        }
                      },
                    ),
                    Text(
                      '${AppLocalizations.of(context)?.current_unit ?? 'Current unit'}: ${distanceUnitProvider.distanceUnit}',
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
