part of 'hermes_api.dart';

/// The Pomelu Hermes plugin's routes (`/api/plugins/pomelu/`): a phone
/// registered here gets a push when a bot answers in its Bot Chat while the
/// app is away. A gateway without the plugin answers 404, a
/// [NotSupportedFailure].
mixin _PushRoutes {
  HermesClient get _client;

  /// Adds or renews phone [id]. Each call also turns the plugin on for bots
  /// made since the last one.
  Future<void> registerPushDevice(String id, PushDevice device) =>
      _optionalRoute(
        'push',
        () => _client.http.send(
          'PUT',
          HermesPaths.pushDevice(id),
          body: device.toJson(),
          timeout: HermesTimeouts.pushRegister,
        ),
      );

  /// Phone [id] gets no more pushes.
  Future<void> removePushDevice(String id) => _optionalRoute(
    'push',
    () => _client.http.send('DELETE', HermesPaths.pushDevice(id)),
  );

  /// The app is on screen on phone [id] ([visible]), or left it: no push
  /// while it is open.
  Future<void> setPushPresence(String id, {required bool visible}) =>
      _optionalRoute(
        'push',
        () => _client.http.send(
          'PUT',
          HermesPaths.pushPresence(id),
          body: {'visible': visible},
        ),
      );
}
