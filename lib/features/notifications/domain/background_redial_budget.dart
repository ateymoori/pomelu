import 'dart:async';

/// How long the app redials an unreachable gateway in the background, held
/// alive by "Stay connected": a gateway down all night must not cost a dial
/// a minute. Once unreachable in the background for [budget], [park] runs;
/// [wake] runs when the app comes to the front or the network changes.
class BackgroundRedialBudget {
  BackgroundRedialBudget({
    required this.budget,
    required this.park,
    required this.wake,
  });

  final Duration budget;

  /// Stops the redialling and says so.
  final Future<void> Function() park;

  /// Dials again.
  final Future<void> Function() wake;

  Timer? _timer;
  bool _background = false;
  bool _unreachable = false;
  bool _parked = false;
  bool _disposed = false;

  bool get parked => _parked;

  /// The connection dials without success ([unreachable]), or not.
  void connection({required bool unreachable}) {
    _unreachable = unreachable;
    _evaluate();
  }

  void foreground({required bool visible}) {
    _background = !visible;
    if (visible && _parked) return _resume();
    _evaluate();
  }

  /// The network changed and is up: worth a try.
  void networkChanged() {
    if (_parked) _resume();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }

  void _evaluate() {
    if (_disposed || _parked) return;
    if (_background && _unreachable) {
      _timer ??= Timer(budget, _runOut);
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _runOut() {
    _timer = null;
    if (_disposed || _parked || !_background || !_unreachable) return;
    _parked = true;
    unawaited(park());
  }

  void _resume() {
    _parked = false;
    _unreachable = false;
    unawaited(wake());
  }
}
