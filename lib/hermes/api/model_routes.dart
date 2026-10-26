part of 'hermes_api.dart';

/// Models to pick from (for a session or a bot), and a live session's model
/// and reasoning effort.
mixin _ModelRoutes {
  HermesClient get _client;

  /// Models and providers to pick from, for a live session or a bot.
  Future<ModelOptions> modelOptions({
    String? runtimeId,
    String? profile,
  }) async => parseObject(
    await _client.call(HermesMethods.modelOptions, {
      'session_id': ?runtimeId,
      'profile': ?profile,
    }, HermesTimeouts.rpcStartup),
    ModelOptions.fromJson,
    what: 'model options',
  );

  /// Runs `/model <id> [--provider <slug>]` on the live session. The ids go
  /// into a command line, so one that is not a plain id is refused.
  Future<void> switchModel({
    required String runtimeId,
    required String model,
    String? provider,
  }) async {
    final named = provider != null && provider.isNotEmpty;
    bool isId(String id) =>
        !id.startsWith('-') && RegExp(r'^[\w.:/@+-]+$').hasMatch(id);
    if (!isId(model) || (named && !isId(provider))) {
      throw ProtocolFailure('not a usable model or provider id: "$model"');
    }
    await _client.call(HermesMethods.slashExec, {
      'session_id': runtimeId,
      'command': named ? 'model $model --provider $provider' : 'model $model',
    }, HermesTimeouts.slashExec);
  }

  /// Sets the reasoning effort for this session only.
  Future<void> setReasoningEffort({
    required String runtimeId,
    required String effort,
  }) => _client.call(HermesMethods.configSet, {
    'session_id': runtimeId,
    'key': 'reasoning',
    'value': effort,
    'scope': 'session',
  });
}
