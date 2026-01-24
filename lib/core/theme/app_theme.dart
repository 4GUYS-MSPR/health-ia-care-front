import 'package:flutter/material.dart';

import 'app_color_schemes.dart';
import 'app_typographies.dart';
import 'theme_builder.dart';

/// Provides the main application themes (light and dark).
///
/// Use [AppTheme.light] or [AppTheme.dark] as the theme in your Flutter app.
/// Example:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
class AppTheme {
  static final _textTheme = AppTypographies.textTheme;
  static final ThemeBuilder themeBuilder = ThemeBuilder(_textTheme);

  /// Light theme based on the app's color schemes and typographies.
  static ThemeData get light {
    return themeBuilder.build(AppColorSchemes.lightScheme);
  }

  /// Medium-contrast light theme based on the app's color schemes and typographies.
  static ThemeData get lightMediumContrast {
    return themeBuilder.build(AppColorSchemes.lightMediumContrastScheme);
  }

  /// High-contrast light theme based on the app's color schemes and typographies.
  static ThemeData get lightHighContrast {
    return themeBuilder.build(AppColorSchemes.lightHighContrastScheme);
  }

  /// Dark theme based on the app's color schemes and typographies.
  static ThemeData get dark {
    return themeBuilder.build(AppColorSchemes.darkScheme);
  }

  /// Medium-contrast dark theme based on the app's color schemes and typographies.
  static ThemeData get darkMediumContrast {
    return themeBuilder.build(AppColorSchemes.darkMediumContrastScheme);
  }

  /// High-contrast dark theme based on the app's color schemes and typographies.
  static ThemeData get darkHighContrast {
    return themeBuilder.build(AppColorSchemes.darkHighContrastScheme);
  }

  List<ExtendedColor> get extendedColors => [];
}
