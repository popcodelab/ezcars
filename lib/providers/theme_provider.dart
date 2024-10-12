// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default theme mode is system

  ThemeMode get themeMode => _themeMode;

  // Method to set a new theme
  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners(); // Notify listeners when the theme changes
  }

  // Method to reset to system default theme
  void resetTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
