import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for managing theme settings.
class ThemeViewModel extends ChangeNotifier {

  /// Creates a [ThemeViewModel] and loads the saved theme preference.
  ThemeViewModel() {
    _loadTheme();
  }
  bool _isDarkMode = true; // Default to dark mode

  /// Returns true if dark mode is enabled.
  bool get isDarkMode => _isDarkMode;

  /// Toggles the theme between dark and light modes and saves the preference.
  // ignore: avoid_positional_boolean_parameters
  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }
}
