// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_payloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GatewayNotice _$GatewayNoticeFromJson(Map<String, dynamic> json) =>
    _GatewayNotice(
      text: json['text'] == null ? '' : const _Trimmed().fromJson(json['text']),
      level: json['level'] == null
          ? GatewayNotice.levelInfo
          : _level(json['level']),
      key: json['key'] == null ? '' : const LooseString().fromJson(json['key']),
      id: json['id'] == null ? '' : const LooseString().fromJson(json['id']),
      ttlMs: const LooseIntOrNull().fromJson(json['ttl_ms']),
    );

_BackgroundResult _$BackgroundResultFromJson(Map<String, dynamic> json) =>
    _BackgroundResult(
      taskId: json['task_id'] == null
          ? ''
          : const LooseString().fromJson(json['task_id']),
      text: json['text'] == null ? '' : const _Trimmed().fromJson(json['text']),
    );

_SessionUsage _$SessionUsageFromJson(
  Map<String, dynamic> json,
) => _SessionUsage(
  model: json['model'] == null
      ? ''
      : const LooseString().fromJson(json['model']),
  input: json['input'] == null ? 0 : const LooseInt().fromJson(json['input']),
  output: json['output'] == null
      ? 0
      : const LooseInt().fromJson(json['output']),
  reasoning: json['reasoning'] == null
      ? 0
      : const LooseInt().fromJson(json['reasoning']),
  total: json['total'] == null ? 0 : const LooseInt().fromJson(json['total']),
  calls: json['calls'] == null ? 0 : const LooseInt().fromJson(json['calls']),
  compressions: json['compressions'] == null
      ? 0
      : const LooseInt().fromJson(json['compressions']),
  cacheHitPct: const LooseIntOrNull().fromJson(json['cache_hit_pct']),
  contextPct: const LooseDouble().fromJson(
    _contextPct(json, 'context_percent'),
  ),
  contextUsed: const LooseIntOrNull().fromJson(json['context_used']),
  contextMax: const LooseIntOrNull().fromJson(json['context_max']),
);

_SessionRef _$SessionRefFromJson(Map<String, dynamic> json) => _SessionRef(
  storedId: json['stored_session_id'] == null
      ? ''
      : const LooseString().fromJson(json['stored_session_id']),
  profile: json['profile_name'] == null
      ? ''
      : const LooseString().fromJson(json['profile_name']),
  title: json['title'] == null
      ? ''
      : const LooseString().fromJson(json['title']),
);
