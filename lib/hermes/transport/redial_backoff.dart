import 'dart:math';

import '../hermes_constants.dart';

/// When to redial: full jitter under a ceiling that doubles per attempt, and
/// rises once an outage is long.
class RedialBackoff {
  RedialBackoff([Random? random]) : _random = random ?? Random();
  final Random _random;

  /// Redials since the last [reset].
  int attempt = 0;

  void reset() => attempt = 0;

  /// The wait before the next redial; counts it as an attempt.
  Duration next() {
    final cap = attempt >= HermesLimits.backoffLongAfter
        ? HermesTimeouts.backoffLongMax
        : HermesTimeouts.backoffMax;
    final grown =
        HermesTimeouts.backoffInitial.inMilliseconds * pow(2, attempt++);
    final ceiling = min(cap.inMilliseconds.toDouble(), grown.toDouble());
    return Duration(milliseconds: (_random.nextDouble() * ceiling).round());
  }
}
