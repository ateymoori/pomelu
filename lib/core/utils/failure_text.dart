import 'package:flutter/widgets.dart';

import '../../hermes/hermes_failure.dart';
import '../../l10n/generated/app_localizations.dart';
import 'l10n_ext.dart';

/// The user's sentence for anything caught: [failureTextFor] in [context].
String failureText(BuildContext context, Object error) =>
    failureTextFor(context.l10n, error);

/// The user's sentence for anything caught. A typed [HermesFailure] has its
/// own; anything else is `errorUnknown`, so no raw exception reaches the
/// screen.
String failureTextFor(AppLocalizations l10n, Object error) => switch (error) {
  NetworkFailure() => l10n.errorNetwork,
  UnauthorizedFailure() => l10n.errorUnauthorized,
  HostRefusedFailure() => l10n.errorHostRefused,
  ForbiddenFailure() => l10n.errorForbidden,
  NotSupportedFailure() => l10n.errorNotSupported,
  GatewayTooOldFailure(:final version, :final minimum) =>
    l10n.errorGatewayTooOld(version, minimum),
  ProtocolFailure() => l10n.errorProtocol,
  SessionBusyFailure(:final openElsewhere) =>
    openElsewhere ? l10n.errorChatOpenElsewhere : l10n.errorGatewayFull,
  ServerFailure(:final message) when message.trim().isNotEmpty =>
    l10n.errorServer(message),
  _ => l10n.errorUnknown,
};

/// Whether a Retry could cure [error]: not a missing route, not an old
/// gateway.
bool failureIsRetryable(Object error) =>
    error is! NotSupportedFailure && error is! GatewayTooOldFailure;
