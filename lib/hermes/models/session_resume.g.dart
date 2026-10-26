// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_resume.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionResume _$SessionResumeFromJson(Map<String, dynamic> json) =>
    _SessionResume(
      sessionId: json['session_id'] == null
          ? ''
          : const LooseString().fromJson(json['session_id']),
      storedSessionId: const LooseStringOrNull().fromJson(
        json['stored_session_id'],
      ),
      sessionKey: const LooseStringOrNull().fromJson(json['session_key']),
      resumed: const LooseStringOrNull().fromJson(json['resumed']),
      messageCount: json['message_count'] == null
          ? 0
          : const LooseInt().fromJson(json['message_count']),
      messages: json['messages'] == null
          ? const <SessionMessage>[]
          : _messagesFromJson(json['messages']),
      messagesOmitted: json['messages_omitted'] == null
          ? false
          : const LooseBool().fromJson(json['messages_omitted']),
      hydrating: json['hydrating'] == null
          ? false
          : const LooseBool().fromJson(json['hydrating']),
      running: json['running'] == null
          ? false
          : const LooseBool().fromJson(json['running']),
      status: json['status'] == null
          ? ''
          : const LooseString().fromJson(json['status']),
      info: json['info'] == null
          ? null
          : RuntimeInfo.fromJson(json['info'] as Map<String, dynamic>),
      inflight: json['inflight'] == null
          ? null
          : Inflight.fromJson(json['inflight'] as Map<String, dynamic>),
      queued: json['queued'] == null
          ? null
          : QueuedPrompt.fromJson(json['queued'] as Map<String, dynamic>),
      openRequests: json['open_requests'] == null
          ? const <Map<String, dynamic>>[]
          : const LooseMapList().fromJson(json['open_requests']),
      todoState: json['todo_state'] == null
          ? null
          : TodoPlan.fromJson(json['todo_state'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionResumeToJson(_SessionResume instance) =>
    <String, dynamic>{
      'session_id': const LooseString().toJson(instance.sessionId),
      'stored_session_id': const LooseStringOrNull().toJson(
        instance.storedSessionId,
      ),
      'session_key': const LooseStringOrNull().toJson(instance.sessionKey),
      'resumed': const LooseStringOrNull().toJson(instance.resumed),
      'message_count': const LooseInt().toJson(instance.messageCount),
      'messages': instance.messages,
      'messages_omitted': const LooseBool().toJson(instance.messagesOmitted),
      'hydrating': const LooseBool().toJson(instance.hydrating),
      'running': const LooseBool().toJson(instance.running),
      'status': const LooseString().toJson(instance.status),
      'info': instance.info,
      'inflight': instance.inflight,
      'queued': instance.queued,
      'open_requests': const LooseMapList().toJson(instance.openRequests),
      'todo_state': instance.todoState,
    };

_RuntimeInfo _$RuntimeInfoFromJson(Map<String, dynamic> json) => _RuntimeInfo(
  model: json['model'] == null
      ? ''
      : const LooseString().fromJson(json['model']),
  provider: json['provider'] == null
      ? ''
      : const LooseString().fromJson(json['provider']),
  reasoningEffort: json['reasoning_effort'] == null
      ? ''
      : const LooseString().fromJson(json['reasoning_effort']),
  running: json['running'] == null
      ? false
      : const LooseBool().fromJson(json['running']),
  version: json['version'] == null
      ? ''
      : const LooseString().fromJson(json['version']),
  usage: const LooseMap().fromJson(json['usage']),
);

Map<String, dynamic> _$RuntimeInfoToJson(_RuntimeInfo instance) =>
    <String, dynamic>{
      'model': const LooseString().toJson(instance.model),
      'provider': const LooseString().toJson(instance.provider),
      'reasoning_effort': const LooseString().toJson(instance.reasoningEffort),
      'running': const LooseBool().toJson(instance.running),
      'version': const LooseString().toJson(instance.version),
      'usage': const LooseMap().toJson(instance.usage),
    };

_Inflight _$InflightFromJson(Map<String, dynamic> json) => _Inflight(
  assistant: json['assistant'] == null
      ? ''
      : const LooseString().fromJson(json['assistant']),
  user: json['user'] == null ? '' : const LooseString().fromJson(json['user']),
  streaming: json['streaming'] == null
      ? false
      : const LooseBool().fromJson(json['streaming']),
  error: const LooseStringOrNull().fromJson(json['error']),
  status: json['status'] == null
      ? ''
      : const LooseString().fromJson(json['status']),
);

Map<String, dynamic> _$InflightToJson(_Inflight instance) => <String, dynamic>{
  'assistant': const LooseString().toJson(instance.assistant),
  'user': const LooseString().toJson(instance.user),
  'streaming': const LooseBool().toJson(instance.streaming),
  'error': const LooseStringOrNull().toJson(instance.error),
  'status': const LooseString().toJson(instance.status),
};

_QueuedPrompt _$QueuedPromptFromJson(Map<String, dynamic> json) =>
    _QueuedPrompt(
      user: json['user'] == null
          ? ''
          : const LooseString().fromJson(json['user']),
    );

Map<String, dynamic> _$QueuedPromptToJson(_QueuedPrompt instance) =>
    <String, dynamic>{'user': const LooseString().toJson(instance.user)};
