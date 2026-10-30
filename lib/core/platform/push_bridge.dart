import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../hermes/models/push_device.dart';
import '../utils/app_logger.dart';
import 'platform_channels.dart';
import 'platform_info.dart';

part 'push_bridge.g.dart';

/// The phone's push service: Apple's (APNs, `PushBridge.swift`) or Google's
/// (FCM, `PushBridge.kt`). The native side also opens each sealed push and
/// shows it, so a push rings while no Dart runs.
abstract interface class PushBridge {
  /// This phone for the Pomelu Hermes plugin: its push token and its key.
  /// [newKey] makes a new key first, so pushes another account still sends
  /// cannot be opened. Null where push cannot work: no Google Play services,
  /// a build without the Firebase config, or the system refused.
  Future<PushDevice?> register({bool newKey = false});

  /// The push token changed: register again.
  Stream<void> get tokenChanges;

  /// The bot whose push notification was tapped.
  Stream<String> get taps;

  /// The bot of the tap that cold-started the app, once.
  Future<String?> launchBot();
}

/// No push: other platforms and tests.
class NoPushBridge implements PushBridge {
  const NoPushBridge();

  @override
  Future<PushDevice?> register({bool newKey = false}) async => null;

  @override
  Stream<void> get tokenChanges => const Stream.empty();

  @override
  Stream<String> get taps => const Stream.empty();

  @override
  Future<String?> launchBot() async => null;
}

/// The native side over [PlatformChannels.push]: `register {newKey}` gives
/// `{platform, token, key, sandbox}` or null, `launchBot` a bot or null;
/// [PlatformChannels.pushEvents] sends `{type: token}` and
/// `{type: tap, bot}`.
class ChannelPushBridge implements PushBridge {
  ChannelPushBridge() {
    _events.receiveBroadcastStream().listen((event) {
      if (event is! Map) return;
      switch (event['type']) {
        case 'token':
          _tokens.add(null);
        case 'tap':
          final bot = event['bot'];
          if (bot is String && bot.isNotEmpty) _taps.add(bot);
      }
    }, onError: (Object e) => log.w('push: event stream failed', error: e));
  }

  static const _channel = MethodChannel(PlatformChannels.push);
  static const _events = EventChannel(PlatformChannels.pushEvents);

  final _tokens = StreamController<void>.broadcast();
  final _taps = StreamController<String>.broadcast();

  @override
  Future<PushDevice?> register({bool newKey = false}) async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('register', {
        'newKey': newKey,
      });
      return raw == null ? null : PushDevice.fromJson(raw);
    } on PlatformException catch (e) {
      log.i('push: not available (${e.code}: ${e.message})');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Stream<void> get tokenChanges => _tokens.stream;

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> launchBot() async {
    try {
      return await _channel.invokeMethod<String>('launchBot');
    } on PlatformException catch (e) {
      log.w('push: launch tap unreadable', error: e);
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

/// Push on Android and iOS, none elsewhere.
@Riverpod(keepAlive: true)
PushBridge pushBridge(Ref ref) => ref.watch(platformInfoProvider).isMobile
    ? ChannelPushBridge()
    : const NoPushBridge();
