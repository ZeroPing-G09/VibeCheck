import 'package:flutter/material.dart';

class AppTheme {
  // APP COLORS:
  static const Color primary = Color(0xFF3388FF);
  // Dark mode
  static const Color text = Color(0xFFFEFEFE);
  static const Color bg = Color(0xFF1E1E1E);
  static const Color bgDarker = Color(0xFF121212);
  // Light mode
  static const Color lightText = Color(0xFF080808);
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color lightBgDarker = Color(0xFFE1E1E1);

  // Theme instances
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppTheme.lightBg,
    primaryColor: AppTheme.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppTheme.lightBgDarker,
      foregroundColor: AppTheme.lightText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppTheme.lightText),
    ),
    iconTheme: const IconThemeData(color: AppTheme.lightText),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppTheme.bg,
    primaryColor: AppTheme.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppTheme.bgDarker,
      foregroundColor: AppTheme.text,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppTheme.text),
    ),
    iconTheme: const IconThemeData(color: AppTheme.text),
  );
}
