import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n {
    final l10n = AppLocalizations.of(this);
    if (l10n == null) {
      throw FlutterError(
        'AppLocalizations not found in context. '
        'Make sure your context is under a Localizations widget and localization is properly set up.',
      );
    }
    return l10n;
  }
}
