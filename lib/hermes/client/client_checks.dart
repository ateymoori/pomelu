part of 'hermes_client.dart';

/// Whether gateway [version] is older than [minimum]. A version that cannot
/// be read is not called old: nothing is refused on a guess.
bool isGatewayTooOld(
  String version, {
  String minimum = HermesProtocol.minGatewayVersion,
}) {
  List<int>? numbers(String v) =>
      RegExp(r'^\s*v?(\d+(?:\.\d+)*)')
          .firstMatch(v)?[1]!
          .split('.')
          .map(int.parse)
          .toList();
  final have = numbers(version);
  final need = numbers(minimum);
  if (have == null || need == null) return false;
  for (var i = 0; i < need.length; i++) {
    final h = i < have.length ? have[i] : 0;
    if (h != need[i]) return h < need[i];
  }
  return false;
}

/// What the client asks `GET /api/status` about the gateway itself: its
/// version, and whether its Host guard refused the address.
class _GatewayChecks {
  _GatewayChecks(this._c);

  final HermesClient _c;

  String _checkedEpoch = '';

  /// Once per gateway process, refuse one older than
  /// [HermesProtocol.minGatewayVersion]: the socket closes with a
  /// [GatewayTooOldFailure] and nothing redials until the app asks.
  void onGatewayProcess(String epoch) {
    if (epoch == _checkedEpoch) return;
    _checkedEpoch = epoch;
    unawaited(_checkVersion());
  }

  Future<void> _checkVersion() async {
    final String version;
    try {
      version = (await _c._status()).version;
    } on HermesFailure catch (e) {
      _c.log('gateway version check failed', e);
      return;
    }
    if (_c._disposed || !isGatewayTooOld(version)) return;
    final failure = GatewayTooOldFailure(
      version,
      HermesProtocol.minGatewayVersion,
    );
    _c.log('refusing the gateway', failure);
    _checkedEpoch = '';
    _c._liveness.stop();
    await _c._transport.disconnect();
    _c._setState(Disconnected(failure: failure));
  }

  /// Whether an upgrade refused with 403 met the Host / Origin guard: the
  /// guard also answers plain HTTP to a wrong host, with a 400, where no
  /// credential matters (`/api/status` needs none).
  Future<bool> hostRefused() async {
    try {
      await _c._status();
      return false;
    } on ServerFailure catch (e) {
      return e.httpStatus == HermesHttpStatus.badRequest;
    } on HermesFailure {
      return false;
    }
  }
}
