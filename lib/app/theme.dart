import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5B98E5);
  static const Color accent = Color(0xFFFFA62B);
  static const Color background = Color(0xFF15191E);
  static const Color surface = Color(0xFF1E232A);
  static const Color input = Color(0xFF161A1F);
  static const Color border = Color(0xFF303842);
  static const Color textPrimary = Color(0xFFF7F9FC);
  static const Color textSecondary = Color(0xFFAAB8CC);
  static const Color success = Color(0xFF6BCB77);
  static const Color warning = Color(0xFFE9B949);
  static const Color error = Color(0xFFE96B6B);
}

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = _buildTheme(Brightness.dark);
  static final ThemeData lightTheme = _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? AppColors.background : const Color(0xFFF7F9FC);
    final surface = isDark ? AppColors.surface : Colors.white;
    final input = isDark ? AppColors.input : const Color(0xFFF9FAFC);
    final primaryText = isDark
        ? AppColors.textPrimary
        : const Color(0xFF1E293B);
    final secondaryText = isDark
        ? AppColors.textSecondary
        : const Color(0xFF64748B);

    final textTheme = GoogleFonts.interTextTheme().copyWith(
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: primaryText),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: secondaryText),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        surface: surface,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: secondaryText,
        ),
        hintStyle: GoogleFonts.inter(color: secondaryText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
