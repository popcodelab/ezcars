import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'widgets/language_selector.dart';
import 'widgets/theme_selector.dart';

/// SettingsScreen shows language and theme selection options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.nav_settings), // Localized title
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LanguageSelector(), // Widget to select the language
          ThemeSelector(),    // Widget to select the theme
        ],
      ),
    );
  }
}


