import 'package:flutter/material.dart';

/// Utility for generating a complete [ThemeData] from
/// a [TextTheme] and a [ColorScheme].
class ThemeBuilder {
  /// Text theme used by the generated theme.
  final TextTheme textTheme;

  /// Creates an instance of [ThemeBuilder] with the given [TextTheme].
  ThemeBuilder(this.textTheme);

  /// Builds a [ThemeData] by applying the given [ColorScheme].
  /// Text colors are automatically adapted to the provided palette.
  ThemeData build(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true, // Enables Material 3 (recommended)
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
    );
  }
}
