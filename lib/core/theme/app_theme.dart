import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryLight = Color(0xFF1A1A1A);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _backgroundLight = Color(0xFFF5F5F5);

  static const _primaryDark = Color(0xFFFFFFFF);
  static const _surfaceDark = Color(0xFF1A1A1A);
  static const _backgroundDark = Color(0xFF000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: _surfaceLight,
        secondary: _primaryLight,
        onSecondary: _surfaceLight,
        surface: _surfaceLight,
        onSurface: _primaryLight,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w700,
          color: _primaryLight,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          color: _primaryLight,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          color: _primaryLight,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          color: _primaryLight,
        ),
        labelLarge: TextStyle(
          fontFamily: 'GeistMono',
          fontWeight: FontWeight.w400,
          color: _primaryLight,
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: _surfaceDark,
        secondary: _primaryDark,
        onSecondary: _surfaceDark,
        surface: _surfaceDark,
        onSurface: _primaryDark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w700,
          color: _primaryDark,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          color: _primaryDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          color: _primaryDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          color: _primaryDark,
        ),
        labelLarge: TextStyle(
          fontFamily: 'GeistMono',
          fontWeight: FontWeight.w400,
          color: _primaryDark,
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryDark,
      ),
    );
  }
}
