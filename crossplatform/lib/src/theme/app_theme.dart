import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF10B981),
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      onBackground: Color(0xFF0F172A),
      onSurface: Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF0F172A),
      elevation: 1,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF10B981),
      background: Color(0xFF0F172A),
      surface: Color(0xFF1E293B),
      onBackground: Color(0xFFF8FAFC),
      onSurface: Color(0xFFF8FAFC),
      error: Color(0xFFEF4444),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Color(0xFFF8FAFC),
      elevation: 1,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1E293B),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF334155),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
  );

  // SCADA-specific colors
  static const Color criticalColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color normalColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);
  
  static const Color npsColor = Color(0xFF3B82F6);      // НПС - синий
  static const Color tankColor = Color(0xFF10B981);     // Резервуар - зеленый
  static const Color pumpColor = Color(0xFF8B5CF6);     // Насос - фиолетовый
  static const Color valveColor = Color(0xFFF59E0B);    // Клапан - оранжевый
  static const Color sensorColor = Color(0xFF06B6D4);   // Датчик - голубой

  // Text styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0xFFCBD5E1),
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF94A3B8),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Color(0xFF64748B),
  );

  // Severity text styles
  static TextStyle severityCritical = const TextStyle(
    color: criticalColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle severityWarning = const TextStyle(
    color: warningColor,
    fontWeight: FontWeight.w600,
  );

  static TextStyle severityNormal = const TextStyle(
    color: normalColor,
    fontWeight: FontWeight.w600,
  );

  // Platform-specific spacing
  static double getHorizontalPadding(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1200) {
      return 48.0; // Large desktop
    } else if (MediaQuery.of(context).size.width > 768) {
      return 24.0; // Tablet/desktop
    } else {
      return 16.0; // Mobile
    }
  }

  static double getCardPadding(BuildContext context) {
    if (MediaQuery.of(context).size.width > 768) {
      return 24.0;
    } else {
      return 16.0;
    }
  }

  // Responsive breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1440;
}