// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatState {

/// Bound to the socket; changes on every resume.
 String get runtimeId;/// Durable id, for resumes.
 String get storedId; String get profile; List<ChatMessage> get messages; bool get loading; bool get running; bool get stopRequested; String get statusLine; String get thinkingLabel; HermesFailure? get error; String get model; String get effort; String get provider;/// The agent's plan for the running turn; null when it keeps none.
 TodoPlan? get plan;/// Token counters of the session when it opened, for the context ring.
 SessionUsage? get openingUsage;/// Turns the gateway has not acknowledged yet, persisted.
 List<OutboxEntry> get outbox; bool get online; UploadProgress? get upload;/// Gateway row ids hidden on this phone.
 Set<int> get hidden;/// Earlier conversations, oldest first, each closed by a boundary row.
 List<ChatMessage> get earlier;/// Stored id of the oldest conversation on screen; empty means the open one.
 String get earlierCursor; bool get earlierDone;/// The transcript could not be read; the next connection or Retry reads it.
 bool get historyStale;
/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStateCopyWith<ChatState> get copyWith => _$ChatStateCopyWithImpl<ChatState>(this as ChatState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState&&(identical(other.runtimeId, _this.runtimeId) || other.runtimeId == _this.runtimeId)&&(identical(other.storedId, _this.storedId) || other.storedId == _this.storedId)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&const DeepCollectionEquality().equals(other.messages, _this.messages)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.stopRequested, _this.stopRequested) || other.stopRequested == _this.stopRequested)&&(identical(other.statusLine, _this.statusLine) || other.statusLine == _this.statusLine)&&(identical(other.thinkingLabel, _this.thinkingLabel) || other.thinkingLabel == _this.thinkingLabel)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.effort, _this.effort) || other.effort == _this.effort)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&(identical(other.openingUsage, _this.openingUsage) || other.openingUsage == _this.openingUsage)&&const DeepCollectionEquality().equals(other.outbox, _this.outbox)&&(identical(other.online, _this.online) || other.online == _this.online)&&(identical(other.upload, _this.upload) || other.upload == _this.upload)&&const DeepCollectionEquality().equals(other.hidden, _this.hidden)&&const DeepCollectionEquality().equals(other.earlier, _this.earlier)&&(identical(other.earlierCursor, _this.earlierCursor) || other.earlierCursor == _this.earlierCursor)&&(identical(other.earlierDone, _this.earlierDone) || other.earlierDone == _this.earlierDone)&&(identical(other.historyStale, _this.historyStale) || other.historyStale == _this.historyStale));
}


@override
int get hashCode {
  final _this = this as ChatState;
  return Object.hashAll([runtimeType,_this.runtimeId,_this.storedId,_this.profile,const DeepCollectionEquality().hash(_this.messages),_this.loading,_this.running,_this.stopRequested,_this.statusLine,_this.thinkingLabel,_this.error,_this.model,_this.effort,_this.provider,_this.plan,_this.openingUsage,const DeepCollectionEquality().hash(_this.outbox),_this.online,_this.upload,const DeepCollectionEquality().hash(_this.hidden),const DeepCollectionEquality().hash(_this.earlier),_this.earlierCursor,_this.earlierDone,_this.historyStale]);
}

@override
String toString() {
  final _this = this as ChatState;
  return 'ChatState(runtimeId: ${_this.runtimeId}, storedId: ${_this.storedId}, profile: ${_this.profile}, messages: ${_this.messages}, loading: ${_this.loading}, running: ${_this.running}, stopRequested: ${_this.stopRequested}, statusLine: ${_this.statusLine}, thinkingLabel: ${_this.thinkingLabel}, error: ${_this.error}, model: ${_this.model}, effort: ${_this.effort}, provider: ${_this.provider}, plan: ${_this.plan}, openingUsage: ${_this.openingUsage}, outbox: ${_this.outbox}, online: ${_this.online}, upload: ${_this.upload}, hidden: ${_this.hidden}, earlier: ${_this.earlier}, earlierCursor: ${_this.earlierCursor}, earlierDone: ${_this.earlierDone}, historyStale: ${_this.historyStale})';
}


}

/// @nodoc
abstract mixin class $ChatStateCopyWith<$Res>  {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) _then) = _$ChatStateCopyWithImpl;
@useResult
$Res call({
 String runtimeId, String storedId, String profile, List<ChatMessage> messages, bool loading, bool running, bool stopRequested, String statusLine, String thinkingLabel, HermesFailure? error, String model, String effort, String provider, TodoPlan? plan, SessionUsage? openingUsage, List<OutboxEntry> outbox, bool online, UploadProgress? upload, Set<int> hidden, List<ChatMessage> earlier, String earlierCursor, bool earlierDone, bool historyStale
});


$TodoPlanCopyWith<$Res>? get plan;$SessionUsageCopyWith<$Res>? get openingUsage;

}
/// @nodoc
class _$ChatStateCopyWithImpl<$Res>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._self, this._then);

  final ChatState _self;
  final $Res Function(ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? runtimeId = null,Object? storedId = null,Object? profile = null,Object? messages = null,Object? loading = null,Object? running = null,Object? stopRequested = null,Object? statusLine = null,Object? thinkingLabel = null,Object? error = freezed,Object? model = null,Object? effort = null,Object? provider = null,Object? plan = freezed,Object? openingUsage = freezed,Object? outbox = null,Object? online = null,Object? upload = freezed,Object? hidden = null,Object? earlier = null,Object? earlierCursor = null,Object? earlierDone = null,Object? historyStale = null,}) {
  return _then(ChatState(
runtimeId: null == runtimeId ? _self.runtimeId : runtimeId // ignore: cast_nullable_to_non_nullable
as String,storedId: null == storedId ? _self.storedId : storedId // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,stopRequested: null == stopRequested ? _self.stopRequested : stopRequested // ignore: cast_nullable_to_non_nullable
as bool,statusLine: null == statusLine ? _self.statusLine : statusLine // ignore: cast_nullable_to_non_nullable
as String,thinkingLabel: null == thinkingLabel ? _self.thinkingLabel : thinkingLabel // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as HermesFailure?,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as TodoPlan?,openingUsage: freezed == openingUsage ? _self.openingUsage : openingUsage // ignore: cast_nullable_to_non_nullable
as SessionUsage?,outbox: null == outbox ? _self.outbox : outbox // ignore: cast_nullable_to_non_nullable
as List<OutboxEntry>,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,upload: freezed == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as UploadProgress?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as Set<int>,earlier: null == earlier ? _self.earlier : earlier // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,earlierCursor: null == earlierCursor ? _self.earlierCursor : earlierCursor // ignore: cast_nullable_to_non_nullable
as String,earlierDone: null == earlierDone ? _self.earlierDone : earlierDone // ignore: cast_nullable_to_non_nullable
as bool,historyStale: null == historyStale ? _self.historyStale : historyStale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodoPlanCopyWith<$Res>? get plan {
    if (_self.plan == null) {
    return null;
  }

  return $TodoPlanCopyWith<$Res>(_self.plan!, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionUsageCopyWith<$Res>? get openingUsage {
    if (_self.openingUsage == null) {
    return null;
  }

  return $SessionUsageCopyWith<$Res>(_self.openingUsage!, (value) {
    return _then(_self.copyWith(openingUsage: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatState value)  $default,){
final _that = this;
switch (_that) {
case _ChatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String runtimeId,  String storedId,  String profile,  List<ChatMessage> messages,  bool loading,  bool running,  bool stopRequested,  String statusLine,  String thinkingLabel,  HermesFailure? error,  String model,  String effort,  String provider,  TodoPlan? plan,  SessionUsage? openingUsage,  List<OutboxEntry> outbox,  bool online,  UploadProgress? upload,  Set<int> hidden,  List<ChatMessage> earlier,  String earlierCursor,  bool earlierDone,  bool historyStale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.runtimeId,_that.storedId,_that.profile,_that.messages,_that.loading,_that.running,_that.stopRequested,_that.statusLine,_that.thinkingLabel,_that.error,_that.model,_that.effort,_that.provider,_that.plan,_that.openingUsage,_that.outbox,_that.online,_that.upload,_that.hidden,_that.earlier,_that.earlierCursor,_that.earlierDone,_that.historyStale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String runtimeId,  String storedId,  String profile,  List<ChatMessage> messages,  bool loading,  bool running,  bool stopRequested,  String statusLine,  String thinkingLabel,  HermesFailure? error,  String model,  String effort,  String provider,  TodoPlan? plan,  SessionUsage? openingUsage,  List<OutboxEntry> outbox,  bool online,  UploadProgress? upload,  Set<int> hidden,  List<ChatMessage> earlier,  String earlierCursor,  bool earlierDone,  bool historyStale)  $default,) {final _that = this;
switch (_that) {
case _ChatState():
return $default(_that.runtimeId,_that.storedId,_that.profile,_that.messages,_that.loading,_that.running,_that.stopRequested,_that.statusLine,_that.thinkingLabel,_that.error,_that.model,_that.effort,_that.provider,_that.plan,_that.openingUsage,_that.outbox,_that.online,_that.upload,_that.hidden,_that.earlier,_that.earlierCursor,_that.earlierDone,_that.historyStale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String runtimeId,  String storedId,  String profile,  List<ChatMessage> messages,  bool loading,  bool running,  bool stopRequested,  String statusLine,  String thinkingLabel,  HermesFailure? error,  String model,  String effort,  String provider,  TodoPlan? plan,  SessionUsage? openingUsage,  List<OutboxEntry> outbox,  bool online,  UploadProgress? upload,  Set<int> hidden,  List<ChatMessage> earlier,  String earlierCursor,  bool earlierDone,  bool historyStale)?  $default,) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.runtimeId,_that.storedId,_that.profile,_that.messages,_that.loading,_that.running,_that.stopRequested,_that.statusLine,_that.thinkingLabel,_that.error,_that.model,_that.effort,_that.provider,_that.plan,_that.openingUsage,_that.outbox,_that.online,_that.upload,_that.hidden,_that.earlier,_that.earlierCursor,_that.earlierDone,_that.historyStale);case _:
  return null;

}
}

}

/// @nodoc


class _ChatState extends ChatState {
  const _ChatState({this.runtimeId = '', this.storedId = '', this.profile = '',  List<ChatMessage> messages = const <ChatMessage>[], this.loading = false, this.running = false, this.stopRequested = false, this.statusLine = '', this.thinkingLabel = '', this.error, this.model = '', this.effort = '', this.provider = '', this.plan, this.openingUsage,  List<OutboxEntry> outbox = const <OutboxEntry>[], this.online = false, this.upload,  Set<int> hidden = const <int>{},  List<ChatMessage> earlier = const <ChatMessage>[], this.earlierCursor = '', this.earlierDone = false, this.historyStale = false}): _messages = messages,_outbox = outbox,_hidden = hidden,_earlier = earlier,super._();
  

/// Bound to the socket; changes on every resume.
@override@JsonKey() final  String runtimeId;
/// Durable id, for resumes.
@override@JsonKey() final  String storedId;
@override@JsonKey() final  String profile;
 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool running;
@override@JsonKey() final  bool stopRequested;
@override@JsonKey() final  String statusLine;
@override@JsonKey() final  String thinkingLabel;
@override final  HermesFailure? error;
@override@JsonKey() final  String model;
@override@JsonKey() final  String effort;
@override@JsonKey() final  String provider;
/// The agent's plan for the running turn; null when it keeps none.
@override final  TodoPlan? plan;
/// Token counters of the session when it opened, for the context ring.
@override final  SessionUsage? openingUsage;
/// Turns the gateway has not acknowledged yet, persisted.
 final  List<OutboxEntry> _outbox;
/// Turns the gateway has not acknowledged yet, persisted.
@override@JsonKey() List<OutboxEntry> get outbox {
  if (_outbox is EqualUnmodifiableListView) return _outbox;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outbox);
}

@override@JsonKey() final  bool online;
@override final  UploadProgress? upload;
/// Gateway row ids hidden on this phone.
 final  Set<int> _hidden;
/// Gateway row ids hidden on this phone.
@override@JsonKey() Set<int> get hidden {
  if (_hidden is EqualUnmodifiableSetView) return _hidden;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_hidden);
}

/// Earlier conversations, oldest first, each closed by a boundary row.
 final  List<ChatMessage> _earlier;
/// Earlier conversations, oldest first, each closed by a boundary row.
@override@JsonKey() List<ChatMessage> get earlier {
  if (_earlier is EqualUnmodifiableListView) return _earlier;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_earlier);
}

/// Stored id of the oldest conversation on screen; empty means the open one.
@override@JsonKey() final  String earlierCursor;
@override@JsonKey() final  bool earlierDone;
/// The transcript could not be read; the next connection or Retry reads it.
@override@JsonKey() final  bool historyStale;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatStateCopyWith<_ChatState> get copyWith => __$ChatStateCopyWithImpl<_ChatState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatState&&(identical(other.runtimeId, runtimeId) || other.runtimeId == runtimeId)&&(identical(other.storedId, storedId) || other.storedId == storedId)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.messages, _messages)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.running, running) || other.running == running)&&(identical(other.stopRequested, stopRequested) || other.stopRequested == stopRequested)&&(identical(other.statusLine, statusLine) || other.statusLine == statusLine)&&(identical(other.thinkingLabel, thinkingLabel) || other.thinkingLabel == thinkingLabel)&&(identical(other.error, error) || other.error == error)&&(identical(other.model, model) || other.model == model)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.openingUsage, openingUsage) || other.openingUsage == openingUsage)&&const DeepCollectionEquality().equals(other.outbox, _outbox)&&(identical(other.online, online) || other.online == online)&&(identical(other.upload, upload) || other.upload == upload)&&const DeepCollectionEquality().equals(other.hidden, _hidden)&&const DeepCollectionEquality().equals(other.earlier, _earlier)&&(identical(other.earlierCursor, earlierCursor) || other.earlierCursor == earlierCursor)&&(identical(other.earlierDone, earlierDone) || other.earlierDone == earlierDone)&&(identical(other.historyStale, historyStale) || other.historyStale == historyStale));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,runtimeId,storedId,profile,const DeepCollectionEquality().hash(_messages),loading,running,stopRequested,statusLine,thinkingLabel,error,model,effort,provider,plan,openingUsage,const DeepCollectionEquality().hash(_outbox),online,upload,const DeepCollectionEquality().hash(_hidden),const DeepCollectionEquality().hash(_earlier),earlierCursor,earlierDone,historyStale]);
}

@override
String toString() {
    return 'ChatState(runtimeId: $runtimeId, storedId: $storedId, profile: $profile, messages: $messages, loading: $loading, running: $running, stopRequested: $stopRequested, statusLine: $statusLine, thinkingLabel: $thinkingLabel, error: $error, model: $model, effort: $effort, provider: $provider, plan: $plan, openingUsage: $openingUsage, outbox: $outbox, online: $online, upload: $upload, hidden: $hidden, earlier: $earlier, earlierCursor: $earlierCursor, earlierDone: $earlierDone, historyStale: $historyStale)';
}


}

/// @nodoc
abstract mixin class _$ChatStateCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$ChatStateCopyWith(_ChatState value, $Res Function(_ChatState) _then) = __$ChatStateCopyWithImpl;
@override @useResult
$Res call({
 String runtimeId, String storedId, String profile, List<ChatMessage> messages, bool loading, bool running, bool stopRequested, String statusLine, String thinkingLabel, HermesFailure? error, String model, String effort, String provider, TodoPlan? plan, SessionUsage? openingUsage, List<OutboxEntry> outbox, bool online, UploadProgress? upload, Set<int> hidden, List<ChatMessage> earlier, String earlierCursor, bool earlierDone, bool historyStale
});


@override $TodoPlanCopyWith<$Res>? get plan;@override $SessionUsageCopyWith<$Res>? get openingUsage;

}
/// @nodoc
class __$ChatStateCopyWithImpl<$Res>
    implements _$ChatStateCopyWith<$Res> {
  __$ChatStateCopyWithImpl(this._self, this._then);

  final _ChatState _self;
  final $Res Function(_ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? runtimeId = null,Object? storedId = null,Object? profile = null,Object? messages = null,Object? loading = null,Object? running = null,Object? stopRequested = null,Object? statusLine = null,Object? thinkingLabel = null,Object? error = freezed,Object? model = null,Object? effort = null,Object? provider = null,Object? plan = freezed,Object? openingUsage = freezed,Object? outbox = null,Object? online = null,Object? upload = freezed,Object? hidden = null,Object? earlier = null,Object? earlierCursor = null,Object? earlierDone = null,Object? historyStale = null,}) {
  return _then(_ChatState(
runtimeId: null == runtimeId ? _self.runtimeId : runtimeId // ignore: cast_nullable_to_non_nullable
as String,storedId: null == storedId ? _self.storedId : storedId // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,stopRequested: null == stopRequested ? _self.stopRequested : stopRequested // ignore: cast_nullable_to_non_nullable
as bool,statusLine: null == statusLine ? _self.statusLine : statusLine // ignore: cast_nullable_to_non_nullable
as String,thinkingLabel: null == thinkingLabel ? _self.thinkingLabel : thinkingLabel // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as HermesFailure?,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as TodoPlan?,openingUsage: freezed == openingUsage ? _self.openingUsage : openingUsage // ignore: cast_nullable_to_non_nullable
as SessionUsage?,outbox: null == outbox ? _self._outbox : outbox // ignore: cast_nullable_to_non_nullable
as List<OutboxEntry>,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,upload: freezed == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as UploadProgress?,hidden: null == hidden ? _self._hidden : hidden // ignore: cast_nullable_to_non_nullable
as Set<int>,earlier: null == earlier ? _self._earlier : earlier // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,earlierCursor: null == earlierCursor ? _self.earlierCursor : earlierCursor // ignore: cast_nullable_to_non_nullable
as String,earlierDone: null == earlierDone ? _self.earlierDone : earlierDone // ignore: cast_nullable_to_non_nullable
as bool,historyStale: null == historyStale ? _self.historyStale : historyStale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodoPlanCopyWith<$Res>? get plan {
    if (_self.plan == null) {
    return null;
  }

  return $TodoPlanCopyWith<$Res>(_self.plan!, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionUsageCopyWith<$Res>? get openingUsage {
    if (_self.openingUsage == null) {
    return null;
  }

  return $SessionUsageCopyWith<$Res>(_self.openingUsage!, (value) {
    return _then(_self.copyWith(openingUsage: value));
  });
}
}

// dart format on
