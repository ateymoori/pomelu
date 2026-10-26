import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/auth/auth_credential.dart';
import '../../../hermes/hermes_constants.dart';
import '../../../hermes/hermes_log.dart';
import '../../connection/domain/gateway_config.dart';
import '../../connection/presentation/connection_providers.dart';
import '../domain/settings_form_state.dart';

part 'settings_controller.g.dart';

/// Installed app version, for the About row.
@riverpod
Future<String> appVersion(Ref ref) async =>
    (await PackageInfo.fromPlatform()).version;

/// Whether the form holds changes Save would write and closing would lose.
@riverpod
bool settingsDirty(Ref ref) => ref
    .watch(settingsControllerProvider)
    .isDirty(
      saved: ref.watch(gatewayConfigProvider),
      credential: ref.watch(credentialProvider),
    );

/// Drives the settings form: probe the URL, sign in, test, save.
///
/// Nothing is stored before [saveAndConnect], the password included. After
/// every `await` a result is dropped when the page is gone or the URL
/// changed meanwhile: it answers for another address (a token from host A
/// is never saved for host B). A started save runs to its end.
@riverpod
class SettingsController extends _$SettingsController {
  Timer? _debounce;

  /// Bumped when the URL changes and when the page closes.
  int _epoch = 0;

  @override
  SettingsFormState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _epoch++;
    });
    final config = ref.read(gatewayConfigProvider);
    final credential = ref.read(credentialProvider);
    unawaited(Future<void>.microtask(probe));
    return SettingsFormState(
      url: config?.url ?? AppConfig.defaultGatewayUrl,
      username: config?.username ?? '',
    ).withStored(config, credential);
  }

  Uri? get _uri => state.config.uri;

  bool _stale(int epoch) => !ref.mounted || epoch != _epoch;

  /// A credential belongs to one gateway: it goes when the URL points
  /// elsewhere and comes back when the saved URL is typed again.
  void setUrl(String value) {
    final saved = ref.read(gatewayConfigProvider);
    final same =
        saved != null &&
        GatewayConfig(url: value).normalizedUrl == saved.normalizedUrl;
    _epoch++;
    state = state
        .copyWith(
          url: value,
          probe: null,
          probing: false,
          signingIn: false,
          testing: false,
          testResult: null,
          error: null,
        )
        .withStored(saved, ref.read(credentialProvider), other: !same);
    _debounce?.cancel();
    _debounce = Timer(AppConfig.urlProbeDebounce, () => unawaited(probe()));
  }

  void setUsername(String value) =>
      state = state.copyWith(username: value, error: null);

  void setPassword(String value) =>
      state = state.copyWith(password: value, error: null);

  void setToken(String value) => state = state.copyWith(token: value);

  /// Runs [op] with [busy] set, dropping a stale result; [busy] is cleared
  /// whatever happens.
  Future<void> _run(
    String what,
    SettingsFormState Function(SettingsFormState s, bool on) busy,
    Future<SettingsFormState Function(SettingsFormState)> Function(int epoch)
    op,
  ) async {
    final epoch = _epoch;
    state = busy(state, true).copyWith(error: null);
    try {
      final apply = await op(epoch);
      if (!_stale(epoch)) state = apply(busy(state, false));
    } on Object catch (e, st) {
      log.w('$what failed', error: safeErrorText(e), stackTrace: st);
      if (!_stale(epoch)) state = busy(state, false).copyWith(error: e);
    }
  }

  /// Asks the gateway what it is and whether it is gated.
  Future<void> probe() async {
    if (!ref.mounted) return;
    final uri = _uri;
    if (uri == null) {
      state = state.copyWith(probe: null, probing: false);
      return;
    }
    await _run('probe', (s, on) => s.copyWith(probing: on), (_) async {
      final result = await ref.read(connectionServiceProvider).probe(uri);
      return (SettingsFormState s) => s.copyWith(probe: result);
    });
  }

  /// Password sign-in; the password stays in the form until a save.
  Future<void> signIn() async {
    final uri = _uri;
    if (uri == null || state.signingIn) return;
    state = state.copyWith(testResult: null);
    await _run('sign-in', (s, on) => s.copyWith(signingIn: on), (_) async {
      final credential = await ref
          .read(connectionServiceProvider)
          .signInBasic(
            base: uri,
            provider:
                state.probe?.passwordProvider?.name ??
                HermesProtocol.basicProvider,
            username: state.username.trim(),
            password: state.password,
          );
      return (SettingsFormState s) => s.copyWith(
        pendingCredential: credential,
        signedInAs: credential.username.isEmpty
            ? s.username.trim()
            : credential.username,
      );
    });
  }

  /// Adopts the pasted token, for the gateway the URL names.
  void useToken() {
    final token = state.token.trim();
    final uri = _uri;
    if (token.isEmpty || uri == null) return;
    state = state.copyWith(
      pendingCredential: SessionTokenCredential(
        token,
        origin: gatewayOrigin(uri),
      ),
      testResult: null,
      error: null,
    );
  }

  /// HTTP and WebSocket round trip; an un-gated gateway's token is
  /// discovered first when none is held.
  Future<void> test() async {
    final uri = _uri;
    if (uri == null || state.testing) return;
    state = state.copyWith(testResult: null);
    await _run('connection test', (s, on) => s.copyWith(testing: on), (
      epoch,
    ) async {
      final service = ref.read(connectionServiceProvider);
      var credential = state.effectiveCredential;
      if (credential == null && !state.gated) {
        credential = await service.discoverToken(uri);
        if (!_stale(epoch) && credential != null) {
          state = state.copyWith(pendingCredential: credential);
        }
      }
      final result = await service.test(
        uri,
        credential ?? const NoCredential(),
      );
      return (SettingsFormState s) => s.copyWith(testResult: result);
    });
  }

  /// Stores the credential, the password and the config, then nudges the
  /// supervisor. Returns whether the page may close.
  ///
  /// The credential is written only when the form changed it, so a save
  /// while the gateway is down keeps the stored account; the password goes
  /// with a signed-in user only. On a new address the old client stops
  /// first and the credential goes in before the config (which the client
  /// is built from), so no client dials with the other gateway's login. On
  /// the same address a new credential cycles the socket.
  Future<bool> saveAndConnect() async {
    final config = state.config;
    if (config.uri == null || state.saving) return false;
    state = state.copyWith(saving: true, error: null);
    final credential = state.effectiveCredential ?? const NoCredential();
    final changed = state.changesCredential(ref.read(credentialProvider));
    final same =
        ref.read(gatewayConfigProvider)?.normalizedUrl == config.normalizedUrl;
    final password = state.password;
    // Read now, so a page closed mid-save cannot cut it in half.
    final storage = ref.read(credentialStorageProvider);
    final credentials = ref.read(credentialProvider.notifier);
    final configs = ref.read(gatewayConfigProvider.notifier);
    final supervisor = ref.read(connectionSupervisorProvider.notifier);
    final oldClient = same ? null : ref.read(hermesClientProvider);
    try {
      await oldClient?.disconnect();
      if (changed) {
        if (credential is! BearerCredential) {
          await storage.savePassword(null);
        } else if (password.isNotEmpty) {
          await storage.savePassword(password);
        }
        await credentials.set(credential);
      }
      await configs.save(config);
      await supervisor.reconnect(cycle: same && changed);
      if (ref.mounted) state = state.copyWith(saving: false);
      return true;
    } on Object catch (e, st) {
      log.w('save failed', error: safeErrorText(e), stackTrace: st);
      // The address did not change after all: the old client goes on.
      if (oldClient != null) {
        unawaited(_quietly('reconnect', oldClient.connect));
      }
      if (ref.mounted) state = state.copyWith(saving: false, error: e);
      return false;
    }
  }

  /// Drops the stored sign-in, keeps the URL, and cycles the socket that
  /// still runs on it. A sign-in only the form holds is only cleared from
  /// the form.
  Future<void> signOut() async {
    final saved = ref.read(gatewayConfigProvider);
    final unsaved =
        state.changesCredential(ref.read(credentialProvider)) ||
        saved?.normalizedUrl != state.config.normalizedUrl;
    if (unsaved) return _clearSignIn();
    final credentials = ref.read(credentialProvider.notifier);
    final storage = ref.read(credentialStorageProvider);
    final client = ref.read(hermesClientProvider);
    try {
      await credentials.set(const NoCredential());
      await storage.savePassword(null);
    } on Object catch (e, st) {
      log.w('sign-out failed', error: safeErrorText(e), stackTrace: st);
      if (ref.mounted) state = state.copyWith(error: e);
      return;
    }
    if (ref.mounted) _clearSignIn();
    if (client == null) return;
    await _quietly('reconnect after sign-out', () async {
      await client.disconnect();
      await client.connect();
    });
  }

  void _clearSignIn() => state = state.withoutSignIn();

  static Future<void> _quietly(String what, Future<void> Function() op) async {
    try {
      await op();
    } on Object catch (e, st) {
      log.w('$what failed', error: safeErrorText(e), stackTrace: st);
    }
  }
}
