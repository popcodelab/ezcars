import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart'; // LocaleProvider manages language changes
import '../providers/theme_provider.dart'; // ThemeProvider (optional if managing themes)
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization for UI strings

/// SettingsScreen allows the user to modify app settings such as language.
/// This screen uses LocaleProvider to manage language changes and reflects
/// those changes immediately within the UI.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer listens for changes in LocaleProvider and rebuilds this screen
    // whenever the locale (language) changes.
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Scaffold(
          // AppBar with a localized title using AppLocalizations
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.navSettings), // "Settings"
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
            children: [
              // --- Language Selection Section ---
              Padding(
                padding: const EdgeInsets.all(16.0), // Padding around the row
                child: Row(
                  children: [
                    // Text label for the language dropdown, localized using AppLocalizations
                    Text(
                      '${AppLocalizations.of(context)!.languageLabel}: ', // "Language:"
                      style: const TextStyle(fontSize: 18), // Set font size for the label
                    ),
                    // DropdownButton to select the app language (locale)
                    DropdownButton<Locale>(
                      value: localeProvider.locale, // Currently selected locale from LocaleProvider
                      items: const [
                        DropdownMenuItem(
                          value: Locale('en', 'US'),
                          child: Text('English'), // English option
                        ),
                        DropdownMenuItem(
                          value: Locale('fr'),
                          child: Text('French'), // French option
                        ),
                        DropdownMenuItem(
                          value: Locale('th'),
                          child: Text('Thai'), // Thai option
                        ),
                        DropdownMenuItem(
                          value: Locale('ar'),
                          child: Text('Arabic'), // Arabic option
                        ),
                        DropdownMenuItem(
                          value: Locale.fromSubtags(
                              languageCode: 'zh', countryCode: 'HK', scriptCode: 'Hant'),
                          child: Text('Chinese (Hong Kong)'), // Chinese (HK) option
                        ),
                        DropdownMenuItem(
                          value: Locale('ru', 'RU'),
                          child: Text('Russian'), // Russian option
                        ),
                        DropdownMenuItem(
                          value: Locale('ko'),
                          child: Text('Korean'), // Korean option
                        ),
                      ],
                      // When the user selects a new language, update LocaleProvider
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          // Update the selected locale in LocaleProvider
                          localeProvider.setLocale(newLocale);

                          // Show a SnackBar to notify the user of the change
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Language changed to ${newLocale.toLanguageTag()}'), // Inform user of the new language
                              duration: const Duration(seconds: 2), // Show for 2 seconds
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // --- Additional sections (e.g., Theme selection, etc.) could go here ---

              // Example: Adding a Reset Button for Language
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Reset the language to the default (English US)
                    localeProvider.resetLocale();

                    // Show a SnackBar to notify the user that the language has been reset
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language reset to English (US)'), // Reset confirmation
                        duration: Duration(seconds: 2), // Show for 2 seconds
                      ),
                    );
                  },
                  child: const Text('Reset to Default (English)'), // Button label
                ),
              ),

              // --- If you have other settings like Theme, you can add them here ---

              // Example: Adding a Theme Selection Dropdown (optional)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'Theme: ', // Label for theme dropdown
                      style: TextStyle(fontSize: 18), // Set font size for the label
                    ),
                    DropdownButton<ThemeMode>(
                      value: Provider.of<ThemeProvider>(context).themeMode, // Current theme from ThemeProvider
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
                      // When the user selects a new theme, update ThemeProvider
                      onChanged: (ThemeMode? newTheme) {
                        if (newTheme != null) {
                          // Update the selected theme in ThemeProvider
                          Provider.of<ThemeProvider>(context, listen: false).setTheme(newTheme);

                          // Show a SnackBar to notify the user of the theme change
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Theme changed to ${newTheme.toString().split('.').last}'),
                              duration: const Duration(seconds: 2), // Show for 2 seconds
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Example: Reset Button for Theme
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Reset theme to system default
                    Provider.of<ThemeProvider>(context, listen: false).resetTheme();

                    // Show a SnackBar to notify the user that the theme has been reset
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Theme reset to System Default'),
                        duration: Duration(seconds: 2), // Show for 2 seconds
                      ),
                    );
                  },
                  child: const Text('Reset to System Default Theme'), // Button label
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
