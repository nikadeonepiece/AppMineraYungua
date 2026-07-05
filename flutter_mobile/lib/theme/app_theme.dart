import 'package:flutter/material.dart';

/// Alineado con web: `web/src/config/branding.ts`
class AppBranding {
  static const name = 'Comunidad Campesina Chuyugual';
  static const logoAsset = 'assets/branding/LogoChuyugual.png';
  static const primary = Color(0xFF123D73);
  static const accent = Color(0xFF2F9A46);
  static const background = Color(0xFFF9FAFB);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppBranding.primary,
      primary: AppBranding.primary,
      secondary: AppBranding.accent,
      surface: Colors.white,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppBranding.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppBranding.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppBranding.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppBranding.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
