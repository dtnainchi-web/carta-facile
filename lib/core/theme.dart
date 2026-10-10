import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colors — same palette as the approved screen designs.
class AppColors {
  static const primary = Color(0xFF1C4E80); // deep blue: trust
  static const primaryDark = Color(0xFF123758);
  static const primarySoft = Color(0xFFE7EEF6);
  static const accent = Color(0xFFF2A93B); // amber: main actions, alerts
  static const accentSoft = Color(0xFFFDF1DE);
  static const accentText = Color(0xFF5C3606);
  static const success = Color(0xFF2E7D5B);
  static const successSoft = Color(0xFFE9F4EE);
  static const ink = Color(0xFF0E1B2C);
  static const muted = Color(0xFF5A6575);
  static const line = Color(0xFFE6E9EE);
  static const ground = Color(0xFFF5F6F8);
  static const surface = Colors.white;
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.ground,
  );

  final text = GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme).apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(44, 52),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primarySoft,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return text.labelSmall?.copyWith(
          color: selected ? AppColors.primary : AppColors.muted,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? AppColors.primary : AppColors.muted);
      }),
    ),
  );
}

/// Amber call-to-action button used for the most important action on a screen.
ButtonStyle accentButtonStyle(BuildContext context) => FilledButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.ink,
      minimumSize: const Size.fromHeight(64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
