import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// Get the actual system [Brightness].
  Brightness get systemBrightness {
    final platformBrightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return platformBrightness;
  }

  /// Go to the next [ThemeMode] depending on the system brightness
  ///
  /// Order:
  /// - system light: system - dark - light
  /// - system dark: system - light - dark
  void nextThemeMode() {
    final brightness = systemBrightness;
    final prev = state;
    ThemeMode next;

    switch (brightness) {
      case Brightness.dark:
        switch (prev) {
          case ThemeMode.system:
            next = ThemeMode.light;
            break;
          case ThemeMode.light:
            next = ThemeMode.dark;
            break;
          case ThemeMode.dark:
            next = ThemeMode.system;
            break;
        }
        break;

      case Brightness.light:
        switch (prev) {
          case ThemeMode.system:
            next = ThemeMode.dark;
            break;
          case ThemeMode.dark:
            next = ThemeMode.light;
            break;
          case ThemeMode.light:
            next = ThemeMode.system;
            break;
        }
        break;
    }

    emit(next);
  }

  /// Set the cubit [ThemeMode] to the selected [ThemeMode].
  void selectThemeMode(ThemeMode themeMode) {
    emit(themeMode);
  }

  /// Toggle the cubit [ThemeMode] between [ThemeMode.light] and [ThemeMode.dark].
  ///
  /// Set the cubit [ThemeMode] to system brightness opposite when toggling from [ThemeMode.system].
  void toggleThemeMode() {
    final prev = state;

    ThemeMode next;
    Brightness? brightness;
    switch (prev) {
      case ThemeMode.system:
        brightness = systemBrightness;
        next = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
        break;
      case ThemeMode.light:
        next = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        next = ThemeMode.light;
        break;
    }
    emit(next);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final index = json['theme_mode'] as int?;
    ThemeMode restored;
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      restored = ThemeMode.values[index];
    } else {
      restored = ThemeMode.system;
    }
    return restored;
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'theme_mode': state.index};
  }
}
