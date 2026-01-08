import 'package:flutter/material.dart';
import 'package:language_code/language_code.dart';

import '../../../l10n/generated/app_localizations.dart';

class LocaleUtils {
  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  static String getLanguageNativeName(Locale locale) {
    return LanguageCodes.fromLocale(locale).nativeName;
  }

  static String getLanguageEnglishName(Locale locale) {
    return LanguageCodes.fromLocale(locale).englishName;
  }

  static Locale findBestSupportedLocale() {
    WidgetsFlutterBinding.ensureInitialized();
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

    // 1. Try to match both languageCode and countryCode
    for (final locale in LocaleUtils.supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode &&
          locale.countryCode == deviceLocale.countryCode) {
        return locale;
      }
    }

    // 2. Try to match languageCode only
    for (final locale in LocaleUtils.supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return locale;
      }
    }

    // 3. Fallback to the first supported locale
    return LocaleUtils.supportedLocales.first;
  }
}
