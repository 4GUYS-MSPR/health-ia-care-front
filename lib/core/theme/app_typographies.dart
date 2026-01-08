import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypographies {
  // Google Fonts families names
  static const String _displayFont = 'Oxanium';
  static const String _headlineFont = 'Oxanium';
  static const String _titleFont = 'Inter';
  static const String _bodyFont = 'Inter';

  // Google Fonts TextTheme
  static final _displayTextTheme = GoogleFonts.getTextTheme(_displayFont);
  static final _headlineTextTheme = GoogleFonts.getTextTheme(_headlineFont);
  static final _titleTextTheme = GoogleFonts.getTextTheme(_titleFont);
  static final _bodyTextTheme = GoogleFonts.getTextTheme(_bodyFont);

  /// App composed TextTheme.
  static TextTheme get textTheme => _bodyTextTheme.copyWith(
    // Display
    displayLarge: _displayTextTheme.displayLarge,
    displayMedium: _displayTextTheme.displayMedium,
    displaySmall: _displayTextTheme.displaySmall,

    // Headline
    headlineLarge: _headlineTextTheme.headlineLarge,
    headlineMedium: _headlineTextTheme.headlineMedium,
    headlineSmall: _headlineTextTheme.headlineSmall,

    // Title
    titleLarge: _titleTextTheme.titleLarge,
    titleMedium: _titleTextTheme.titleMedium,
    titleSmall: _titleTextTheme.titleSmall,
  );
}
