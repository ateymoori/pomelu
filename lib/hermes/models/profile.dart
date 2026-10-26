import 'package:freezed_annotation/freezed_annotation.dart';

import '../hermes_constants.dart';
import 'json_converters.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// One bot (= Hermes profile) from `profiles.list`.
@freezed
abstract class HermesProfile with _$HermesProfile {
  const HermesProfile._();

  const factory HermesProfile({
    @LooseString() @Default('') String name,
    @JsonKey(name: 'is_default') @LooseBool() @Default(false) bool isDefault,
    @LooseString() @Default('') String model,
    @LooseString() @Default('') String provider,
    @LooseString() @Default('') String description,
    @JsonKey(name: 'display_name')
    @LooseString()
    @Default('')
    String displayName,
    @JsonKey(name: 'last_session') SessionPreview? lastSession,
    @JsonKey(name: 'worker_session') WorkerSession? workerSession,
    @JsonKey(name: 'canonical_session') CanonicalSession? canonicalSession,
    @JsonKey(name: 'ui_meta') @LooseMap() Map<String, dynamic>? uiMeta,

    /// Per-key write counters of [uiMeta], for a compare-and-set; null on a
    /// gateway without them.
    @JsonKey(name: 'ui_meta_revisions')
    @LooseMap()
    Map<String, dynamic>? uiMetaRevisions,
  }) = _HermesProfile;

  factory HermesProfile.fromJson(Map<String, dynamic> json) =>
      _$HermesProfileFromJson(json);

  BotMeta? get botMeta {
    final raw = uiMeta?[HermesProtocol.botsMetaKey];
    if (raw is Map<String, dynamic>) return BotMeta.fromJson(raw);
    return null;
  }

  String get title {
    final t = botMeta?.title;
    if (t != null && t.isNotEmpty) return t;
    if (displayName.isNotEmpty) return displayName;
    return name;
  }

  bool get isHidden => botMeta?.hidden ?? false;

  DateTime? get lastActivity {
    final a = canonicalSession?.lastActive;
    final b = lastSession?.lastActive;
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  /// True when a background worker heartbeat is fresh.
  bool isWorking(DateTime now, Duration freshness) {
    final t = workerSession?.lastActive;
    return t != null && now.difference(t) < freshness;
  }
}

/// A short view of one session in a `profiles.list` row.
@freezed
abstract class SessionPreview with _$SessionPreview {
  const SessionPreview._();

  const factory SessionPreview({
    @LooseString() @Default('') String id,
    @LooseString() @Default('') String title,
    @LooseString() @Default('') String preview,
    @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)
    DateTime? lastActive,
    @JsonKey(name: 'message_count') @LooseInt() @Default(0) int messageCount,
  }) = _SessionPreview;

  factory SessionPreview.fromJson(Map<String, dynamic> json) =>
      _$SessionPreviewFromJson(json);
}

/// The bot's canonical "Bot Chat" session.
@freezed
abstract class CanonicalSession with _$CanonicalSession {
  const CanonicalSession._();

  const factory CanonicalSession({
    @LooseString() @Default('') String id,

    /// The live tip of a compacted chat.
    @JsonKey(name: 'resolved_id') @LooseStringOrNull() String? resolvedId,
    @LooseString() @Default('') String title,
    @LooseString() @Default('') String preview,
    @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)
    DateTime? lastActive,
    @JsonKey(name: 'message_count') @LooseInt() @Default(0) int messageCount,
  }) = _CanonicalSession;

  factory CanonicalSession.fromJson(Map<String, dynamic> json) =>
      _$CanonicalSessionFromJson(json);

  String get openId => resolvedId ?? id;
}

/// The session a background worker of the bot runs in.
@freezed
abstract class WorkerSession with _$WorkerSession {
  const factory WorkerSession({
    @LooseString() @Default('') String id,
    @LooseString() @Default('') String title,
    @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)
    DateTime? lastActive,
  }) = _WorkerSession;

  factory WorkerSession.fromJson(Map<String, dynamic> json) =>
      _$WorkerSessionFromJson(json);
}

/// How the bot looks and sorts in the roster.
@freezed
abstract class BotMeta with _$BotMeta {
  const factory BotMeta({
    @LooseStringOrNull() String? color,
    @LooseStringOrNull() String? title,
    @LooseStringOrNull() String? description,
    @LooseStringOrNull() String? image,
    @LooseStringOrNull() String? shape,
    @LooseStringOrNull() String? group,
    @LooseBool() @Default(false) bool hidden,
  }) = _BotMeta;

  factory BotMeta.fromJson(Map<String, dynamic> json) =>
      _$BotMetaFromJson(json);
}
