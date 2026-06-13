import 'package:flutter/material.dart';

/// Color system — mirrors `design.md` exactly.
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFFA8B9FF); // Primary Blue
  static const Color primaryDark = Color(0xFF8EA1FF); // Hover / pressed

  // Surfaces
  static const Color secondary = Color(0xFFF7F8FC); // card / section bg
  static const Color surface = Color(0xFFFFFFFF); // main background

  // Text
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6E6E73);

  // Semantic
  static const Color success = Color(0xFF34C759); // settled / positive
  static const Color warning = Color(0xFFFF9F0A); // budget alerts
  static const Color error = Color(0xFFFF453A); // negative / failed OCR

  // AI
  static const Color aiAccent = Color(0xFFB7C3FF);
  static const Color aiBubble = Color(0xFFEEF2FF); // AI message card bg

  // Extra pastels used for budget / category chips (kept on-palette).
  static const Color food = Color(0xFFFFD8A8);
  static const Color travel = Color(0xFFA8E6CF);
  static const Color entertainment = Color(0xFFFFC2D1);
  static const Color shopping = Color(0xFFD0BFFF);

  static const Color border = Color(0xFFECEEF5);
}
