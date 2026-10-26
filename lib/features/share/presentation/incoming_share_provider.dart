import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/routes.dart';
import '../../../core/platform/platform_info.dart';
import '../../chat/domain/chat_target.dart';
import '../data/share_channel.dart';
import '../data/share_intake_service.dart';
import '../domain/incoming_share.dart';
import 'composer_seeds_provider.dart';

part 'incoming_share_provider.g.dart';

/// Shares and links. Android's share bridge and iOS's share extension speak
/// one channel; other platforms get links alone.
@Riverpod(keepAlive: true)
ShareIntakeService shareIntakeService(Ref ref) {
  final service = ShareIntakeService(
    bridge: ref.watch(platformInfoProvider).isMobile
        ? const ShareChannel()
        : const NoShareBridge(),
    links: AppLinks().uriLinkStream,
  );
  ref.onDispose(service.dispose);
  return service;
}

/// The share waiting for the user to pick a bot. Kept too: a link that only
/// names a bot (it says where to go), and a share whose files were all left
/// out (the picker says why nothing came).
@Riverpod(keepAlive: true)
class PendingShare extends _$PendingShare {
  static bool _worthKeeping(IncomingShare share) =>
      !share.isEmpty || share.hasTarget || share.hasNotice;

  @override
  IncomingShare? build() {
    final service = ref.watch(shareIntakeServiceProvider);
    final sub = service.shares.listen((s) {
      if (_worthKeeping(s)) state = s;
    });
    ref.onDispose(sub.cancel);
    unawaited(
      service.initial().then((s) {
        if (s != null && ref.mounted && _worthKeeping(s)) state = s;
      }),
    );
    return null;
  }

  /// Routed or dismissed.
  void consume() => state = null;

  /// Drops the share [id] only: a newer one that came meanwhile stays.
  void dismiss(String id) {
    if (state?.id == id) state = null;
  }

  /// Seeds [target]'s composer with [share] and returns its chat route.
  String routeTo(ChatTarget target, IncomingShare share) {
    final seed = ComposerSeed(text: share.text, attachments: share.files);
    if (!seed.isEmpty) {
      ref.read(composerSeedsProvider.notifier).put(target.key, seed);
    }
    consume();
    return Routes.chatPath(target.profile);
  }
}
