import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/router.dart';
import '../../../app/routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/platform/app_shortcuts.dart';
import '../../../core/utils/data_url.dart';
import '../../../hermes/hermes_constants.dart';
import '../domain/bot_group.dart';
import 'shortcut_icon.dart';
import 'sidebar_providers.dart';

part 'bot_shortcuts.g.dart';

/// Keeps the bots the system offers (the app icon's menu, the share sheet's
/// top row) on the sidebar's first ones, each with its picture where the
/// system shows one; picking one opens its chat. Alive for the whole app.
@Riverpod(keepAlive: true)
void botShortcuts(Ref ref) {
  final shortcuts = ref.watch(appShortcutsProvider);
  unawaited(
    shortcuts.listen(
      (profile) => openFromOutside(
        ref.read(appRouterProvider),
        Routes.chatPath(profile),
      ),
    ),
  );
  // What the menu shows now, by its parts: an entry's picture is redrawn
  // only when its bot, title or picture changes.
  var shown = const <(String, String, String?)>[];
  var turn = 0;
  Future<void> publish(List<BotGroup> bots) async {
    final mine = ++turn;
    final pictures = shortcuts.iconFill > 0
        ? await Future.wait([
            for (final b in bots)
              ref.read(profileAvatarProvider(b.name).future),
          ])
        : List<String?>.filled(bots.length, null);
    final parts = [
      for (final (i, b) in bots.indexed) (b.name, b.title, pictures[i]),
    ];
    // A reload that changes none of them leaves the menu as it is.
    if (mine != turn || listEquals(parts, shown)) return;
    final icons = shortcuts.iconFill > 0
        ? await Future.wait([
            for (final (_, title, url) in parts)
              shortcutIcon(
                title: title,
                fill: shortcuts.iconFill,
                picture: decodeDataUrl(url),
              ),
          ])
        : List<Uint8List?>.filled(bots.length, null);
    if (mine != turn) return;
    final set = await shortcuts.set([
      for (final (i, (id, title, _)) in parts.indexed)
        (
          id: id,
          title: title,
          link: Uri(
            scheme: AppConfig.deepLinkScheme,
            host: AppConfig.deepLinkChatHost,
            queryParameters: {AppConfig.deepLinkProfileParam: id},
          ),
          icon: icons[i],
        ),
    ]);
    // Refused (Android, in the background): the next reload tries again.
    if (set && mine == turn) shown = parts;
  }

  ref.listen(profilesProvider, (_, profiles) {
    final bots = profiles.value;
    if (bots == null) return;
    final ordered = BotGroup.build(
      profiles: bots,
      now: DateTime.now().toUtc(),
      workerFreshness: HermesTimeouts.workerFreshness,
    );
    unawaited(publish(ordered.take(AppConfig.botShortcuts).toList()));
  }, fireImmediately: true);
}
