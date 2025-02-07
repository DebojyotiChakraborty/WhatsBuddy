import 'package:flutter/material.dart';

class AppTheme {
  static const String fontGeist = 'Geist';
  static const String fontGeistMono = 'GeistMono';

  // Light Theme Colors
  static const _primaryLight = Color.fromARGB(255, 0, 0, 0);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _backgroundLight = Color(0xFFF6F6F6);
  static const _textLight = Color(0xFF1A1A1A);
  static const _secondaryLight = Color.fromARGB(255, 0, 0, 0);
  static final _hintLight = const Color(0xFF1A1A1A).withOpacity(0.35);
  static final _secondaryTextLight = const Color(0xFF1A1A1A).withOpacity(0.6);

  // Dark Theme Colors
  static const _primaryDark = Color.fromARGB(255, 255, 255, 255);
  static const _surfaceDark = Color(0xFF232323);
  static const _backgroundDark = Color(0xFF171717);
  static const _textDark = Color(0xFFFFFFFF);
  static const _secondaryDark = Color.fromARGB(255, 255, 255, 255);
  static final _hintDark = const Color(0xFFFFFFFF).withOpacity(0.35);
  static final _secondaryTextDark = const Color(0xFFFFFFFF).withOpacity(0.54);

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
      textTheme: TextTheme(
        // Display styles
        displayLarge: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: _textLight,
        ),
        // Title styles
        titleLarge: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.5,
          color: _textLight,
        ),
        // Body styles
        bodyLarge: const TextStyle(
          fontFamily: fontGeistMono,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _textLight,
        ),
        bodyMedium: const TextStyle(
          fontFamily: fontGeistMono,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _textLight,
        ),
        // Label styles
        labelLarge: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textLight,
        ),
        labelMedium: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: _textLight,
        ),
        // Mono styles
        labelSmall: TextStyle(
          fontFamily: fontGeistMono,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _secondaryTextLight,
        ),
      ),
      // Additional text styles that aren't part of the standard textTheme
      extensions: [
        AppThemeExtension(
          hintStyle: TextStyle(
            fontFamily: fontGeistMono,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _hintLight,
            letterSpacing: -0.2,
          ),
          secondaryText: TextStyle(
            fontFamily: fontGeistMono,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _secondaryTextLight,
            height: 1.2,
          ),
          monoText: TextStyle(
            fontFamily: fontGeistMono,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _secondaryTextLight,
          ),
        ),
      ],
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
      textTheme: TextTheme(
        // Display styles
        displayLarge: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: _textDark,
        ),
        // Title styles
        titleLarge: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.5,
          color: _textDark,
        ),
        // Body styles
        bodyLarge: const TextStyle(
          fontFamily: fontGeistMono,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _textDark,
        ),
        bodyMedium: const TextStyle(
          fontFamily: fontGeistMono,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _textDark,
        ),
        // Label styles
        labelLarge: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
        labelMedium: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: _textDark,
        ),
        // Mono styles
        labelSmall: TextStyle(
          fontFamily: fontGeistMono,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _secondaryTextDark,
        ),
      ),
      // Additional text styles that aren't part of the standard textTheme
      extensions: [
        AppThemeExtension(
          hintStyle: TextStyle(
            fontFamily: fontGeistMono,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _hintDark,
            letterSpacing: -0.2,
          ),
          secondaryText: TextStyle(
            fontFamily: fontGeistMono,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _secondaryTextDark,
            height: 1.2,
          ),
          monoText: TextStyle(
            fontFamily: fontGeistMono,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _secondaryTextDark,
          ),
        ),
      ],
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

// Extension to add custom text styles to ThemeData
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final TextStyle hintStyle;
  final TextStyle secondaryText;
  final TextStyle monoText;

  AppThemeExtension({
    required this.hintStyle,
    required this.secondaryText,
    required this.monoText,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    TextStyle? hintStyle,
    TextStyle? secondaryText,
    TextStyle? monoText,
  }) {
    return AppThemeExtension(
      hintStyle: hintStyle ?? this.hintStyle,
      secondaryText: secondaryText ?? this.secondaryText,
      monoText: monoText ?? this.monoText,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t)!,
      secondaryText: TextStyle.lerp(secondaryText, other.secondaryText, t)!,
      monoText: TextStyle.lerp(monoText, other.monoText, t)!,
    );
  }
}
