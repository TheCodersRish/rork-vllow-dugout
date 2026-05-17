import 'package:flutter/material.dart';

class AppTheme {
  static const neonGreen = Color.fromRGBO(57, 255, 20, 1);
  static const darkBg = Color.fromRGBO(18, 18, 15, 1);
  static const cardSurface = Color.fromRGBO(31, 31, 28, 1);
  static const cardSurfaceLight = Color.fromRGBO(41, 41, 38, 1);
  static const textPrimary = Colors.white;
  static const textSecondary = Color.fromRGBO(140, 140, 140, 1);
  static const textTertiary = Color.fromRGBO(89, 89, 89, 1);
  static const border = Color.fromRGBO(46, 46, 46, 1);
  static final neonGreenDim = neonGreen.withOpacity(0.15);
  static const goldAccent = Color.fromRGBO(217, 166, 33, 1);

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        surface: cardSurface,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonGreen, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        bodySmall: TextStyle(color: textTertiary),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      ),
      dividerColor: border,
      useMaterial3: true,
    );
  }
}
