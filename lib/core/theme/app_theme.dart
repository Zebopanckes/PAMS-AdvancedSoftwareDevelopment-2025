import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Nature-Inspired Earth Tones
  // Primary colors for main UI elements
  static const Color hunterGreen = Color(0xFF386641);      // Deep forest green - primary actions
  static const Color asparagus = Color(0xFF6A994E);         // Medium green - secondary elements
  static const Color yellowGreen = Color(0xFFA7C957);       // Light green - accents & highlights
  static const Color parchment = Color(0xFFF2E8CF);         // Warm cream - backgrounds
  static const Color bittersweetShimmer = Color(0xFFBC4749); // Warm red - errors & warnings
  
  // Semantic color assignments for app usage
  static const Color primaryColor = hunterGreen;            // Main brand color
  static const Color secondaryColor = asparagus;            // Supporting actions
  static const Color accentColor = yellowGreen;             // Highlights & emphasis
  static const Color errorColor = bittersweetShimmer;       // Errors & critical actions
  static const Color successColor = asparagus;              // Success states
  static const Color warningColor = Color(0xFFD4A574);      // Derived warm tone for warnings
  static const Color backgroundColor = parchment;           // Main background
  static const Color surfaceColor = Color(0xFFFFFBF5);      // Card/surface background (lighter parchment)
  static const Color textPrimary = hunterGreen;             // Primary text
  static const Color textSecondary = asparagus;             // Secondary text

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: surfaceColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
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
  );

  // Dark Theme with nature-inspired colors
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: yellowGreen,
      secondary: asparagus,
      tertiary: yellowGreen,
      error: bittersweetShimmer,
      surface: Color(0xFF1A2D1F),              // Dark green-tinted surface
      background: Color(0xFF0F1810),           // Very dark green background
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1810),
  );
}
