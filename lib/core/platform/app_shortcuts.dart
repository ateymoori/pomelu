import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/app_logger.dart';
import 'platform_channels.dart';
import 'platform_info.dart';

part 'app_shortcuts.g.dart';

/// One bot for the system: an entry of the app icon's menu, and a target in
/// the share sheet's top row. [id] comes back when it is picked, or [link]
/// opens; [icon] is a PNG where the system shows pictures.
typedef AppShortcut = ({String id, String title, Uri link, Uint8List? icon});

/// The bots the system offers outside the app: the menu a long press on the
/// app icon opens, and the share sheet's top row.
abstract interface class AppShortcuts {
  /// Share of an icon's side the round picture fills; 0 when the system
  /// shows none, so [AppShortcut.icon] is not worth drawing.
  double get iconFill;

  /// [onPick] gets the id of an entry picked, also one that launched the
  /// app.
  Future<void> listen(void Function(String id) onPick);

  /// The bots offered now; false when the system refused them (Android
  /// limits how often an app in the background may change them).
  Future<bool> set(List<AppShortcut> items);

  /// The user wrote to bot [id]: the share sheet ranks its top row by this.
  Future<void> used(String id);
}

/// No such menu.
class NoAppShortcuts implements AppShortcuts {
  const NoAppShortcuts();

  @override
  double get iconFill => 0;

  @override
  Future<void> listen(void Function(String id) onPick) async {}

  @override
  Future<bool> set(List<AppShortcut> items) async => true;

  @override
  Future<void> used(String id) async {}
}

/// Android's app shortcuts (`BotShortcuts.kt`), each with its picture as an
/// adaptive icon, also Direct Share targets. A pick opens the entry's link,
/// as any deep link.
class AndroidAppShortcuts implements AppShortcuts {
  const AndroidAppShortcuts();

  static const _channel = MethodChannel(PlatformChannels.shortcuts);

  /// An adaptive icon: the launcher shows the middle 72 of its 108 dp.
  @override
  double get iconFill => 72 / 108;

  @override
  Future<void> listen(void Function(String id) onPick) async {}

  @override
  Future<bool> set(List<AppShortcut> items) => _invoke('set', {
    'items': [
      for (final item in items)
        {
          'id': item.id,
          'title': item.title,
          'link': item.link.toString(),
          'icon': item.icon,
        },
    ],
  });

  @override
  Future<void> used(String id) => _invoke('used', {'id': id});

  Future<bool> _invoke(String method, Object arguments) async {
    try {
      return await _channel.invokeMethod<bool>(method, arguments) ?? false;
    } on PlatformException catch (e) {
      log.w('app shortcuts: $method failed', error: e);
      return false;
    }
  }
}

/// iOS's Home Screen quick actions (`quick_actions`), which take no
/// picture, only a monochrome symbol; and its share suggestions: each bot
/// is told to iOS as a conversation (`BotSuggestions` in `AppDelegate.swift`)
/// with its picture, which the share sheet then offers.
class IosAppShortcuts implements AppShortcuts {
  const IosAppShortcuts();

  static const _channel = MethodChannel(PlatformChannels.shortcuts);
  final _plugin = const QuickActions();

  /// The share sheet crops the picture to a circle itself.
  @override
  double get iconFill => 1;

  @override
  Future<void> listen(void Function(String id) onPick) async {
    try {
      await _plugin.initialize(onPick);
    } on Object catch (e) {
      log.w('app shortcuts unavailable', error: e);
    }
  }

  /// The quick actions and the share suggestions apart: one failing never
  /// keeps the other.
  @override
  Future<bool> set(List<AppShortcut> items) async {
    var done = true;
    try {
      await _plugin.setShortcutItems([
        for (final item in items)
          ShortcutItem(type: item.id, localizedTitle: item.title),
      ]);
    } on Object catch (e) {
      log.w('quick actions not set', error: e);
      done = false;
    }
    final suggested = await _invoke('set', {
      'items': [
        for (final item in items)
          {'id': item.id, 'title': item.title, 'icon': item.icon},
      ],
    });
    return done && suggested;
  }

  @override
  Future<void> used(String id) => _invoke('used', {'id': id});

  Future<bool> _invoke(String method, Object arguments) async {
    try {
      return await _channel.invokeMethod<bool>(method, arguments) ?? false;
    } on PlatformException catch (e) {
      log.w('share suggestions: $method failed', error: e);
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
AppShortcuts appShortcuts(Ref ref) {
  final platform = ref.watch(platformInfoProvider);
  if (platform.isAndroid) return const AndroidAppShortcuts();
  if (platform.isIOS) return const IosAppShortcuts();
  return const NoAppShortcuts();
}
