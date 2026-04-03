import 'package:flutter/material.dart';

class AppTheme {
  // Professional Corporate Color Palette
  static const Color primaryColor = Color(0xFF0F3A7D); // Deep Corporate Blue
  static const Color secondaryColor = Color(0xFF1A5490); // Medium Blue
  static const Color accentColor = Color(0xFF2E7DC0); // Light Blue
  static const Color successColor = Color(0xFF2D8659); // Professional Green
  static const Color errorColor = Color(0xFFD32F2F); // Corporate Red
  static const Color warningColor = Color(0xFFF57C00); // Corporate Orange

  // Background Colors
  static const Color darkBg = Color(0xFF0A1929);
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFF0F0F0);
  static const Color textGrey = Color(0xFF757575);
  static const Color textMuted = Color(0xFFA0A0A0);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textDark,
            letterSpacing: 0.2,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          titleLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          bodyLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textDark,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textGrey,
            height: 1.4,
          ),
          labelMedium: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: primaryColor,
            letterSpacing: 0.1,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 1,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          hintStyle: const TextStyle(
            fontSize: 12,
            color: textMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
          ),
          shadowColor: Colors.black.withOpacity(0.08),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF162446),
          foregroundColor: textLight,
          elevation: 2,
        ),
      );
}
