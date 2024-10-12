// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US'); // Default locale

  Locale get locale => _locale;

  // List of supported locales
  final List<Locale> supportedLocales = const [
    Locale('en', 'US'),
    Locale('fr'),
    Locale('th'),
    Locale('ar'),
    Locale.fromSubtags(languageCode: 'zh', countryCode: 'HK', scriptCode: 'Hant'),
    Locale('ru', 'RU'),
    Locale('ko'),
  ];

  // Set a new locale and notify listeners
  void setLocale(Locale locale) {
    if (_isSupportedLocale(locale)) {
      _locale = locale;
      notifyListeners(); // Notify listeners when locale changes
    }
  }

  // Reset to default locale and notify listeners
  void resetLocale() {
    _locale = const Locale('en', 'US'); // Reset to English (US)
    notifyListeners();
  }

  // Check if the locale is supported
  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.contains(locale);
  }
}
