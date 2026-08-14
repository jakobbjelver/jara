import 'package:flutter/material.dart';

/// Typography scale for JARA.
///
/// Uses the system font stack (SF Pro on iOS, Roboto on Android).
/// No decorative fonts.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(fontSize: 32, fontWeight: FontWeight.w700);
  }

  static TextStyle heading2(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  }

  static TextStyle heading3(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  }

  static TextStyle body(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
  }

  static TextStyle bodySmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
  }

  static TextStyle caption(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ) ??
        const TextStyle(fontSize: 12);
  }

  /// Large numerical display for run stats (elapsed time, distance, pace).
  static TextStyle runStat(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w300,
      letterSpacing: -1,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: theme.colorScheme.onSurface,
    );
  }

  /// Medium numerical display for secondary stats.
  static TextStyle runStatSecondary(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }
}
