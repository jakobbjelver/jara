import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Sealed class representing all available themes in JARA.
sealed class AppTheme {
  const AppTheme._();

  static const light = LightTheme();
  static const dark = DarkTheme();
  static const slate = NamedTheme(
    name: 'Slate',
    accentColor: AppColors.slateAccent,
  );
  static const ocean = NamedTheme(
    name: 'Ocean',
    accentColor: AppColors.oceanAccent,
  );

  /// All themes in cycle order.
  static const values = [light, dark, slate, ocean];

  String get displayName;
  Color get accentColor;
  bool get isDark;
  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;

  ThemeData toThemeData() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: brightness,
      surface: isDark ? AppColors.gray900 : AppColors.gray50,
    );

    // Grayscale-at-rest: override the color scheme to be fundamentally grayscale.
    // Accent is used sparingly (selected tabs, active buttons, focused inputs).
    final grayscaleScheme = colorScheme.copyWith(
      primary: accentColor,
      onPrimary: isDark ? Colors.black : Colors.white,
      secondary: accentColor.withValues(alpha: 0.7),
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.gray900 : Colors.white,
      onSurface: isDark ? AppColors.gray100 : AppColors.gray900,
      onSurfaceVariant: isDark ? AppColors.gray400 : AppColors.gray500,
      outline: isDark ? AppColors.gray700 : AppColors.gray300,
      outlineVariant: isDark ? AppColors.gray800 : AppColors.gray200,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: grayscaleScheme,
      brightness: brightness,
      scaffoldBackgroundColor: grayscaleScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: grayscaleScheme.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading3(
          _dummyContext(isDark),
        ).copyWith(color: grayscaleScheme.onSurface),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentColor,
        unselectedLabelColor: grayscaleScheme.onSurfaceVariant,
        indicatorColor: accentColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: grayscaleScheme.surface,
        selectedItemColor: accentColor,
        unselectedItemColor: grayscaleScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.gray800 : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: grayscaleScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.gray800 : AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: grayscaleScheme.outlineVariant,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: grayscaleScheme.onSurface,
          side: BorderSide(color: grayscaleScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentColor),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
    );
  }

  /// Minimal context for text style resolution during theme construction.
  static BuildContext _dummyContext(bool isDark) {
    // This is only used for text style resolution. The actual context
    // will be provided by the widget tree at runtime.
    throw UnimplementedError('Use Theme.of(context) instead');
  }
}

class LightTheme extends AppTheme {
  const LightTheme() : super._();

  @override
  String get displayName => 'Light';

  @override
  Color get accentColor => AppColors.lightAccent;

  @override
  bool get isDark => false;
}

class DarkTheme extends AppTheme {
  const DarkTheme() : super._();

  @override
  String get displayName => 'Dark';

  @override
  Color get accentColor => AppColors.darkAccent;

  @override
  bool get isDark => true;
}

class NamedTheme extends AppTheme {
  const NamedTheme({required this.name, required this._accentColor})
    : super._();

  final String name;
  final Color _accentColor;

  @override
  String get displayName => name;

  @override
  Color get accentColor => _accentColor;

  @override
  bool get isDark => false;

  @override
  bool operator ==(Object other) => other is NamedTheme && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
