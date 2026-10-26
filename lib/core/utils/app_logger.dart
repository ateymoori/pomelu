import 'package:logger/logger.dart';

import '../../hermes/hermes_log.dart';

/// Warnings and up in release, all but traces in debug.
const Level appLogLevel = bool.fromEnvironment('dart.vm.product')
    ? Level.warning
    : Level.debug;

/// Applies [appLogLevel]; [log] follows the global `Logger.level`, which is
/// how tests turn it off.
void initLogging() => Logger.level = appLogLevel;

/// The app logger. Every line is redacted: the socket URL carries a token,
/// and an uncaught socket error prints it.
final Logger log = Logger(
  // The default filter drops every line in release; this one keeps
  // [appLogLevel].
  filter: ProductionFilter(),
  printer: RedactingPrinter(
    PrettyPrinter(methodCount: 0, errorMethodCount: 6, lineLength: 100),
  ),
);

/// The lines of [_inner] through [redactSecrets].
class RedactingPrinter extends LogPrinter {
  RedactingPrinter(this._inner);

  final LogPrinter _inner;

  @override
  Future<void> init() => _inner.init();

  @override
  List<String> log(LogEvent event) => [
    for (final line in _inner.log(event)) redactSecrets(line),
  ];

  @override
  Future<void> destroy() => _inner.destroy();
}
