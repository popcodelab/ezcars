// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr'); // Default locale is French
  Locale get locale => _locale;

  // List of supported locales
  final List<Locale> supportedLocales = const [
    Locale('en', 'US'),
    Locale('fr'),
    Locale('th'),
    Locale('ar'),
    Locale.fromSubtags(languageCode: 'zh', countryCode: 'HK', scriptCode: 'Hant'),
    Locale('ru', 'RU'),
    Locale('ko')
  ];

  // Method to set a new locale
  void setLocale(Locale locale, BuildContext context) {
    if (_isSupportedLocale(locale)) {
      if (_locale != locale) {
        _locale = locale;
        notifyListeners();
        // Show a SnackBar to notify user of the language change
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to ${locale.toLanguageTag()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unsupported locale: ${locale.toLanguageTag()}. Defaulting to English (US).'),
          duration: const Duration(seconds: 2),
        ),
      );
      _locale = const Locale('en', 'US');
      notifyListeners();
    }
  }

  // Method to reset to default locale
  void resetLocale(BuildContext context) {
    _locale = const Locale('en', 'US'); // Reset to default (English)
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Locale reset to English (US).'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Helper method to check if a locale is supported
  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.contains(locale);
  }
}
