// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_resume.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionResume {

@JsonKey(name: 'session_id')@LooseString() String get sessionId;@JsonKey(name: 'stored_session_id')@LooseStringOrNull() String? get storedSessionId;@JsonKey(name: 'session_key')@LooseStringOrNull() String? get sessionKey;@LooseStringOrNull() String? get resumed;@JsonKey(name: 'message_count')@LooseInt() int get messageCount;@JsonKey(fromJson: _messagesFromJson) List<SessionMessage> get messages;@JsonKey(name: 'messages_omitted')@LooseBool() bool get messagesOmitted;@LooseBool() bool get hydrating;@LooseBool() bool get running;@LooseString() String get status; RuntimeInfo? get info; Inflight? get inflight; QueuedPrompt? get queued;/// Questions still waiting on this session, as sent to the router: a live
/// session reattached by a resume lists them here.
@JsonKey(name: 'open_requests')@LooseMapList() List<Map<String, dynamic>> get openRequests;/// The agent's plan as last written; null when it keeps none.
@JsonKey(name: 'todo_state') TodoPlan? get todoState;
/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionResumeCopyWith<SessionResume> get copyWith => _$SessionResumeCopyWithImpl<SessionResume>(this as SessionResume, _$identity);

  /// Serializes this SessionResume to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionResume;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionResume&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.storedSessionId, _this.storedSessionId) || other.storedSessionId == _this.storedSessionId)&&(identical(other.sessionKey, _this.sessionKey) || other.sessionKey == _this.sessionKey)&&(identical(other.resumed, _this.resumed) || other.resumed == _this.resumed)&&(identical(other.messageCount, _this.messageCount) || other.messageCount == _this.messageCount)&&const DeepCollectionEquality().equals(other.messages, _this.messages)&&(identical(other.messagesOmitted, _this.messagesOmitted) || other.messagesOmitted == _this.messagesOmitted)&&(identical(other.hydrating, _this.hydrating) || other.hydrating == _this.hydrating)&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.info, _this.info) || other.info == _this.info)&&(identical(other.inflight, _this.inflight) || other.inflight == _this.inflight)&&(identical(other.queued, _this.queued) || other.queued == _this.queued)&&const DeepCollectionEquality().equals(other.openRequests, _this.openRequests)&&(identical(other.todoState, _this.todoState) || other.todoState == _this.todoState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionResume;
  return Object.hash(runtimeType,_this.sessionId,_this.storedSessionId,_this.sessionKey,_this.resumed,_this.messageCount,const DeepCollectionEquality().hash(_this.messages),_this.messagesOmitted,_this.hydrating,_this.running,_this.status,_this.info,_this.inflight,_this.queued,const DeepCollectionEquality().hash(_this.openRequests),_this.todoState);
}

@override
String toString() {
  final _this = this as SessionResume;
  return 'SessionResume(sessionId: ${_this.sessionId}, storedSessionId: ${_this.storedSessionId}, sessionKey: ${_this.sessionKey}, resumed: ${_this.resumed}, messageCount: ${_this.messageCount}, messages: ${_this.messages}, messagesOmitted: ${_this.messagesOmitted}, hydrating: ${_this.hydrating}, running: ${_this.running}, status: ${_this.status}, info: ${_this.info}, inflight: ${_this.inflight}, queued: ${_this.queued}, openRequests: ${_this.openRequests}, todoState: ${_this.todoState})';
}


}

/// @nodoc
abstract mixin class $SessionResumeCopyWith<$Res>  {
  factory $SessionResumeCopyWith(SessionResume value, $Res Function(SessionResume) _then) = _$SessionResumeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id')@LooseString() String sessionId,@JsonKey(name: 'stored_session_id')@LooseStringOrNull() String? storedSessionId,@JsonKey(name: 'session_key')@LooseStringOrNull() String? sessionKey,@LooseStringOrNull() String? resumed,@JsonKey(name: 'message_count')@LooseInt() int messageCount,@JsonKey(fromJson: _messagesFromJson) List<SessionMessage> messages,@JsonKey(name: 'messages_omitted')@LooseBool() bool messagesOmitted,@LooseBool() bool hydrating,@LooseBool() bool running,@LooseString() String status, RuntimeInfo? info, Inflight? inflight, QueuedPrompt? queued,@JsonKey(name: 'open_requests')@LooseMapList() List<Map<String, dynamic>> openRequests,@JsonKey(name: 'todo_state') TodoPlan? todoState
});


$RuntimeInfoCopyWith<$Res>? get info;$InflightCopyWith<$Res>? get inflight;$QueuedPromptCopyWith<$Res>? get queued;$TodoPlanCopyWith<$Res>? get todoState;

}
/// @nodoc
class _$SessionResumeCopyWithImpl<$Res>
    implements $SessionResumeCopyWith<$Res> {
  _$SessionResumeCopyWithImpl(this._self, this._then);

  final SessionResume _self;
  final $Res Function(SessionResume) _then;

/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? storedSessionId = freezed,Object? sessionKey = freezed,Object? resumed = freezed,Object? messageCount = null,Object? messages = null,Object? messagesOmitted = null,Object? hydrating = null,Object? running = null,Object? status = null,Object? info = freezed,Object? inflight = freezed,Object? queued = freezed,Object? openRequests = null,Object? todoState = freezed,}) {
  return _then(SessionResume(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,storedSessionId: freezed == storedSessionId ? _self.storedSessionId : storedSessionId // ignore: cast_nullable_to_non_nullable
as String?,sessionKey: freezed == sessionKey ? _self.sessionKey : sessionKey // ignore: cast_nullable_to_non_nullable
as String?,resumed: freezed == resumed ? _self.resumed : resumed // ignore: cast_nullable_to_non_nullable
as String?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<SessionMessage>,messagesOmitted: null == messagesOmitted ? _self.messagesOmitted : messagesOmitted // ignore: cast_nullable_to_non_nullable
as bool,hydrating: null == hydrating ? _self.hydrating : hydrating // ignore: cast_nullable_to_non_nullable
as bool,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as RuntimeInfo?,inflight: freezed == inflight ? _self.inflight : inflight // ignore: cast_nullable_to_non_nullable
as Inflight?,queued: freezed == queued ? _self.queued : queued // ignore: cast_nullable_to_non_nullable
as QueuedPrompt?,openRequests: null == openRequests ? _self.openRequests : openRequests // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,todoState: freezed == todoState ? _self.todoState : todoState // ignore: cast_nullable_to_non_nullable
as TodoPlan?,
  ));
}
/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RuntimeInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $RuntimeInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InflightCopyWith<$Res>? get inflight {
    if (_self.inflight == null) {
    return null;
  }

  return $InflightCopyWith<$Res>(_self.inflight!, (value) {
    return _then(_self.copyWith(inflight: value));
  });
}/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueuedPromptCopyWith<$Res>? get queued {
    if (_self.queued == null) {
    return null;
  }

  return $QueuedPromptCopyWith<$Res>(_self.queued!, (value) {
    return _then(_self.copyWith(queued: value));
  });
}/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodoPlanCopyWith<$Res>? get todoState {
    if (_self.todoState == null) {
    return null;
  }

  return $TodoPlanCopyWith<$Res>(_self.todoState!, (value) {
    return _then(_self.copyWith(todoState: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionResume].
extension SessionResumePatterns on SessionResume {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionResume value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionResume() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionResume value)  $default,){
final _that = this;
switch (_that) {
case _SessionResume():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionResume value)?  $default,){
final _that = this;
switch (_that) {
case _SessionResume() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')@LooseString()  String sessionId, @JsonKey(name: 'stored_session_id')@LooseStringOrNull()  String? storedSessionId, @JsonKey(name: 'session_key')@LooseStringOrNull()  String? sessionKey, @LooseStringOrNull()  String? resumed, @JsonKey(name: 'message_count')@LooseInt()  int messageCount, @JsonKey(fromJson: _messagesFromJson)  List<SessionMessage> messages, @JsonKey(name: 'messages_omitted')@LooseBool()  bool messagesOmitted, @LooseBool()  bool hydrating, @LooseBool()  bool running, @LooseString()  String status,  RuntimeInfo? info,  Inflight? inflight,  QueuedPrompt? queued, @JsonKey(name: 'open_requests')@LooseMapList()  List<Map<String, dynamic>> openRequests, @JsonKey(name: 'todo_state')  TodoPlan? todoState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionResume() when $default != null:
return $default(_that.sessionId,_that.storedSessionId,_that.sessionKey,_that.resumed,_that.messageCount,_that.messages,_that.messagesOmitted,_that.hydrating,_that.running,_that.status,_that.info,_that.inflight,_that.queued,_that.openRequests,_that.todoState);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')@LooseString()  String sessionId, @JsonKey(name: 'stored_session_id')@LooseStringOrNull()  String? storedSessionId, @JsonKey(name: 'session_key')@LooseStringOrNull()  String? sessionKey, @LooseStringOrNull()  String? resumed, @JsonKey(name: 'message_count')@LooseInt()  int messageCount, @JsonKey(fromJson: _messagesFromJson)  List<SessionMessage> messages, @JsonKey(name: 'messages_omitted')@LooseBool()  bool messagesOmitted, @LooseBool()  bool hydrating, @LooseBool()  bool running, @LooseString()  String status,  RuntimeInfo? info,  Inflight? inflight,  QueuedPrompt? queued, @JsonKey(name: 'open_requests')@LooseMapList()  List<Map<String, dynamic>> openRequests, @JsonKey(name: 'todo_state')  TodoPlan? todoState)  $default,) {final _that = this;
switch (_that) {
case _SessionResume():
return $default(_that.sessionId,_that.storedSessionId,_that.sessionKey,_that.resumed,_that.messageCount,_that.messages,_that.messagesOmitted,_that.hydrating,_that.running,_that.status,_that.info,_that.inflight,_that.queued,_that.openRequests,_that.todoState);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')@LooseString()  String sessionId, @JsonKey(name: 'stored_session_id')@LooseStringOrNull()  String? storedSessionId, @JsonKey(name: 'session_key')@LooseStringOrNull()  String? sessionKey, @LooseStringOrNull()  String? resumed, @JsonKey(name: 'message_count')@LooseInt()  int messageCount, @JsonKey(fromJson: _messagesFromJson)  List<SessionMessage> messages, @JsonKey(name: 'messages_omitted')@LooseBool()  bool messagesOmitted, @LooseBool()  bool hydrating, @LooseBool()  bool running, @LooseString()  String status,  RuntimeInfo? info,  Inflight? inflight,  QueuedPrompt? queued, @JsonKey(name: 'open_requests')@LooseMapList()  List<Map<String, dynamic>> openRequests, @JsonKey(name: 'todo_state')  TodoPlan? todoState)?  $default,) {final _that = this;
switch (_that) {
case _SessionResume() when $default != null:
return $default(_that.sessionId,_that.storedSessionId,_that.sessionKey,_that.resumed,_that.messageCount,_that.messages,_that.messagesOmitted,_that.hydrating,_that.running,_that.status,_that.info,_that.inflight,_that.queued,_that.openRequests,_that.todoState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionResume extends SessionResume {
  const _SessionResume({@JsonKey(name: 'session_id')@LooseString() this.sessionId = '', @JsonKey(name: 'stored_session_id')@LooseStringOrNull() this.storedSessionId, @JsonKey(name: 'session_key')@LooseStringOrNull() this.sessionKey, @LooseStringOrNull() this.resumed, @JsonKey(name: 'message_count')@LooseInt() this.messageCount = 0, @JsonKey(fromJson: _messagesFromJson)  List<SessionMessage> messages = const <SessionMessage>[], @JsonKey(name: 'messages_omitted')@LooseBool() this.messagesOmitted = false, @LooseBool() this.hydrating = false, @LooseBool() this.running = false, @LooseString() this.status = '', this.info, this.inflight, this.queued, @JsonKey(name: 'open_requests')@LooseMapList()  List<Map<String, dynamic>> openRequests = const <Map<String, dynamic>>[], @JsonKey(name: 'todo_state') this.todoState}): _messages = messages,_openRequests = openRequests,super._();
  factory _SessionResume.fromJson(Map<String, dynamic> json) => _$SessionResumeFromJson(json);

@override@JsonKey(name: 'session_id')@LooseString() final  String sessionId;
@override@JsonKey(name: 'stored_session_id')@LooseStringOrNull() final  String? storedSessionId;
@override@JsonKey(name: 'session_key')@LooseStringOrNull() final  String? sessionKey;
@override@LooseStringOrNull() final  String? resumed;
@override@JsonKey(name: 'message_count')@LooseInt() final  int messageCount;
 final  List<SessionMessage> _messages;
@override@JsonKey(fromJson: _messagesFromJson) List<SessionMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey(name: 'messages_omitted')@LooseBool() final  bool messagesOmitted;
@override@JsonKey()@LooseBool() final  bool hydrating;
@override@JsonKey()@LooseBool() final  bool running;
@override@JsonKey()@LooseString() final  String status;
@override final  RuntimeInfo? info;
@override final  Inflight? inflight;
@override final  QueuedPrompt? queued;
/// Questions still waiting on this session, as sent to the router: a live
/// session reattached by a resume lists them here.
 final  List<Map<String, dynamic>> _openRequests;
/// Questions still waiting on this session, as sent to the router: a live
/// session reattached by a resume lists them here.
@override@JsonKey(name: 'open_requests')@LooseMapList() List<Map<String, dynamic>> get openRequests {
  if (_openRequests is EqualUnmodifiableListView) return _openRequests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openRequests);
}

/// The agent's plan as last written; null when it keeps none.
@override@JsonKey(name: 'todo_state') final  TodoPlan? todoState;

/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionResumeCopyWith<_SessionResume> get copyWith => __$SessionResumeCopyWithImpl<_SessionResume>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionResumeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionResume&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.storedSessionId, storedSessionId) || other.storedSessionId == storedSessionId)&&(identical(other.sessionKey, sessionKey) || other.sessionKey == sessionKey)&&(identical(other.resumed, resumed) || other.resumed == resumed)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&const DeepCollectionEquality().equals(other.messages, _messages)&&(identical(other.messagesOmitted, messagesOmitted) || other.messagesOmitted == messagesOmitted)&&(identical(other.hydrating, hydrating) || other.hydrating == hydrating)&&(identical(other.running, running) || other.running == running)&&(identical(other.status, status) || other.status == status)&&(identical(other.info, info) || other.info == info)&&(identical(other.inflight, inflight) || other.inflight == inflight)&&(identical(other.queued, queued) || other.queued == queued)&&const DeepCollectionEquality().equals(other.openRequests, _openRequests)&&(identical(other.todoState, todoState) || other.todoState == todoState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,storedSessionId,sessionKey,resumed,messageCount,const DeepCollectionEquality().hash(_messages),messagesOmitted,hydrating,running,status,info,inflight,queued,const DeepCollectionEquality().hash(_openRequests),todoState);
}

@override
String toString() {
    return 'SessionResume(sessionId: $sessionId, storedSessionId: $storedSessionId, sessionKey: $sessionKey, resumed: $resumed, messageCount: $messageCount, messages: $messages, messagesOmitted: $messagesOmitted, hydrating: $hydrating, running: $running, status: $status, info: $info, inflight: $inflight, queued: $queued, openRequests: $openRequests, todoState: $todoState)';
}


}

/// @nodoc
abstract mixin class _$SessionResumeCopyWith<$Res> implements $SessionResumeCopyWith<$Res> {
  factory _$SessionResumeCopyWith(_SessionResume value, $Res Function(_SessionResume) _then) = __$SessionResumeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id')@LooseString() String sessionId,@JsonKey(name: 'stored_session_id')@LooseStringOrNull() String? storedSessionId,@JsonKey(name: 'session_key')@LooseStringOrNull() String? sessionKey,@LooseStringOrNull() String? resumed,@JsonKey(name: 'message_count')@LooseInt() int messageCount,@JsonKey(fromJson: _messagesFromJson) List<SessionMessage> messages,@JsonKey(name: 'messages_omitted')@LooseBool() bool messagesOmitted,@LooseBool() bool hydrating,@LooseBool() bool running,@LooseString() String status, RuntimeInfo? info, Inflight? inflight, QueuedPrompt? queued,@JsonKey(name: 'open_requests')@LooseMapList() List<Map<String, dynamic>> openRequests,@JsonKey(name: 'todo_state') TodoPlan? todoState
});


@override $RuntimeInfoCopyWith<$Res>? get info;@override $InflightCopyWith<$Res>? get inflight;@override $QueuedPromptCopyWith<$Res>? get queued;@override $TodoPlanCopyWith<$Res>? get todoState;

}
/// @nodoc
class __$SessionResumeCopyWithImpl<$Res>
    implements _$SessionResumeCopyWith<$Res> {
  __$SessionResumeCopyWithImpl(this._self, this._then);

  final _SessionResume _self;
  final $Res Function(_SessionResume) _then;

/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? storedSessionId = freezed,Object? sessionKey = freezed,Object? resumed = freezed,Object? messageCount = null,Object? messages = null,Object? messagesOmitted = null,Object? hydrating = null,Object? running = null,Object? status = null,Object? info = freezed,Object? inflight = freezed,Object? queued = freezed,Object? openRequests = null,Object? todoState = freezed,}) {
  return _then(_SessionResume(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,storedSessionId: freezed == storedSessionId ? _self.storedSessionId : storedSessionId // ignore: cast_nullable_to_non_nullable
as String?,sessionKey: freezed == sessionKey ? _self.sessionKey : sessionKey // ignore: cast_nullable_to_non_nullable
as String?,resumed: freezed == resumed ? _self.resumed : resumed // ignore: cast_nullable_to_non_nullable
as String?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<SessionMessage>,messagesOmitted: null == messagesOmitted ? _self.messagesOmitted : messagesOmitted // ignore: cast_nullable_to_non_nullable
as bool,hydrating: null == hydrating ? _self.hydrating : hydrating // ignore: cast_nullable_to_non_nullable
as bool,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as RuntimeInfo?,inflight: freezed == inflight ? _self.inflight : inflight // ignore: cast_nullable_to_non_nullable
as Inflight?,queued: freezed == queued ? _self.queued : queued // ignore: cast_nullable_to_non_nullable
as QueuedPrompt?,openRequests: null == openRequests ? _self._openRequests : openRequests // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,todoState: freezed == todoState ? _self.todoState : todoState // ignore: cast_nullable_to_non_nullable
as TodoPlan?,
  ));
}

/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RuntimeInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $RuntimeInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InflightCopyWith<$Res>? get inflight {
    if (_self.inflight == null) {
    return null;
  }

  return $InflightCopyWith<$Res>(_self.inflight!, (value) {
    return _then(_self.copyWith(inflight: value));
  });
}/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueuedPromptCopyWith<$Res>? get queued {
    if (_self.queued == null) {
    return null;
  }

  return $QueuedPromptCopyWith<$Res>(_self.queued!, (value) {
    return _then(_self.copyWith(queued: value));
  });
}/// Create a copy of SessionResume
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodoPlanCopyWith<$Res>? get todoState {
    if (_self.todoState == null) {
    return null;
  }

  return $TodoPlanCopyWith<$Res>(_self.todoState!, (value) {
    return _then(_self.copyWith(todoState: value));
  });
}
}


/// @nodoc
mixin _$RuntimeInfo {

@LooseString() String get model;@LooseString() String get provider;@JsonKey(name: 'reasoning_effort')@LooseString() String get reasoningEffort;@LooseBool() bool get running;@LooseString() String get version;@LooseMap() Map<String, dynamic>? get usage;
/// Create a copy of RuntimeInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuntimeInfoCopyWith<RuntimeInfo> get copyWith => _$RuntimeInfoCopyWithImpl<RuntimeInfo>(this as RuntimeInfo, _$identity);

  /// Serializes this RuntimeInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RuntimeInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuntimeInfo&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.reasoningEffort, _this.reasoningEffort) || other.reasoningEffort == _this.reasoningEffort)&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.version, _this.version) || other.version == _this.version)&&const DeepCollectionEquality().equals(other.usage, _this.usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RuntimeInfo;
  return Object.hash(runtimeType,_this.model,_this.provider,_this.reasoningEffort,_this.running,_this.version,const DeepCollectionEquality().hash(_this.usage));
}

@override
String toString() {
  final _this = this as RuntimeInfo;
  return 'RuntimeInfo(model: ${_this.model}, provider: ${_this.provider}, reasoningEffort: ${_this.reasoningEffort}, running: ${_this.running}, version: ${_this.version}, usage: ${_this.usage})';
}


}

/// @nodoc
abstract mixin class $RuntimeInfoCopyWith<$Res>  {
  factory $RuntimeInfoCopyWith(RuntimeInfo value, $Res Function(RuntimeInfo) _then) = _$RuntimeInfoCopyWithImpl;
@useResult
$Res call({
@LooseString() String model,@LooseString() String provider,@JsonKey(name: 'reasoning_effort')@LooseString() String reasoningEffort,@LooseBool() bool running,@LooseString() String version,@LooseMap() Map<String, dynamic>? usage
});




}
/// @nodoc
class _$RuntimeInfoCopyWithImpl<$Res>
    implements $RuntimeInfoCopyWith<$Res> {
  _$RuntimeInfoCopyWithImpl(this._self, this._then);

  final RuntimeInfo _self;
  final $Res Function(RuntimeInfo) _then;

/// Create a copy of RuntimeInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? model = null,Object? provider = null,Object? reasoningEffort = null,Object? running = null,Object? version = null,Object? usage = freezed,}) {
  return _then(RuntimeInfo(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,reasoningEffort: null == reasoningEffort ? _self.reasoningEffort : reasoningEffort // ignore: cast_nullable_to_non_nullable
as String,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RuntimeInfo].
extension RuntimeInfoPatterns on RuntimeInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RuntimeInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RuntimeInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RuntimeInfo value)  $default,){
final _that = this;
switch (_that) {
case _RuntimeInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RuntimeInfo value)?  $default,){
final _that = this;
switch (_that) {
case _RuntimeInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String model, @LooseString()  String provider, @JsonKey(name: 'reasoning_effort')@LooseString()  String reasoningEffort, @LooseBool()  bool running, @LooseString()  String version, @LooseMap()  Map<String, dynamic>? usage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RuntimeInfo() when $default != null:
return $default(_that.model,_that.provider,_that.reasoningEffort,_that.running,_that.version,_that.usage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String model, @LooseString()  String provider, @JsonKey(name: 'reasoning_effort')@LooseString()  String reasoningEffort, @LooseBool()  bool running, @LooseString()  String version, @LooseMap()  Map<String, dynamic>? usage)  $default,) {final _that = this;
switch (_that) {
case _RuntimeInfo():
return $default(_that.model,_that.provider,_that.reasoningEffort,_that.running,_that.version,_that.usage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String model, @LooseString()  String provider, @JsonKey(name: 'reasoning_effort')@LooseString()  String reasoningEffort, @LooseBool()  bool running, @LooseString()  String version, @LooseMap()  Map<String, dynamic>? usage)?  $default,) {final _that = this;
switch (_that) {
case _RuntimeInfo() when $default != null:
return $default(_that.model,_that.provider,_that.reasoningEffort,_that.running,_that.version,_that.usage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RuntimeInfo implements RuntimeInfo {
  const _RuntimeInfo({@LooseString() this.model = '', @LooseString() this.provider = '', @JsonKey(name: 'reasoning_effort')@LooseString() this.reasoningEffort = '', @LooseBool() this.running = false, @LooseString() this.version = '', @LooseMap()  Map<String, dynamic>? usage}): _usage = usage;
  factory _RuntimeInfo.fromJson(Map<String, dynamic> json) => _$RuntimeInfoFromJson(json);

@override@JsonKey()@LooseString() final  String model;
@override@JsonKey()@LooseString() final  String provider;
@override@JsonKey(name: 'reasoning_effort')@LooseString() final  String reasoningEffort;
@override@JsonKey()@LooseBool() final  bool running;
@override@JsonKey()@LooseString() final  String version;
 final  Map<String, dynamic>? _usage;
@override@LooseMap() Map<String, dynamic>? get usage {
  final value = _usage;
  if (value == null) return null;
  if (_usage is EqualUnmodifiableMapView) return _usage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of RuntimeInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuntimeInfoCopyWith<_RuntimeInfo> get copyWith => __$RuntimeInfoCopyWithImpl<_RuntimeInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuntimeInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuntimeInfo&&(identical(other.model, model) || other.model == model)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.reasoningEffort, reasoningEffort) || other.reasoningEffort == reasoningEffort)&&(identical(other.running, running) || other.running == running)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.usage, _usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,model,provider,reasoningEffort,running,version,const DeepCollectionEquality().hash(_usage));
}

@override
String toString() {
    return 'RuntimeInfo(model: $model, provider: $provider, reasoningEffort: $reasoningEffort, running: $running, version: $version, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$RuntimeInfoCopyWith<$Res> implements $RuntimeInfoCopyWith<$Res> {
  factory _$RuntimeInfoCopyWith(_RuntimeInfo value, $Res Function(_RuntimeInfo) _then) = __$RuntimeInfoCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String model,@LooseString() String provider,@JsonKey(name: 'reasoning_effort')@LooseString() String reasoningEffort,@LooseBool() bool running,@LooseString() String version,@LooseMap() Map<String, dynamic>? usage
});




}
/// @nodoc
class __$RuntimeInfoCopyWithImpl<$Res>
    implements _$RuntimeInfoCopyWith<$Res> {
  __$RuntimeInfoCopyWithImpl(this._self, this._then);

  final _RuntimeInfo _self;
  final $Res Function(_RuntimeInfo) _then;

/// Create a copy of RuntimeInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? model = null,Object? provider = null,Object? reasoningEffort = null,Object? running = null,Object? version = null,Object? usage = freezed,}) {
  return _then(_RuntimeInfo(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,reasoningEffort: null == reasoningEffort ? _self.reasoningEffort : reasoningEffort // ignore: cast_nullable_to_non_nullable
as String,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,usage: freezed == usage ? _self._usage : usage // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$Inflight {

@LooseString() String get assistant;@LooseString() String get user;@LooseBool() bool get streaming;@LooseStringOrNull() String? get error;@LooseString() String get status;
/// Create a copy of Inflight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InflightCopyWith<Inflight> get copyWith => _$InflightCopyWithImpl<Inflight>(this as Inflight, _$identity);

  /// Serializes this Inflight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Inflight;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inflight&&(identical(other.assistant, _this.assistant) || other.assistant == _this.assistant)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.streaming, _this.streaming) || other.streaming == _this.streaming)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Inflight;
  return Object.hash(runtimeType,_this.assistant,_this.user,_this.streaming,_this.error,_this.status);
}

@override
String toString() {
  final _this = this as Inflight;
  return 'Inflight(assistant: ${_this.assistant}, user: ${_this.user}, streaming: ${_this.streaming}, error: ${_this.error}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $InflightCopyWith<$Res>  {
  factory $InflightCopyWith(Inflight value, $Res Function(Inflight) _then) = _$InflightCopyWithImpl;
@useResult
$Res call({
@LooseString() String assistant,@LooseString() String user,@LooseBool() bool streaming,@LooseStringOrNull() String? error,@LooseString() String status
});




}
/// @nodoc
class _$InflightCopyWithImpl<$Res>
    implements $InflightCopyWith<$Res> {
  _$InflightCopyWithImpl(this._self, this._then);

  final Inflight _self;
  final $Res Function(Inflight) _then;

/// Create a copy of Inflight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assistant = null,Object? user = null,Object? streaming = null,Object? error = freezed,Object? status = null,}) {
  return _then(Inflight(
assistant: null == assistant ? _self.assistant : assistant // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,streaming: null == streaming ? _self.streaming : streaming // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Inflight].
extension InflightPatterns on Inflight {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inflight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inflight() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inflight value)  $default,){
final _that = this;
switch (_that) {
case _Inflight():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inflight value)?  $default,){
final _that = this;
switch (_that) {
case _Inflight() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String assistant, @LooseString()  String user, @LooseBool()  bool streaming, @LooseStringOrNull()  String? error, @LooseString()  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inflight() when $default != null:
return $default(_that.assistant,_that.user,_that.streaming,_that.error,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String assistant, @LooseString()  String user, @LooseBool()  bool streaming, @LooseStringOrNull()  String? error, @LooseString()  String status)  $default,) {final _that = this;
switch (_that) {
case _Inflight():
return $default(_that.assistant,_that.user,_that.streaming,_that.error,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String assistant, @LooseString()  String user, @LooseBool()  bool streaming, @LooseStringOrNull()  String? error, @LooseString()  String status)?  $default,) {final _that = this;
switch (_that) {
case _Inflight() when $default != null:
return $default(_that.assistant,_that.user,_that.streaming,_that.error,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Inflight implements Inflight {
  const _Inflight({@LooseString() this.assistant = '', @LooseString() this.user = '', @LooseBool() this.streaming = false, @LooseStringOrNull() this.error, @LooseString() this.status = ''});
  factory _Inflight.fromJson(Map<String, dynamic> json) => _$InflightFromJson(json);

@override@JsonKey()@LooseString() final  String assistant;
@override@JsonKey()@LooseString() final  String user;
@override@JsonKey()@LooseBool() final  bool streaming;
@override@LooseStringOrNull() final  String? error;
@override@JsonKey()@LooseString() final  String status;

/// Create a copy of Inflight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InflightCopyWith<_Inflight> get copyWith => __$InflightCopyWithImpl<_Inflight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InflightToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inflight&&(identical(other.assistant, assistant) || other.assistant == assistant)&&(identical(other.user, user) || other.user == user)&&(identical(other.streaming, streaming) || other.streaming == streaming)&&(identical(other.error, error) || other.error == error)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,assistant,user,streaming,error,status);
}

@override
String toString() {
    return 'Inflight(assistant: $assistant, user: $user, streaming: $streaming, error: $error, status: $status)';
}


}

/// @nodoc
abstract mixin class _$InflightCopyWith<$Res> implements $InflightCopyWith<$Res> {
  factory _$InflightCopyWith(_Inflight value, $Res Function(_Inflight) _then) = __$InflightCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String assistant,@LooseString() String user,@LooseBool() bool streaming,@LooseStringOrNull() String? error,@LooseString() String status
});




}
/// @nodoc
class __$InflightCopyWithImpl<$Res>
    implements _$InflightCopyWith<$Res> {
  __$InflightCopyWithImpl(this._self, this._then);

  final _Inflight _self;
  final $Res Function(_Inflight) _then;

/// Create a copy of Inflight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assistant = null,Object? user = null,Object? streaming = null,Object? error = freezed,Object? status = null,}) {
  return _then(_Inflight(
assistant: null == assistant ? _self.assistant : assistant // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,streaming: null == streaming ? _self.streaming : streaming // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$QueuedPrompt {

@LooseString() String get user;
/// Create a copy of QueuedPrompt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueuedPromptCopyWith<QueuedPrompt> get copyWith => _$QueuedPromptCopyWithImpl<QueuedPrompt>(this as QueuedPrompt, _$identity);

  /// Serializes this QueuedPrompt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QueuedPrompt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueuedPrompt&&(identical(other.user, _this.user) || other.user == _this.user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QueuedPrompt;
  return Object.hash(runtimeType,_this.user);
}

@override
String toString() {
  final _this = this as QueuedPrompt;
  return 'QueuedPrompt(user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $QueuedPromptCopyWith<$Res>  {
  factory $QueuedPromptCopyWith(QueuedPrompt value, $Res Function(QueuedPrompt) _then) = _$QueuedPromptCopyWithImpl;
@useResult
$Res call({
@LooseString() String user
});




}
/// @nodoc
class _$QueuedPromptCopyWithImpl<$Res>
    implements $QueuedPromptCopyWith<$Res> {
  _$QueuedPromptCopyWithImpl(this._self, this._then);

  final QueuedPrompt _self;
  final $Res Function(QueuedPrompt) _then;

/// Create a copy of QueuedPrompt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,}) {
  return _then(QueuedPrompt(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QueuedPrompt].
extension QueuedPromptPatterns on QueuedPrompt {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueuedPrompt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueuedPrompt() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueuedPrompt value)  $default,){
final _that = this;
switch (_that) {
case _QueuedPrompt():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueuedPrompt value)?  $default,){
final _that = this;
switch (_that) {
case _QueuedPrompt() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueuedPrompt() when $default != null:
return $default(_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String user)  $default,) {final _that = this;
switch (_that) {
case _QueuedPrompt():
return $default(_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String user)?  $default,) {final _that = this;
switch (_that) {
case _QueuedPrompt() when $default != null:
return $default(_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QueuedPrompt implements QueuedPrompt {
  const _QueuedPrompt({@LooseString() this.user = ''});
  factory _QueuedPrompt.fromJson(Map<String, dynamic> json) => _$QueuedPromptFromJson(json);

@override@JsonKey()@LooseString() final  String user;

/// Create a copy of QueuedPrompt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueuedPromptCopyWith<_QueuedPrompt> get copyWith => __$QueuedPromptCopyWithImpl<_QueuedPrompt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QueuedPromptToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueuedPrompt&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,user);
}

@override
String toString() {
    return 'QueuedPrompt(user: $user)';
}


}

/// @nodoc
abstract mixin class _$QueuedPromptCopyWith<$Res> implements $QueuedPromptCopyWith<$Res> {
  factory _$QueuedPromptCopyWith(_QueuedPrompt value, $Res Function(_QueuedPrompt) _then) = __$QueuedPromptCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String user
});




}
/// @nodoc
class __$QueuedPromptCopyWithImpl<$Res>
    implements _$QueuedPromptCopyWith<$Res> {
  __$QueuedPromptCopyWithImpl(this._self, this._then);

  final _QueuedPrompt _self;
  final $Res Function(_QueuedPrompt) _then;

/// Create a copy of QueuedPrompt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(_QueuedPrompt(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
