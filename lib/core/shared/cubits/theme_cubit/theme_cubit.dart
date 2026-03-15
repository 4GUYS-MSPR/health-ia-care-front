import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../logging/logger_mixin.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> with LoggerMixin {
  @override
  String get loggerName => 'Core.Shared.Cubits.ThemeCubit';

  ThemeCubit() : super(ThemeMode.system) {
    logger.info('ThemeCubit initialized with mode: ${state.name}');
  }

  /// Get the actual system [Brightness].
  Brightness get systemBrightness {
    final platformBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
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

    logger.fine(
      'Next theme mode called - current: ${prev.name}, system brightness: ${brightness.name}',
    );

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

    logger.info('Theme mode changed from ${prev.name} to ${next.name}');
    emit(next);
  }

  /// Set the cubit [ThemeMode] to the selected [ThemeMode].
  void selectThemeMode(ThemeMode themeMode) {
    logger.info('Theme mode selected: ${themeMode.name}');
    emit(themeMode);
  }

  /// Toggle the cubit [ThemeMode] between [ThemeMode.light] and [ThemeMode.dark].
  ///
  /// Set the cubit [ThemeMode] to system brightness opposite when toggling from [ThemeMode.system].
  void toggleThemeMode() {
    final prev = state;

    logger.fine('Toggle theme mode called - current: ${prev.name}');

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

    logger.info('Theme mode toggled from ${prev.name} to ${next.name}');
    emit(next);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final index = json['theme_mode'] as int?;
    ThemeMode restored;
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      restored = ThemeMode.values[index];
      logger.fine('Theme mode restored from storage: ${restored.name}');
    } else {
      restored = ThemeMode.system;
      logger.warning(
        'Invalid theme mode index in storage, defaulting to system',
      );
    }
    return restored;
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    logger.fine('Persisting theme mode to storage: ${state.name}');
    return {'theme_mode': state.index};
  }
}
