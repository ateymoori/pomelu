import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/platform/platform_channels.dart';
import '../../../core/utils/app_logger.dart';

part 'share_channel.freezed.dart';
part 'share_channel.g.dart';

/// One item from the share bridge (`MainActivity.kt` on Android,
/// `ShareBridge.swift` on iOS, both from the same map): `text`, a `file`
/// already copied into the app cache, `skipped` with how many files were
/// left out for the size and count caps, or the `target` bot.
@freezed
abstract class SharedItem with _$SharedItem {
  const SharedItem._();

  const factory SharedItem({
    /// `text`, `file`, `skipped`, or `target`: the bot picked in the share
    /// sheet's top row (Android's Direct Share, iOS's share suggestions).
    required String type,
    String? text,

    /// The copy's absolute path, for a `file`.
    String? path,
    String? mime,

    /// The name the sharing app gave the file.
    String? name,

    /// Files left out, for `skipped`.
    @Default(0) int count,

    /// The bot's profile, for `target`.
    String? profile,
  }) = _SharedItem;

  factory SharedItem.fromJson(Map<String, dynamic> json) =>
      _$SharedItemFromJson(json);

  bool get isText => type == 'text';
  bool get isFile => type == 'file' && path != null;
  bool get isSkipped => type == 'skipped';
  bool get isTarget => type == 'target' && (profile?.isNotEmpty ?? false);

  /// The items in [raw] (a channel list of maps), malformed ones dropped.
  static List<SharedItem> listFrom(Object? raw) => [
    if (raw is List)
      for (final entry in raw) ?_parse(entry),
  ];

  static SharedItem? _parse(Object? entry) {
    if (entry is! Map) return null;
    try {
      final item = SharedItem.fromJson(Map<String, dynamic>.from(entry));
      return item.type.isEmpty ? null : item;
    } on Object catch (e) {
      log.w('share item dropped', error: e);
      return null;
    }
  }
}

/// Where the system share sheet hands its items over. A platform seam:
/// Android and iOS have [ShareChannel], any other platform [NoShareBridge].
abstract interface class ShareBridge {
  /// The share that launched the app, if any (consumed on read).
  Future<List<SharedItem>> initial();

  /// Shares that arrive while the app runs.
  Stream<List<SharedItem>> stream();
}

class NoShareBridge implements ShareBridge {
  const NoShareBridge();

  @override
  Future<List<SharedItem>> initial() async => const [];

  @override
  Stream<List<SharedItem>> stream() => const Stream.empty();
}

/// The platform channels of `MainActivity.kt` (Android) and `ShareBridge.swift`
/// (iOS), which keep one contract.
class ShareChannel implements ShareBridge {
  const ShareChannel({
    this.methods = const MethodChannel(PlatformChannels.share),
    this.events = const EventChannel(PlatformChannels.shareEvents),
  });

  final MethodChannel methods;
  final EventChannel events;

  @override
  Future<List<SharedItem>> initial() async {
    try {
      return SharedItem.listFrom(
        await methods.invokeMethod<Object?>('initial'),
      );
    } on MissingPluginException {
      return const [];
    }
  }

  @override
  Stream<List<SharedItem>> stream() =>
      events.receiveBroadcastStream().map(SharedItem.listFrom);
}
