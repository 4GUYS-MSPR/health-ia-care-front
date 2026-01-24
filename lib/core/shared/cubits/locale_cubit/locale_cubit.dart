import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../logging/logger_mixin.dart';
import '../../../utils/locale_utils.dart';

class LocaleCubit extends HydratedCubit<Locale?> with LoggerMixin {
  @override
  String get loggerName => 'Core.Shared.Cubits.LocaleCubit';

  LocaleCubit() : super(LocaleUtils.findBestSupportedLocale()) {
    final locale = state;
    logger.info(
      'LocaleCubit initialized with locale: ${locale?.toLanguageTag() ?? "null"}',
    );
  }

  /// Sets the locale for the application.
  ///
  /// If [locale] is null, it resets to the system locale.
  /// [locale] is the locale to set, or null to reset to system locale.
  void setLocale(Locale locale) {
    final prev = state;
    logger.info(
      'Locale changed from ${prev?.toLanguageTag() ?? "null"} to ${locale.toLanguageTag()}',
    );
    emit(locale);
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final String? languageCode = json['languageCode'] as String?;
    final String? countryCode = json['countryCode'] as String?;
    if (languageCode != null) {
      final restoredLocale = Locale(languageCode, countryCode);
      logger.fine(
        'Locale restored from storage: ${restoredLocale.toLanguageTag()}',
      );
      return restoredLocale;
    }

    logger.warning('No locale found in storage, using best supported locale');
    return LocaleUtils.findBestSupportedLocale();
  }

  @override
  Map<String, dynamic>? toJson(Locale? state) {
    if (state == null) {
      logger.fine('Persisting null locale to storage');
      return null;
    }
    logger.fine('Persisting locale to storage: ${state.toLanguageTag()}');
    return {
      'languageCode': state.languageCode,
      'countryCode': state.countryCode,
    };
  }
}
