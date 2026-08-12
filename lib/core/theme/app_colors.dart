import 'package:flutter/material.dart';

/// Fixed semantic color tokens for the JARA design system.
///
/// Grayscale-at-rest: amber = warning, red = error/delete.
/// No green anywhere. Accent comes from the active theme.
class AppColors {
  AppColors._();

  // Semantic colors — fixed across all themes
  static const warning = Color(0xFFD97706); // Amber
  static const error = Color(0xFFDC2626); // Red

  // Accent is theme-dependent — set via AppTheme
  static const lightAccent = Color(0xFF2563EB); // Blue
  static const darkAccent = Color(0xFF60A5FA); // Lighter blue
  static const slateAccent = Color(0xFF64748B); // Slate
  static const oceanAccent = Color(0xFF0EA5E9); // Ocean blue

  // Grayscale palette (light theme)
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);
}
