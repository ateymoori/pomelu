import 'dart:async';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/models/local_attachment.dart';
import '../domain/incoming_share.dart';
import 'share_channel.dart';

/// Turns the share sheet ([ShareBridge]) and the app's links into
/// [IncomingShare]s.
class ShareIntakeService {
  /// [links] is every link that opens the app: `app_links` replays the one
  /// that launched it to its first listener, so it is never read twice.
  ShareIntakeService({
    this.bridge = const NoShareBridge(),
    this.links = const Stream.empty(),
    this.uuid = const Uuid(),
  });

  final ShareBridge bridge;
  final Stream<Uri> links;
  final Uuid uuid;
  final _controller = StreamController<IncomingShare>.broadcast();
  final _subs = <StreamSubscription<Object?>>[];

  /// Shares and links that arrive while the app runs, and a link that
  /// launched it.
  Stream<IncomingShare> get shares {
    _start();
    return _controller.stream;
  }

  /// The share-sheet share that launched the app, if any.
  Future<IncomingShare?> initial() async {
    _start();
    try {
      final items = await bridge.initial();
      if (items.isNotEmpty) return _fromItems(items);
    } on Object catch (e, st) {
      log.w('share intake initial failed', error: e, stackTrace: st);
    }
    return null;
  }

  void _start() {
    if (_subs.isNotEmpty) return;
    _subs
      ..add(
        bridge.stream().listen((items) {
          final share = _fromItems(items);
          if (!share.isEmpty || share.hasNotice) _controller.add(share);
        }, onError: (Object e) => log.w('share stream error', error: e)),
      )
      ..add(
        links.listen((uri) {
          final share = fromLink(uri);
          if (share != null) _controller.add(share);
        }, onError: (Object e) => log.w('link stream error', error: e)),
      );
  }

  IncomingShare _fromItems(List<SharedItem> items) {
    final files = <LocalAttachment>[];
    final text = StringBuffer();
    var skipped = 0;
    String? profile;
    for (final item in items) {
      if (item.isTarget) profile = item.profile;
      if (item.isText) text.writeln(item.text);
      if (item.isSkipped) skipped += item.count;
      if (!item.isFile) continue;
      final file = File(item.path!);
      if (!file.existsSync()) continue;
      final name = item.name ?? file.uri.pathSegments.last;
      final mime = LocalAttachment.mimeForPath(name, hint: item.mime);
      files.add(
        LocalAttachment(
          id: uuid.v4(),
          path: file.path,
          name: name,
          mimeType: mime,
          sizeBytes: file.lengthSync(),
          kind: LocalAttachment.kindForMime(mime),
        ),
      );
    }
    return IncomingShare(
      id: uuid.v4(),
      profile: profile,
      files: files,
      text: text.toString().trim(),
      skipped: skipped,
    );
  }

  /// `pomelu://chat?profile=<name>&text=<msg>`, or null for any other link.
  IncomingShare? fromLink(Uri uri) {
    if (uri.scheme != AppConfig.deepLinkScheme ||
        uri.host != AppConfig.deepLinkChatHost) {
      return null;
    }
    final q = uri.queryParameters;
    return IncomingShare(
      id: uuid.v4(),
      profile: q[AppConfig.deepLinkProfileParam],
      text: q[AppConfig.deepLinkTextParam] ?? '',
    );
  }

  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _controller.close();
  }
}
