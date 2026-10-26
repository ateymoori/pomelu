import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'session_message.freezed.dart';
part 'session_message.g.dart';

/// Flattened transcript row from `session.history` / `session.resume`.
/// Tool rows carry `name`/`context`; others carry `text`. A stored row
/// from REST `GET /api/sessions/{id}/messages` carries `content` (and
/// `display_content`, `tool_name`) instead; [body] and [toolName] read both.
@freezed
abstract class SessionMessage with _$SessionMessage {
  const SessionMessage._();

  const factory SessionMessage({
    @LooseString() @Default('') String role,
    @LooseString() @Default('') String text,
    @JsonKey(fromJson: dateTimeFromEpochSeconds) DateTime? timestamp,
    @JsonKey(name: 'row_id') @LooseIntOrNull() int? rowId,

    @LooseIntOrNull() int? id,
    @LooseStringOrNull() String? reasoning,
    @JsonKey(name: 'reasoning_content')
    @LooseStringOrNull()
    String? reasoningContent,
    @JsonKey(name: 'display_kind') @LooseStringOrNull() String? displayKind,
    // tool rows
    @LooseStringOrNull() String? name,
    @LooseString() @Default('') String context,
    // stored (REST) rows
    @ContentText() @Default('') String content,
    @JsonKey(name: 'display_content')
    @LooseStringOrNull()
    String? displayContent,
    @JsonKey(name: 'tool_name') @LooseStringOrNull() String? storedToolName,
  }) = _SessionMessage;

  factory SessionMessage.fromJson(Map<String, dynamic> json) =>
      _$SessionMessageFromJson(json);

  /// The text to show: `text`, else the stored row's display projection,
  /// else its `content`.
  String get body => text.isNotEmpty ? text : (displayContent ?? content);

  String? get toolName => name ?? storedToolName;

  /// The row id that survives a reload.
  int? get durableId => rowId ?? id;

  bool get isTool => role == 'tool';

  bool get isUser => role == 'user';

  bool get isAssistant => role == 'assistant';

  bool get isHidden => displayKind == 'hidden';

  String? get reasoningText {
    final r = reasoning ?? reasoningContent;
    return (r == null || r.isEmpty) ? null : r;
  }
}
