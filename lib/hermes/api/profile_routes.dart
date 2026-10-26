part of 'hermes_api.dart';

/// Bot (profile) management as Hermes Desktop does it: the title in
/// `ui_meta['hermes-bots']`, the picture in the profile's asset store,
/// create over the socket, delete over the dashboard's REST route.
mixin _ProfileRoutes {
  HermesClient get _client;

  /// Creates bot [name], a profile id. It starts with the gateway's own
  /// model, keys and bundled skills.
  Future<void> createProfile(String name) => _client.call(
    HermesMethods.profilesCreate,
    {'name': name},
    HermesTimeouts.profileChange,
  );

  /// Deletes bot [name] with its chats, memory and files. The gateway
  /// refuses the default bot.
  Future<void> deleteProfile(String name) => _optionalRoute(
    'deleting a bot',
    () => _client.http.send(
      'DELETE',
      HermesPaths.profile(name),
      timeout: HermesTimeouts.profileChange,
    ),
  );

  /// Sets the picture of bot [name] to [dataUrl] (PNG, JPEG or WebP, at
  /// most [HermesLimits.maxAvatarBytes]); null removes it.
  Future<void> setAvatar(String name, String? dataUrl) =>
      _client.call(HermesMethods.profilesSetAsset, {
        'name': name,
        'asset': HermesProtocol.avatarAsset,
        if (dataUrl == null) 'clear': true else 'data': dataUrl,
      });

  /// Sets the title of bot [name]; empty shows its profile name again.
  ///
  /// A compare-and-set on the whole `hermes-bots` entry: the rest of it (a
  /// colour another client chose) is written back as the gateway has it, and
  /// a write that lost a race is redone on the newer entry.
  Future<void> setBotTitle(String name, String title) async {
    const key = HermesProtocol.botsMetaKey;
    for (var i = 0; i < HermesLimits.metaWriteAttempts; i++) {
      final res = await _client.call(HermesMethods.profilesList, const {
        'include_sessions': false,
      });
      final row = (res['profiles'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .where((p) => p['name'] == name)
          .firstOrNull;
      if (row == null) throw ServerFailure('there is no bot "$name"');
      final profile = HermesProfile.fromJson(row);
      final current = profile.uiMeta?[key];
      // `chat` is a pin Desktop no longer writes back either.
      final meta = {
        if (current is Map<String, dynamic>) ...current,
        'title': title,
      }..remove('chat');
      if (title.isEmpty) meta.remove('title');
      final revisions = profile.uiMetaRevisions;
      final applied = (await _client.call(HermesMethods.profilesConfigure, {
        'name': name,
        'ui_meta': {key: meta},
        if (revisions != null)
          'ui_meta_expected_revisions': {
            key: switch (revisions[key]) {
              final int n => n,
              _ => 0,
            },
          },
      }))['applied'];
      // An older gateway reports nothing: the write is all it can do.
      if (applied is! Map) return;
      if (applied['ui_meta_conflicts'] != null) continue;
      if (applied['ui_meta'] == true) return;
      throw const ServerFailure('the gateway did not save the name');
    }
    throw const ServerFailure('another device keeps changing this bot');
  }
}
