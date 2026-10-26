import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'session_summary.freezed.dart';
part 'session_summary.g.dart';

/// A sidebar row. Built from REST `GET /api/profiles/sessions` (rich) or from
/// RPC `session.list` (six fields) — optional fields stay null on the latter.
@freezed
abstract class SessionSummary with _$SessionSummary {
  const SessionSummary._();

  const factory SessionSummary({
    @LooseString() @Default('') String id,
    @LooseString() @Default('') String title,
    @LooseString() @Default('') String preview,
    @LooseString() @Default('') String profile,
    @LooseString() @Default('') String model,
    @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)
    DateTime? lastActive,
    @JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds)
    DateTime? startedAt,
    @JsonKey(name: 'message_count') @LooseInt() @Default(0) int messageCount,
    @JsonKey(name: 'parent_session_id')
    @LooseStringOrNull()
    String? parentSessionId,
    @JsonKey(name: 'resolved_id') @LooseStringOrNull() String? resolvedId,

    /// Why the session ended (`compression` for a compaction rotation);
    /// only on a single-session read.
    @JsonKey(name: 'end_reason') @LooseStringOrNull() String? endReason,
    @LooseBool() @Default(false) bool hidden,
    @JsonKey(name: 'is_active') @LooseBool() @Default(false) bool isActive,
  }) = _SessionSummary;

  factory SessionSummary.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryFromJson(json);

  String get openId => resolvedId ?? id;
}
