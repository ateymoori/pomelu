/// Typed views of the session-wide event payloads: notices, background
/// results, usage and identity. Wire shapes read off a [GatewayEvent], not
/// stored models; the session id comes from the event.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/json_converters.dart';
import 'gateway_event.dart';

part 'event_payloads.freezed.dart';
part 'event_payloads.g.dart';

/// `notification.show` — a toast/notice pushed by the agent or the gateway.
///
/// Payload: `{text, level, kind, ttl_ms, key, id}`. [key] is a replace-in-place
/// identity: a later notice with the same key supersedes the earlier one, and
/// `notification.clear {key}` retracts it.
@Freezed(toJson: false)
abstract class GatewayNotice with _$GatewayNotice {
  const GatewayNotice._();

  const factory GatewayNotice({
    @JsonKey(includeFromJson: false) @Default('') String sessionId,
    @_Trimmed() @Default('') String text,
    @JsonKey(fromJson: _level) @Default(GatewayNotice.levelInfo) String level,
    @LooseString() @Default('') String key,
    @LooseString() @Default('') String id,
    @JsonKey(name: 'ttl_ms') @LooseIntOrNull() int? ttlMs,
  }) = _GatewayNotice;

  factory GatewayNotice.fromJson(Map<String, dynamic> json) =>
      _$GatewayNoticeFromJson(json);

  static const String levelInfo = 'info';
  static const String levelWarning = 'warning';
  static const String levelError = 'error';

  bool get isError => level == levelError;

  String get dedupeKey => key.isNotEmpty
      ? '$sessionId/$key'
      : (id.isNotEmpty ? '$sessionId/$id' : '$sessionId/$text');

  /// Reads a `notification.show` event; null for any other event or an
  /// empty text.
  static GatewayNotice? fromEvent(GatewayEvent e) {
    if (e.type != EventNames.notificationShow) return null;
    final notice = GatewayNotice.fromJson(e.payload ?? const {});
    return notice.text.isEmpty ? null : notice.copyWith(sessionId: e.sessionId);
  }

  /// `notification.clear {key}` → the key to retract, or null.
  static String? clearedKey(GatewayEvent e) {
    if (e.type != EventNames.notificationClear) return null;
    final key = const LooseString().fromJson(e['key']);
    return key.isEmpty ? null : '${e.sessionId}/$key';
  }
}

String _level(Object? json) {
  final level = const LooseString().fromJson(json);
  return level.isEmpty ? GatewayNotice.levelInfo : level;
}

/// `background.complete` — a delegated/background side-agent finished and its
/// answer lands on the *parent* session. Payload: `{task_id, text}`.
@Freezed(toJson: false)
abstract class BackgroundResult with _$BackgroundResult {
  const BackgroundResult._();

  const factory BackgroundResult({
    @JsonKey(includeFromJson: false) @Default('') String sessionId,
    @JsonKey(name: 'task_id') @LooseString() @Default('') String taskId,
    @_Trimmed() @Default('') String text,
  }) = _BackgroundResult;

  factory BackgroundResult.fromJson(Map<String, dynamic> json) =>
      _$BackgroundResultFromJson(json);

  bool get isError => text.startsWith('error: ');

  /// Reads a `background.complete` event; null for any other event or an
  /// empty one.
  static BackgroundResult? fromEvent(GatewayEvent e) {
    if (e.type != EventNames.backgroundComplete) return null;
    final result = BackgroundResult.fromJson(e.payload ?? const {});
    if (result.taskId.isEmpty && result.text.isEmpty) return null;
    return result.copyWith(sessionId: e.sessionId);
  }
}

/// `session.usage` — live token/cost counters for one session.
/// Payload: `{usage: {model, input, output, reasoning, total, calls, ...}}`.
/// Fields the backend cannot compute are *omitted*, not zeroed, so they stay
/// nullable here rather than being faked.
@Freezed(toJson: false)
abstract class SessionUsage with _$SessionUsage {
  const SessionUsage._();

  const factory SessionUsage({
    @JsonKey(includeFromJson: false) @Default('') String sessionId,
    @LooseString() @Default('') String model,
    @LooseInt() @Default(0) int input,
    @LooseInt() @Default(0) int output,
    @LooseInt() @Default(0) int reasoning,
    @LooseInt() @Default(0) int total,
    @LooseInt() @Default(0) int calls,
    @LooseInt() @Default(0) int compressions,
    @JsonKey(name: 'cache_hit_pct') @LooseIntOrNull() int? cacheHitPct,

    /// `context_percent`, else the older `context_pct`.
    @JsonKey(name: 'context_percent', readValue: _contextPct)
    @LooseDouble()
    double? contextPct,
    @JsonKey(name: 'context_used') @LooseIntOrNull() int? contextUsed,
    @JsonKey(name: 'context_max') @LooseIntOrNull() int? contextMax,
  }) = _SessionUsage;

  factory SessionUsage.fromJson(Map<String, dynamic> json) =>
      _$SessionUsageFromJson(json);

  bool get isEmpty => total == 0 && input == 0 && output == 0;

  /// Events whose payload carries a `usage` map: the live ticks during a
  /// turn, the final count when the turn ends, and the session's info.
  static const Set<String> carriers = {
    EventNames.sessionUsage,
    EventNames.messageComplete,
    EventNames.sessionInfo,
  };

  /// Reads the `usage` map of a [carriers] event; null for any other event
  /// or no `usage` map.
  static SessionUsage? fromEvent(GatewayEvent e) {
    if (!carriers.contains(e.type)) return null;
    return fromMap(e.sessionId, e['usage']);
  }

  /// Reads one `usage` map (an event's, or `info.usage` of a resume); null
  /// when [raw] is not a map.
  static SessionUsage? fromMap(String sessionId, Object? raw) => raw is Map
      ? SessionUsage.fromJson(raw.cast<String, dynamic>())
            .copyWith(sessionId: sessionId)
      : null;
}

Object? _contextPct(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['context_pct'];

/// Identity of a live session, learned from `session.info`.
///
/// The wire uses two ids: the runtime `session_id` every event carries, and
/// the durable `stored_session_id` the app's routes are keyed by. Deep links
/// need the durable one plus the profile, so the mapping is captured here.
@Freezed(toJson: false)
abstract class SessionRef with _$SessionRef {
  const SessionRef._();

  const factory SessionRef({
    @JsonKey(includeFromJson: false) @Default('') String runtimeId,
    @JsonKey(name: 'stored_session_id')
    @LooseString()
    @Default('')
    String storedId,
    @JsonKey(name: 'profile_name') @LooseString() @Default('') String profile,
    @LooseString() @Default('') String title,
  }) = _SessionRef;

  factory SessionRef.fromJson(Map<String, dynamic> json) =>
      _$SessionRefFromJson(json);

  bool get canDeepLink => profile.isNotEmpty;

  /// This ref with the non-empty fields of [other] laid over it.
  SessionRef merge(SessionRef other) => copyWith(
    storedId: other.storedId.isNotEmpty ? other.storedId : storedId,
    profile: other.profile.isNotEmpty ? other.profile : profile,
    title: other.title.isNotEmpty ? other.title : title,
  );

  /// Reads a session-scoped `session.info` event; null otherwise.
  static SessionRef? fromEvent(GatewayEvent e) {
    if (e.type != EventNames.sessionInfo || !e.isSessionScoped) return null;
    return SessionRef.fromJson(e.payload ?? const {})
        .copyWith(runtimeId: e.sessionId);
  }
}

/// A string from anything, trimmed.
class _Trimmed implements JsonConverter<String, Object?> {
  const _Trimmed();

  @override
  String fromJson(Object? json) => const LooseString().fromJson(json).trim();

  @override
  Object? toJson(String object) => object;
}
