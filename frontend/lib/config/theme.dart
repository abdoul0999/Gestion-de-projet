import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primaryDark = Color(0xFF1B3F70);
  static const primaryMid = Color(0xFF1A5FA0);
  static const primaryLight = Color(0xFF42A5F5);
  static const accent = Color(0xFF2196F3);
  static const background = Color(0xFFF4F9FF);
  static const backgroundAlt = Color(0xFFEDF4FC);
  static const cardBorder = Color(0xFFC5DDF0);
  static const inputBg = Color(0xFFEFF6FF);
  static const inputBorder = Color(0xFFB8D4ED);
  static const textDark = Color(0xFF0A1628);
  static const textMid = Color(0xFF2A3D50);
  static const textLight = Color(0xFF7090A8);
  static const textMuted = Color(0xFF9BB5C8);
  static const success = Color(0xFF2E7D32);
  static const successBg = Color(0xFFE8F5E9);
  static const error = Color(0xFFC62828);
  static const errorBg = Color(0xFFFFEBEE);
  static const warning = Color(0xFFE65100);
  static const warningBg = Color(0xFFFFF3E0);
  static const navBg = Color(0xFF0A1830);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
    ),
  );
}
