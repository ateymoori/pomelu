import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';
import 'json_parse.dart';

part 'context_breakdown.freezed.dart';
part 'context_breakdown.g.dart';

/// What fills a live session's context window: the answer of
/// `session.context_breakdown`, the same figures the Hermes desktop context
/// popover shows. Read only; it costs no model call.
///
/// [contextUsed] is the provider's own count when [contextSource] says so;
/// the category and file figures are always estimates (characters / 4).
@freezed
abstract class ContextBreakdown with _$ContextBreakdown {
  const ContextBreakdown._();

  const factory ContextBreakdown({
    @JsonKey(fromJson: _categoriesFromJson)
    @Default(<ContextCategory>[])
    List<ContextCategory> categories,
    @JsonKey(name: 'context_max') @LooseInt() @Default(0) int contextMax,
    @JsonKey(name: 'context_used') @LooseInt() @Default(0) int contextUsed,
    @JsonKey(name: 'context_percent') @LooseDouble() double? contextPercent,

    @JsonKey(name: 'context_source')
    @LooseString()
    @Default('')
    String contextSource,
    @LooseString() @Default('') String model,
    @JsonKey(name: 'context_files', fromJson: _filesFromJson)
    @Default(<ContextFile>[])
    List<ContextFile> contextFiles,
  }) = _ContextBreakdown;

  factory ContextBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ContextBreakdownFromJson(json);

  bool get isEmpty => contextMax <= 0;

  int get remaining =>
      contextMax - contextUsed < 0 ? 0 : contextMax - contextUsed;

  /// Window share in use, 0..1.
  double get fraction =>
      contextMax <= 0 ? 0 : (contextUsed / contextMax).clamp(0.0, 1.0);
}

/// Wire values of [ContextBreakdown.contextSource]. Any other value
/// (`local_estimate`: no provider count yet) is an estimate only.
abstract final class ContextSource {
  static const String provider = 'provider_usage';
  static const String providerPlusEstimate = 'provider_usage_plus_estimate';
}

/// One part of the window: system prompt, tool definitions, rules, skills,
/// MCP, sub-agents, memory or conversation.
@freezed
abstract class ContextCategory with _$ContextCategory {
  const factory ContextCategory({
    @LooseString() @Default('') String id,

    @LooseString() @Default('') String label,
    @LooseInt() @Default(0) int tokens,
  }) = _ContextCategory;

  factory ContextCategory.fromJson(Map<String, dynamic> json) =>
      _$ContextCategoryFromJson(json);
}

/// Wire ids of [ContextCategory.id], in the gateway's display order.
abstract final class ContextCategoryId {
  static const String systemPrompt = 'system_prompt';
  static const String tools = 'tool_definitions';
  static const String rules = 'rules';
  static const String skills = 'skills';
  static const String mcp = 'mcp';
  static const String subagents = 'subagent_definitions';
  static const String memory = 'memory';
  static const String conversation = 'conversation';
}

/// A context file the bot reads into its prompt (`SOUL.md`, `AGENTS.md`, ...).
@freezed
abstract class ContextFile with _$ContextFile {
  const ContextFile._();

  const factory ContextFile({
    @LooseString() @Default('') String label,
    @LooseString() @Default('') String path,
    @JsonKey(name: 'est_tokens') @LooseInt() @Default(0) int tokens,
    @LooseBool() @Default(false) bool loaded,

    /// `loaded`, `truncated`, `flagged`, `shadowed`, `blocked`, `empty`,
    /// `unreadable` or `suppressed`.
    @LooseString() @Default('') String status,
  }) = _ContextFile;

  factory ContextFile.fromJson(Map<String, dynamic> json) =>
      _$ContextFileFromJson(json);
}

/// The rows of `categories`; a malformed row is left out.
List<ContextCategory> _categoriesFromJson(Object? json) =>
    parseRows(json, ContextCategory.fromJson, what: 'context category');

/// The rows of `context_files`; a malformed row is left out.
List<ContextFile> _filesFromJson(Object? json) =>
    parseRows(json, ContextFile.fromJson, what: 'context file');
