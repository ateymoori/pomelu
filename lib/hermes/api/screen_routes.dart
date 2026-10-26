part of 'hermes_api.dart';

/// A bot's screen (Hermes "Bot Screen"), as Hermes Desktop drives it: every
/// call names its bot, or the gateway answers for its launch profile.
/// Watching takes a viewer id this socket minted (`display.observe`);
/// take over and hand back name it. The stream itself is a second socket
/// ([ScreenAttach.stream]) the viewer opens.
mixin _ScreenRoutes {
  HermesClient get _client;

  /// The screen of [profile]; null when its gateway has none (an older
  /// Hermes).
  Future<ScreenStatus?> screenStatus(String profile) async {
    try {
      return _status(
        await _client.call(HermesMethods.displayStatus, {'profile': profile}),
      );
    } on ServerFailure catch (e) {
      if (e.rpcCode == HermesProtocol.errMethodNotFound) return null;
      rethrow;
    }
  }

  /// Starts the screen of [profile]; answers once it is up.
  Future<ScreenStatus> startScreen(String profile) async => _status(
    await _client.call(HermesMethods.displayStart, {
      'profile': profile,
    }, HermesTimeouts.screenStart),
  );

  /// The screen of [profile] now, as a JPEG data URL; null while it is off
  /// or while a human has control (what they type stays theirs).
  Future<String?> screenThumbnail(String profile) async {
    final res = await _client.call(HermesMethods.displayThumbnail, {
      'profile': profile,
    });
    final url = res['data_url'];
    return url is String && url.isNotEmpty ? url : null;
  }

  /// A way in to the running screen of [profile]. [viewerId], one this
  /// socket minted before, is kept; any other is replaced.
  Future<ScreenAttach> observeScreen(String profile, {String? viewerId}) async {
    final res = await _client.call(HermesMethods.displayObserve, {
      'profile': profile,
      'viewer_id': ?viewerId,
    });
    final ticket = res['ticket'];
    final viewer = res['viewer_id'];
    if (ticket is! String || ticket.isEmpty || viewer is! String) {
      throw const ProtocolFailure('the gateway gave no screen ticket');
    }
    return (
      status: _status(res),
      viewerId: viewer,
      stream: _client.http.resolveWs(HermesPaths.displayWs, {
        HermesProtocol.displayTicketParam: ticket,
      }),
    );
  }

  /// Control of the screen of [profile] to [viewerId]: the agent's screen
  /// tools wait, and another viewer drops to watching.
  Future<ScreenLease> takeOverScreen(String profile, String viewerId) async =>
      _lease(
        await _client.call(HermesMethods.displayLeaseAcquire, {
          'profile': profile,
          'viewer_id': viewerId,
        }),
      );

  /// Control of the screen of [profile] back to the agent, from
  /// [viewerId]; with [force], from whoever holds it.
  Future<ScreenLease> handBackScreen(
    String profile, {
    String? viewerId,
    bool force = false,
  }) async => _lease(
    await _client.call(HermesMethods.displayLeaseRelease, {
      'profile': profile,
      'viewer_id': ?viewerId,
      if (force) 'force': true,
    }),
  );

  ScreenStatus _status(Map<String, dynamic> res) =>
      parseObject(res, ScreenStatus.fromJson, what: 'screen status');

  ScreenLease _lease(Map<String, dynamic> res) =>
      parseObject(res['lease'], ScreenLease.fromJson, what: 'screen lease');
}
