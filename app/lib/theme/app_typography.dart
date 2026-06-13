import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale from `design.md`. Poppins (bundled asset, offline-safe).
class AppType {
  AppType._();

  static const String fontFamily = 'Poppins';

  static TextStyle _p(double size, FontWeight w, double height,
          {Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: w,
        height: height / size,
        color: color,
      );

  static TextStyle get displayLarge => _p(40, FontWeight.w700, 48);
  static TextStyle get h1 => _p(32, FontWeight.w700, 40);
  static TextStyle get h2 => _p(24, FontWeight.w600, 32);
  static TextStyle get h3 => _p(20, FontWeight.w600, 28);
  static TextStyle get bodyLarge => _p(16, FontWeight.w500, 24);
  static TextStyle get body =>
      _p(14, FontWeight.w400, 22, color: AppColors.textSecondary);
  static TextStyle get caption =>
      _p(12, FontWeight.w400, 18, color: AppColors.textSecondary);

  /// Financial values — ₹12,450 / $2,500.
  static TextStyle financial({Color color = AppColors.textPrimary}) =>
      _p(28, FontWeight.w700, 34, color: color);
}
