import 'hermes_constants.dart';

/// Where the SDK writes what it cannot report through a result. A message
/// never carries a secret: see [redactSecrets].
typedef HermesLog = void Function(String message, [Object? error]);

/// A [HermesLog] that drops everything.
void discardLog(String message, [Object? error]) {}

final RegExp _secretParam = RegExp(
  '(\\b(?:${HermesProtocol.secretParams.join('|')})=)[^&;\\s#\'"<>)]*',
  caseSensitive: false,
);
final RegExp _userInfo = RegExp('([a-zA-Z][a-zA-Z0-9+.-]*://)[^/@?#\\s]*@');
final RegExp _bearer = RegExp(
  r'(\bBearer\s+)[A-Za-z0-9._~+/=-]+',
  caseSensitive: false,
);
final RegExp _ticketProtocol = RegExp(
  '(${RegExp.escape(HermesProtocol.wsTicketProtocolPrefix)})[^\\s,\'"\\]]+',
);

/// [text] with every secret taken out, so it can be logged or shown: secret
/// query values and cookies (`token=***`, `password=***`), `Bearer` tokens,
/// ws tickets and every URL's `user:password@`.
String redactSecrets(String text) => text
    .replaceAllMapped(_userInfo, (m) => m[1]!)
    .replaceAllMapped(_secretParam, (m) => '${m[1]}***')
    .replaceAllMapped(_bearer, (m) => '${m[1]}***')
    .replaceAllMapped(_ticketProtocol, (m) => '${m[1]}***');

/// [error] as text safe to log; null stays null.
String? safeErrorText(Object? error) =>
    error == null ? null : redactSecrets('$error');
