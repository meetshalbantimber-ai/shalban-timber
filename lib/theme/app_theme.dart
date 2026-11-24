import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryGreen = Color(0xFF2E5A36);
  static const Color primaryDarkGreen = Color(0xFF1E3E24);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color warmSurface = Color(0xFFEEEAE0);
  static const Color inkDark = Color(0xFF1A241C);
  static const Color inkMuted = Color(0xFF5A655C);
  static const Color hairlineBorder = Color(0xFFDAD4C7);

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      onPrimary: warmCream,
      secondary: primaryDarkGreen,
      onSecondary: warmCream,
      surface: warmCream,
      onSurface: inkDark,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: warmCream,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: warmSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: warmCream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: inkDark,
        contentTextStyle: const TextStyle(color: warmCream, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
