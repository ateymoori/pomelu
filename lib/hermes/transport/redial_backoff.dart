import 'dart:math';

import '../hermes_constants.dart';

/// When to redial: full jitter under a ceiling that doubles per attempt, and
/// rises once an outage is long.
class RedialBackoff {
  RedialBackoff([Random? random]) : _random = random ?? Random();
  final Random _random;

  static const _maxDoublings = 20;

  /// Redials since the last [reset].
  int attempt = 0;

  void reset() => attempt = 0;

  /// The wait before the next redial; counts it as an attempt.
  Duration next() {
    final cap = attempt >= HermesLimits.backoffLongAfter
        ? HermesTimeouts.backoffLongMax
        : HermesTimeouts.backoffMax;
    // The exponent stops where the cap is long passed: 2^62 and up wraps
    // to zero or below, which would redial with no wait at all.
    final grown =
        HermesTimeouts.backoffInitial.inMilliseconds *
        pow(2, min(attempt++, _maxDoublings));
    final ceiling = min(cap.inMilliseconds, grown);
    return Duration(milliseconds: (_random.nextDouble() * ceiling).round());
  }
}
