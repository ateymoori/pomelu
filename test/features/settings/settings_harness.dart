import 'dart:async';

import 'package:hermes/features/connection/data/connection_service.dart';
import 'package:hermes/features/connection/domain/connection_probe.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/auth/hermes_auth.dart';
import 'package:hermes/hermes/models/gateway_status.dart';

import '../../support/fake_gateway.dart';
import '../../support/memory_stores.dart';
import '../../support/throwing.dart';

const ProbeResult gatedProbe = ProbeResult(
  reachable: true,
  status: GatewayStatus(version: '1.2.3', authRequired: true),
  providers: [AuthProvider(name: 'basic', supportsPassword: true)],
);

/// The gateway calls of the page; gates hold an answer back.
class FakeConnectionService implements ConnectionService {
  ProbeResult probeResult = const ProbeResult(
    reachable: true,
    status: GatewayStatus(version: '1.2.3'),
  );
  TestResult testResult = const TestResult(
    httpOk: true,
    wsOk: true,
    version: '1.2.3',
  );
  SessionTokenCredential? discovered;
  Object? signInError;
  Object? testError;
  Completer<void>? probeGate;
  Completer<void>? signInGate;
  Completer<void>? discoverGate;
  int probeCalls = 0;
  int signIns = 0;
  Uri lastProbeUri = Uri();

  @override
  Future<ProbeResult> probe(Uri base) async {
    probeCalls++;
    lastProbeUri = base;
    final result = probeResult;
    await probeGate?.future;
    return result;
  }

  @override
  Future<SessionTokenCredential?> discoverToken(Uri base) async {
    await discoverGate?.future;
    return discovered;
  }

  @override
  Future<BearerCredential> signInBasic({
    required Uri base,
    required String provider,
    required String username,
    required String password,
  }) async {
    signIns++;
    await signInGate?.future;
    if (signInError case final e?) throwInjected(e);
    return BearerCredential(accessToken: 'at-$username', username: username);
  }

  @override
  Future<TestResult> test(Uri base, AuthCredential cred) async {
    if (testError case final e?) throwInjected(e);
    return testResult;
  }
}

/// Keeps the real supervisor (and its platform channels) out.
class FakeSupervisor extends ConnectionSupervisor {
  // ignore: riverpod_lint/avoid_public_notifier_properties
  int reconnects = 0;
  // ignore: riverpod_lint/avoid_public_notifier_properties
  int cycles = 0;

  @override
  void build() {}

  @override
  Future<void> reconnect({bool cycle = false}) async {
    reconnects++;
    if (cycle) cycles++;
  }
}

/// A live client that records what is done to its socket.
class RecordingClient extends FakeClient {
  final socketCalls = <String>[];

  @override
  Future<void> disconnect() async => socketCalls.add('disconnect');

  @override
  Future<void> connect() async => socketCalls.add('connect');
}

class LoggingKeyValueStore extends MemoryKeyValueStore {
  LoggingKeyValueStore(this.order);
  final List<String> order;

  @override
  Future<void> setString(String key, String value) {
    order.add('kv:$key');
    return super.setString(key, value);
  }
}

/// Records secret writes in [order], runs [beforeToken] before the token is
/// written, and with [fail] throws like a locked keystore.
class SpySecretStore extends MemorySecretStore {
  SpySecretStore({this.order, this.beforeToken, this.fail = false});
  final List<String>? order;
  final void Function()? beforeToken;
  final bool fail;

  @override
  Future<void> write(String key, String value) {
    if (fail) throw StateError('keystore locked');
    if (key == PreferenceKeys.gatewayToken) beforeToken?.call();
    order?.add('secret:$key');
    return super.write(key, value);
  }
}
