import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color cardBg = Color(0xFF1B1B2F);
  static const Color primaryGold = Color(0xFFFFD700); // Vàng gold sang trọng
  static const Color secondaryAmber = Color(0xFFFF8C00); // Amber neon ấm áp
  static const Color accentNeonGreen = Color(0xFF39FF14); // Trạng thái Trống (vacant)
  static const Color accentNeonRed = Color(0xFFFE015B); // Trạng thái Đang có khách (occupied)
  static const Color textMain = Color(0xFFF5F5FA);
  static const Color textMuted = Color(0xFF8A8A9E);
  static const Color borderStroke = Color(0xFF2C2C4E);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: secondaryAmber,
        surface: cardBg,
        error: accentNeonRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryGold,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: primaryGold),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderStroke, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: darkBg,
          elevation: 6,
          shadowColor: primaryGold.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: primaryGold, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        headlineMedium: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textMain),
        bodyMedium: TextStyle(color: textMuted),
      ),
    );
  }
}
