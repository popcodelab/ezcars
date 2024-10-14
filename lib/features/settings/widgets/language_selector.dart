import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../providers/locale_provider.dart';

/// LanguageSelector is responsible for displaying and handling language changes.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${AppLocalizations.of(context)!.languageLabel.capitalize()}: ', // Localized "Language"
                style: const TextStyle(fontSize: 18),
              ),
              DropdownButton<Locale>(
                value: Provider.of<LocaleProvider>(context).locale, // Current locale
                items: const [
                  DropdownMenuItem(
                    value: Locale('en', 'US'),
                    child: Text('English'), // English option
                  ),
                  DropdownMenuItem(
                    value: Locale('fr'),
                    child: Text('French'), // French option
                  )
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    Provider.of<LocaleProvider>(context, listen: false).setLocale(newLocale);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context)!.language_changed_to.capitalize()} ${newLocale.toLanguageTag()}'.capitalize(),
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
              // Reset language to English US
              Provider.of<LocaleProvider>(context, listen: false).resetLocale();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppLocalizations.of(context)!.language_reset.capitalize()}: '),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text('${AppLocalizations.of(context)!.language_reset.capitalize()}: '), // Button label
          ),
        ],
      ),
    );
  }
}
