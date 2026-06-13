import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Assembles the global [ThemeData] from the design tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.surface,
      splashColor: AppColors.primary.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
      textTheme: TextTheme(
        displayLarge: AppType.displayLarge,
        headlineLarge: AppType.h1,
        headlineMedium: AppType.h2,
        headlineSmall: AppType.h3,
        bodyLarge: AppType.bodyLarge,
        bodyMedium: AppType.body,
        bodySmall: AppType.caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(56), // large touch target
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppType.bodyLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x16,
          vertical: AppSpacing.x16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppType.body,
      ),
    );
  }

  /// Elevation tokens (Level 1-3) as reusable box shadows.
  static List<BoxShadow> get shadow1 => [
        const BoxShadow(
          color: Color(0x0F000000), // rgba(0,0,0,0.06)
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadow2 => [
        const BoxShadow(
          color: Color(0x14000000), // rgba(0,0,0,0.08)
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadow3 => [
        const BoxShadow(
          color: Color(0x1A000000), // rgba(0,0,0,0.10)
          blurRadius: 40,
          offset: Offset(0, 16),
        ),
      ];
}
