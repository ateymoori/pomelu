import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Strings outside the widget tree (the notification shade): the platform
/// locale when the app has it, else the first supported one.
AppLocalizations platformL10n() => lookupAppLocalizations(
  AppLocalizations.supportedLocales.firstWhere(
    (l) => l.languageCode == PlatformDispatcher.instance.locale.languageCode,
    orElse: () => AppLocalizations.supportedLocales.first,
  ),
);
