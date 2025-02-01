import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const _primaryLight = Color.fromARGB(255, 0, 0, 0); // WhatsApp green
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _backgroundLight = Color(0xFFF5F5F5);
  static const _textLight = Color(0xFF1A1A1A);
  static const _secondaryLight =
      Color.fromARGB(255, 0, 0, 0); // WhatsApp dark green

  // Dark Theme Colors
  static const _primaryDark = Color.fromARGB(255, 255, 255, 255);
  static const _surfaceDark = Color(0xFF1A1A1A);
  static const _backgroundDark = Color(0xFF000000);
  static const _textDark = Color(0xFFFFFFFF);
  static const _secondaryDark = Color.fromARGB(255, 255, 255, 255);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: _surfaceLight,
        secondary: _secondaryLight,
        onSecondary: _surfaceLight,
        surface: _surfaceLight,
        onSurface: _textLight,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: _textLight,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: _textLight,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: _textLight,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: _textLight,
        ),
        labelLarge: TextStyle(
          fontFamily: 'GeistMono',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: _textLight,
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryLight,
        size: 24,
      ),
      cardTheme: CardTheme(
        color: _surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _textLight.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _textLight.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryLight),
        ),
        labelStyle: TextStyle(color: _textLight.withOpacity(0.6)),
        hintStyle: TextStyle(color: _textLight.withOpacity(0.4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: _surfaceLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
        secondary: _secondaryDark,
        onSecondary: _surfaceDark,
        surface: _surfaceDark,
        onSurface: _textDark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: _textDark,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: _textDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: _textDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: _textDark,
        ),
        labelLarge: TextStyle(
          fontFamily: 'GeistMono',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: _textDark,
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryDark,
        size: 24,
      ),
      cardTheme: CardTheme(
        color: _surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _textDark.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _textDark.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryDark),
        ),
        labelStyle: TextStyle(color: _textDark.withOpacity(0.6)),
        hintStyle: TextStyle(color: _textDark.withOpacity(0.4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: _surfaceDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
