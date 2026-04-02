import 'package:flutter/material.dart';
class AppColors {
  static const bgDeep = Color(0xFF0E0E14);
  static const bgCard = Color(0xFF1A1A26);
  static const bgCardBorder = Color(0xFF2E2E42);
  static const primary = Color(0xFF534AB7);
  static const accent = Color(0xFF7F77DD);
  static const accentLight = Color(0xFFAFA9EC);
  static const accentDark = Color(0xFF26215C);
  static const online = Color(0xFF1D9E75);
  static const onlineDark = Color(0xFF04342C);
  static const textPrimary = Color(0xFFE8E6F0);
  static const textSecondary = Color(0xFF9997B0);
  static const textMuted = Color(0xFF5F5E7A);
}
class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true, brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeep,
    colorScheme: const ColorScheme.dark(primary: AppColors.primary, secondary: AppColors.accent, surface: AppColors.bgCard),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.bgDeep, foregroundColor: AppColors.textPrimary, elevation: 0, centerTitle: false),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.accentLight, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.bgCard, labelStyle: const TextStyle(color: AppColors.textMuted), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.bgCardBorder, width: .5)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.bgCardBorder, width: .5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1))),
  );
}
