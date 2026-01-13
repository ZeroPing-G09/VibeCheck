import 'package:flutter/material.dart';

/// ViewModel for managing settings such as theme mode.
class SettingsViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  /// Gets the current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Returns true if the current theme mode is dark.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggles the theme between dark and light modes.
  // ignore: avoid_positional_boolean_parameters
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Sets the theme mode to the specified [mode].
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
