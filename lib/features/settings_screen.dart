// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import 'common/details_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navSettings),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  "${AppLocalizations.of(context)!.languageLabel} ",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DropdownButton<Locale>(
                  value: Provider.of<LocaleProvider>(context).locale,
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en', 'US'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: Locale('fr'),
                      child: Text('French'),
                    ),
                    DropdownMenuItem(
                      value: Locale('th'),
                      child: Text('Thai'),
                    ),
                    DropdownMenuItem(
                      value: Locale('ar'),
                      child: Text('Arabic'),
                    ),
                    DropdownMenuItem(
                      value: Locale.fromSubtags(languageCode: 'zh', countryCode: 'HK', scriptCode: 'Hant'),
                      child: Text('Chinese (Hong Kong)'),
                    ),
                    DropdownMenuItem(
                      value: Locale('ru', 'RU'),
                      child: Text('Russian'),
                    ),
                    DropdownMenuItem(
                      value: Locale('ko'),
                      child: Text('Korean'),
                    ),
                  ],
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      Provider.of<LocaleProvider>(context, listen: false)
                          .setLocale(newLocale, context);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                      const DetailsScreen(detail: "Settings Details"),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.navDetails),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
