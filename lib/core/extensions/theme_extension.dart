import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  ColorScheme get colorScheme => ColorScheme.of(this);
  TextTheme get textTheme => TextTheme.of(this);
}
