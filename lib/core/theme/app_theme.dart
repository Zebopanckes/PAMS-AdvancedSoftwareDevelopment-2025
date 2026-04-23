// Author: Alec Brothwood (23076824) - Project Manager
// Author: Saynab Saleh (23000156) - System Analyst
// File: app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Professional & Energetic Color Palette
  // Dominant (60%) - Neutral white/light grey for maximum readability
  static const Color pureWhite = Color(0xFFFFFFFF);         // Primary background
  static const Color lightGrey = Color(0xFFF5F5F7);         // Secondary background
  static const Color softGrey = Color(0xFFE8E8EA);          // Elevated surfaces
  static const Color borderGrey = Color(0xFFD1D1D6);        // Borders & dividers
  
  // Secondary (30%) - Calm mid-range blue for clarity and reliability
  static const Color calmBlue = Color(0xFF2563EB);          // Primary blue
  static const Color midBlue = Color(0xFF3B82F6);           // Interactive elements
  static const Color lightBlue = Color(0xFF60A5FA);         // Hover states
  static const Color paleBlue = Color(0xFFDCEAFE);          // Blue backgrounds
  
  // Accent (10%) - Vibrant yellow/orange for warmth and excitement
  static const Color vibrantYellow = Color(0xFFFBBF24);     // Primary accent
  static const Color brightOrange = Color(0xFFF97316);      // Secondary accent
  static const Color warmOrange = Color(0xFFFF8C42);        // Highlights
  static const Color paleYellow = Color(0xFFFEF3C7);        // Yellow backgrounds
  
  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);       // Primary text (dark grey)
  static const Color textSecondary = Color(0xFF6B7280);     // Secondary text (medium grey)
  static const Color textMuted = Color(0xFF9CA3AF);         // Disabled/muted text
  static const Color textOnBlue = Color(0xFFFFFFFF);        // Text on blue backgrounds
  
  // Semantic colors
  static const Color successGreen = Color(0xFF10B981);      // Success states
  static const Color errorRed = Color(0xFFEF4444);          // Errors
  static const Color warningAmber = Color(0xFFF59E0B);      // Warnings

  // Light Theme (Professional & Energetic Design)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: calmBlue,
      secondary: vibrantYellow,
      tertiary: brightOrange,
      error: errorRed,
      surface: pureWhite,
      onPrimary: textOnBlue,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onError: textOnBlue,
    ),
    scaffoldBackgroundColor: lightGrey,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: calmBlue,
      foregroundColor: textOnBlue,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textOnBlue,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: textOnBlue),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: pureWhite,
      shadowColor: Colors.black.withValues(alpha: 0.08),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: calmBlue,
        foregroundColor: textOnBlue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: calmBlue,
        side: const BorderSide(color: calmBlue, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: vibrantYellow,
      foregroundColor: textPrimary,
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: pureWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: calmBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
      bodySmall: TextStyle(fontSize: 12, color: textSecondary),
    ),
    iconTheme: const IconThemeData(
      color: calmBlue,
      size: 24,
    ),
    dividerColor: borderGrey,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(color: textOnBlue),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Dark Theme (same as light for consistency)
  static ThemeData darkTheme = lightTheme;
}
