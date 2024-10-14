import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'widgets/language_selector.dart';
import 'widgets/theme_selector.dart';

/// The `SettingsScreen` is a stateless widget that displays
/// options for changing the language and theme of the application.
///
/// This screen includes two widgets:
/// - `LanguageSelector`: A widget for changing the app's language.
/// - `ThemeSelector`: A widget for switching between light and dark themes.
///
/// The title of the screen is localized using `AppLocalizations`.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Builds the settings screen UI.
  ///
  /// This method constructs a `Scaffold` with an app bar that contains
  /// a localized title, and a body with two main options for language
  /// and theme selection. The UI is designed to be responsive and
  /// avoids overflow on small screens by using a `SingleChildScrollView`.
  ///
  /// - [context]: The build context for this widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The app bar with a localized title for "Settings"
      appBar: AppBar(
        // Uses the localization system to get the "Settings" string
        title: Text(AppLocalizations.of(context)?.nav_settings ?? 'Settings'),
      ),
      // The body of the settings screen
      body: const SingleChildScrollView(
        // Padding around the content to provide breathing room
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language selector widget allows the user to change the app language
              LanguageSelector(),
              // Theme selector widget allows the user to switch between themes
              ThemeSelector(),
            ],
          ),
        ),
      ),
    );
  }
}
