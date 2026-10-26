import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/config/assets.dart';
import 'core/storage/key_value_store.dart';
import 'core/storage/memory_key_value_store.dart';
import 'core/storage/secret_store.dart';
import 'core/theme/app_chrome.dart';
import 'core/utils/app_logger.dart';
import 'features/chat/data/media_cache.dart';
import 'features/connection/data/credential_storage.dart';
import 'features/connection/presentation/connection_providers.dart';
import 'features/settings/domain/preference_keys.dart';
import 'hermes/auth/auth_credential.dart';

Future<void> main() async {
  initLogging();
  final binding = WidgetsFlutterBinding.ensureInitialized();
  _installErrorHooks();
  _registerBundledLicenses();
  binding.deferFirstFrame();
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  // Until the first frame, when `AppChrome` takes over from the theme.
  SystemChrome.setSystemUIOverlayStyle(
    overlayStyleFor(PlatformDispatcher.instance.platformBrightness),
  );
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

  final secrets = SecureSecretStore();
  final savedPrefs = _loadOrElse<KeyValueStore>(
    'preferences',
    SharedPrefsStore.create,
    MemoryKeyValueStore.new,
  );
  final savedCredential = _loadOrElse<AuthCredential>(
    'credential',
    SecureCredentialStorage(secrets).load,
    NoCredential.new,
  );
  final prefs = await savedPrefs;
  final credential = await savedCredential;
  await _keepSecretsReadableLocked(secrets, prefs);

  runApp(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(prefs),
        secretStoreProvider.overrideWithValue(secrets),
        initialCredentialProvider.overrideWithValue(credential),
      ],
      child: const HermesApp(),
    ),
  );
  binding.allowFirstFrame();
  binding.addPostFrameCallback((_) => unawaited(MediaCache.pruneStale()));
}

/// Logs what the framework and the platform dispatcher catch.
void _installErrorHooks() {
  FlutterError.onError = (details) {
    log.e(
      'flutter error in ${details.library ?? 'the framework'}',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.e('uncaught error', error: error, stackTrace: stack);
    return true;
  };
}

/// The notices of the fonts and scripts shipped as files, read when the
/// license page opens.
void _registerBundledLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final bundled in Assets.bundledLicenses) {
      yield LicenseEntryWithLineBreaks([
        bundled.name,
      ], await rootBundle.loadString(bundled.asset));
    }
  });
}

/// Once: secrets stored before the background check are written again
/// under the level it can read while the phone is locked. Before the client
/// starts, so no renewed token is overwritten.
Future<void> _keepSecretsReadableLocked(
  SecureSecretStore secrets,
  KeyValueStore prefs,
) async {
  if (prefs.getBool(PreferenceKeys.secretsReadableLocked) ?? false) return;
  try {
    await secrets
        .rewrite(const [
          PreferenceKeys.gatewayToken,
          PreferenceKeys.gatewayPassword,
        ])
        .timeout(AppConfig.startupBudget);
    await prefs.setBool(PreferenceKeys.secretsReadableLocked, true);
  } on Object catch (e, st) {
    log.w('secrets not moved yet', error: e, stackTrace: st);
  }
}

/// [load], or [fallback] when it throws or outlasts
/// [AppConfig.startupBudget]: startup never stalls on the splash.
Future<T> _loadOrElse<T>(
  String what,
  Future<T> Function() load,
  T Function() fallback,
) async {
  try {
    return await load().timeout(AppConfig.startupBudget);
  } on Object catch (e, st) {
    log.w('$what not ready, starting without it', error: e, stackTrace: st);
    return fallback();
  }
}
