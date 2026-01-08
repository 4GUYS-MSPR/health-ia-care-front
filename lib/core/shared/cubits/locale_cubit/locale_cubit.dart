import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../utils/locale_utils.dart';

class LocaleCubit extends HydratedCubit<Locale?> {

  LocaleCubit() : super(LocaleUtils.findBestSupportedLocale());

  /// Sets the locale for the application.
  ///
  /// If [locale] is null, it resets to the system locale.
  /// [locale] is the locale to set, or null to reset to system locale.
  void setLocale(Locale locale) {
    emit(locale);
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final String? languageCode = json['languageCode'] as String?;
    final String? countryCode = json['countryCode'] as String?;
    if (languageCode != null) {
      final restoredLocale = Locale(languageCode, countryCode);
      return restoredLocale;
    }

    return LocaleUtils.findBestSupportedLocale();
  }

  @override
  Map<String, dynamic>? toJson(Locale? state) {
    if (state == null) return null;

    return {
      'languageCode': state.languageCode,
      'countryCode': state.countryCode,
    };
  }
}
