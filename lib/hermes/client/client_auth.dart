part of 'hermes_client.dart';

/// Builds each dial with a fresh credential, and renews it: a refreshed
/// token pair, or the session token a restarted dashboard shows.
class _Renewal {
  _Renewal(this._c);

  final HermesClient _c;

  Future<bool>? _refreshing;

  /// Dials being built; a replaced one may still be out.
  int _dialing = 0;
  bool _dialRenewed = false;

  /// The refresh token the gateway refused last; never offered again.
  String? _refusedRefreshToken;

  Future<WsDial> buildDial() async {
    _dialing++;
    _dialRenewed = false;
    try {
      var cred = read();
      if (cred is BearerCredential &&
          cred.needsRefresh(DateTime.now().toUtc()) &&
          await tryRefresh()) {
        cred = read();
      }
      WsDial tokenDial(String token) =>
          WsDial(uri: _c.http.resolveWs(HermesPaths.ws, {'token': token}));
      switch (cred) {
        case NoCredential():
          // Un-gated gateway: its index page tells the token.
          final found = await _c.auth.discoverSessionCredential();
          if (found == null) {
            throw const UnauthorizedFailure('gateway requires a credential');
          }
          await _rotate(found);
          return tokenDial(found.token);
        case SessionTokenCredential(:final token):
          return tokenDial(token);
        case BearerCredential():
          final ticket = await _c.auth.mintTicket();
          return WsDial(
            uri: _c.http.resolveWs(HermesPaths.ws),
            protocols: [
              HermesProtocol.wsSubprotocol,
              '${HermesProtocol.wsTicketProtocolPrefix}$ticket',
            ],
          );
      }
    } finally {
      _dialing--;
    }
  }

  AuthCredential read() => credentialFor(_c.baseUrl, _c._credential);

  Future<void> _rotate(AuthCredential cred) async {
    try {
      await _c._onCredentialRotated(cred);
    } on Object catch (e) {
      _c.log('could not keep the renewed credential', e);
    }
  }

  /// Renews the credential, one renewal at a time (callers meanwhile wait
  /// for it). True when renewed. False when there is nothing to renew, the
  /// refresh token is refused, the token found is the failing one, or this
  /// dial renewed already. Other failures (unreachable, 5xx) are thrown: they
  /// must not read as a sign-out.
  Future<bool> tryRefresh() {
    final running = _refreshing;
    if (running != null) return running;
    if (_dialing > 0 && _dialRenewed) return Future.value(false);
    final AuthCredential cred;
    try {
      cred = read();
    } on HermesFailure catch (e) {
      return Future.error(e);
    }
    final Future<bool> renewal;
    switch (cred) {
      case BearerCredential(:final refreshToken)
          when refreshToken != null && refreshToken == _refusedRefreshToken:
        return Future.value(false);
      case BearerCredential():
        renewal = _refresh(cred);
      case SessionTokenCredential():
        renewal = rediscover(cred);
      case NoCredential():
        return Future.value(false);
    }
    if (_dialing > 0) _dialRenewed = true;
    _refreshing = renewal;
    return renewal.whenComplete(() => _refreshing = null);
  }

  Future<bool> _refresh(BearerCredential cred) async {
    try {
      await _rotate(await _c.auth.refresh(cred));
      return true;
    } on HermesFailure catch (e) {
      if (e is! UnauthorizedFailure && e is! ForbiddenFailure) rethrow;
      _refusedRefreshToken = cred.refreshToken;
      _c.log('token refresh refused', e);
      return false;
    }
  }

  /// A restarted dashboard has a new session token on its index page; true
  /// when one other than [held] was found and kept.
  Future<bool> rediscover(SessionTokenCredential? held) async {
    final SessionTokenCredential? found;
    try {
      found = await _c.auth.discoverSessionCredential();
    } on ServerFailure catch (e) {
      _c.log('session token discovery failed', e);
      return false;
    }
    if (found == null || found.token == held?.token) return false;
    await _rotate(found);
    return true;
  }
}
