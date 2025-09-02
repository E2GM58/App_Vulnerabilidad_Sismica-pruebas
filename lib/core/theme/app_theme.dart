import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );

    final textTheme = GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.roboto(fontWeight: FontWeight.w700), // Bold
      titleMedium: GoogleFonts.roboto(fontWeight: FontWeight.w500), // Medium
      bodyMedium: GoogleFonts.roboto(fontWeight: FontWeight.w400), // Regular
      labelLarge: GoogleFonts.roboto(fontWeight: FontWeight.w600), // Semibold
    );

    return base.copyWith(
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray300.withValues(alpha: 0.5),
        hintStyle: const TextStyle(color: AppColors.gray500),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.text,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.gray500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: AppColors.text,
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
