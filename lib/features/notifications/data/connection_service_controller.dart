import 'dart:async';

import 'package:flutter/services.dart';

import '../../../core/platform/platform_channels.dart';
import '../../../core/utils/app_logger.dart';

/// The platform foreground service that keeps the gateway socket alive with
/// the screen off ("Stay connected"). A seam: Android has one, every other
/// platform gets [NoopConnectionServiceController].
abstract interface class ConnectionServiceController {
  /// Whether the platform has such a service at all.
  bool get isSupported;

  /// A [start] went through and nothing has ended the service since, as far
  /// as the app knows; [resync] asks the platform.
  bool get isRunning;

  /// Shows the ongoing row and holds the process. Calls run in order and the
  /// latest intent wins: a start and a stop at once never reach the
  /// platform.
  Future<void> start({required String title, required String body});

  /// New words for the running service's row; kept for the next [start].
  Future<void> update({required String title, required String body});

  Future<void> stop();

  /// Takes the platform's word for [isRunning]: the system can end the
  /// service while the app is away (a timeout, the task swiped away).
  Future<void> resync();
}

/// Android, over [PlatformChannels.connectionService].
class AndroidConnectionServiceController
    implements ConnectionServiceController {
  AndroidConnectionServiceController({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel(PlatformChannels.connectionService);

  final MethodChannel _channel;
  bool _running = false;

  /// What the app last asked for, set before anything is awaited, so queued
  /// calls act on the final intent.
  bool _wanted = false;
  String _title = '';
  String _body = '';
  Future<void> _tail = Future<void>.value();

  @override
  bool get isSupported => true;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start({required String title, required String body}) {
    _wanted = true;
    _title = title;
    _body = body;
    return _enqueue(_apply);
  }

  @override
  Future<void> update({required String title, required String body}) {
    _title = title;
    _body = body;
    return _enqueue(() async {
      if (_running) await _call('update', {'title': _title, 'body': _body});
    });
  }

  @override
  Future<void> stop() {
    _wanted = false;
    return _enqueue(_apply);
  }

  @override
  Future<void> resync() => _enqueue(() async {
    final running = await _call('isRunning');
    if (running != null) _running = running;
  });

  /// Runs [op] after the calls before it. A throw is logged and ends only
  /// that call: one failure must not stop every later start and stop.
  Future<void> _enqueue(Future<void> Function() op) => _tail = _tail
      .then((_) => op())
      .catchError(
        (Object e, StackTrace st) =>
            log.e('foreground service call failed', error: e, stackTrace: st),
      );

  /// Brings the platform to what was last asked for.
  Future<void> _apply() async {
    if (_wanted == _running) return;
    if (_wanted) {
      // A refused start (the app went to the background) leaves the flag
      // off, so the next start tries again.
      _running =
          await _call('start', {'title': _title, 'body': _body}) ?? false;
    } else {
      await _call('stop');
      _running = false;
    }
  }

  /// [method] on the channel; null when the platform failed, which is
  /// logged and never thrown at the app.
  Future<bool?> _call(String method, [Map<String, String>? args]) async {
    try {
      return await _channel.invokeMethod<bool>(method, args);
    } on PlatformException catch (e) {
      log.w('foreground service $method failed', error: e);
    } on MissingPluginException catch (e) {
      log.w('foreground service channel unavailable', error: e);
    }
    return null;
  }
}

/// A platform without a foreground service.
class NoopConnectionServiceController implements ConnectionServiceController {
  @override
  bool get isSupported => false;

  @override
  bool get isRunning => false;

  @override
  Future<void> start({required String title, required String body}) async {}

  @override
  Future<void> update({required String title, required String body}) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> resync() async {}
}
