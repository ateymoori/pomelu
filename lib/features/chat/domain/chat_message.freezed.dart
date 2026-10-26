// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatMessage {

 String get id; ChatRole get role; String get text; String get reasoning; List<ToolCall> get tools; DateTime? get timestamp;/// The gateway's durable row id; live rows get it on the next reload.
 int? get rowId; bool get streaming; bool get interim; DeliveryState get delivery; String? get error; List<LocalAttachment> get attachments; List<MediaRef> get media;/// The slash command typed, for a command row.
 String? get command;/// The line that ends one conversation with the bot. Carries no text.
 bool get boundary;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.reasoning, _this.reasoning) || other.reasoning == _this.reasoning)&&const DeepCollectionEquality().equals(other.tools, _this.tools)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&(identical(other.rowId, _this.rowId) || other.rowId == _this.rowId)&&(identical(other.streaming, _this.streaming) || other.streaming == _this.streaming)&&(identical(other.interim, _this.interim) || other.interim == _this.interim)&&(identical(other.delivery, _this.delivery) || other.delivery == _this.delivery)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments)&&const DeepCollectionEquality().equals(other.media, _this.media)&&(identical(other.command, _this.command) || other.command == _this.command)&&(identical(other.boundary, _this.boundary) || other.boundary == _this.boundary));
}


@override
int get hashCode {
  final _this = this as ChatMessage;
  return Object.hash(runtimeType,_this.id,_this.role,_this.text,_this.reasoning,const DeepCollectionEquality().hash(_this.tools),_this.timestamp,_this.rowId,_this.streaming,_this.interim,_this.delivery,_this.error,const DeepCollectionEquality().hash(_this.attachments),const DeepCollectionEquality().hash(_this.media),_this.command,_this.boundary);
}

@override
String toString() {
  final _this = this as ChatMessage;
  return 'ChatMessage(id: ${_this.id}, role: ${_this.role}, text: ${_this.text}, reasoning: ${_this.reasoning}, tools: ${_this.tools}, timestamp: ${_this.timestamp}, rowId: ${_this.rowId}, streaming: ${_this.streaming}, interim: ${_this.interim}, delivery: ${_this.delivery}, error: ${_this.error}, attachments: ${_this.attachments}, media: ${_this.media}, command: ${_this.command}, boundary: ${_this.boundary})';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, ChatRole role, String text, String reasoning, List<ToolCall> tools, DateTime? timestamp, int? rowId, bool streaming, bool interim, DeliveryState delivery, String? error, List<LocalAttachment> attachments, List<MediaRef> media, String? command, bool boundary
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? role = null,Object? text = null,Object? reasoning = null,Object? tools = null,Object? timestamp = freezed,Object? rowId = freezed,Object? streaming = null,Object? interim = null,Object? delivery = null,Object? error = freezed,Object? attachments = null,Object? media = null,Object? command = freezed,Object? boundary = null,}) {
  return _then(ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ChatRole,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,tools: null == tools ? _self.tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolCall>,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,rowId: freezed == rowId ? _self.rowId : rowId // ignore: cast_nullable_to_non_nullable
as int?,streaming: null == streaming ? _self.streaming : streaming // ignore: cast_nullable_to_non_nullable
as bool,interim: null == interim ? _self.interim : interim // ignore: cast_nullable_to_non_nullable
as bool,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as DeliveryState,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<LocalAttachment>,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,command: freezed == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String?,boundary: null == boundary ? _self.boundary : boundary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ChatRole role,  String text,  String reasoning,  List<ToolCall> tools,  DateTime? timestamp,  int? rowId,  bool streaming,  bool interim,  DeliveryState delivery,  String? error,  List<LocalAttachment> attachments,  List<MediaRef> media,  String? command,  bool boundary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.role,_that.text,_that.reasoning,_that.tools,_that.timestamp,_that.rowId,_that.streaming,_that.interim,_that.delivery,_that.error,_that.attachments,_that.media,_that.command,_that.boundary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ChatRole role,  String text,  String reasoning,  List<ToolCall> tools,  DateTime? timestamp,  int? rowId,  bool streaming,  bool interim,  DeliveryState delivery,  String? error,  List<LocalAttachment> attachments,  List<MediaRef> media,  String? command,  bool boundary)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.role,_that.text,_that.reasoning,_that.tools,_that.timestamp,_that.rowId,_that.streaming,_that.interim,_that.delivery,_that.error,_that.attachments,_that.media,_that.command,_that.boundary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ChatRole role,  String text,  String reasoning,  List<ToolCall> tools,  DateTime? timestamp,  int? rowId,  bool streaming,  bool interim,  DeliveryState delivery,  String? error,  List<LocalAttachment> attachments,  List<MediaRef> media,  String? command,  bool boundary)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.role,_that.text,_that.reasoning,_that.tools,_that.timestamp,_that.rowId,_that.streaming,_that.interim,_that.delivery,_that.error,_that.attachments,_that.media,_that.command,_that.boundary);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessage extends ChatMessage {
  const _ChatMessage({required this.id, required this.role, this.text = '', this.reasoning = '',  List<ToolCall> tools = const <ToolCall>[], this.timestamp, this.rowId, this.streaming = false, this.interim = false, this.delivery = DeliveryState.sent, this.error,  List<LocalAttachment> attachments = const <LocalAttachment>[],  List<MediaRef> media = const <MediaRef>[], this.command, this.boundary = false}): _tools = tools,_attachments = attachments,_media = media,super._();
  

@override final  String id;
@override final  ChatRole role;
@override@JsonKey() final  String text;
@override@JsonKey() final  String reasoning;
 final  List<ToolCall> _tools;
@override@JsonKey() List<ToolCall> get tools {
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tools);
}

@override final  DateTime? timestamp;
/// The gateway's durable row id; live rows get it on the next reload.
@override final  int? rowId;
@override@JsonKey() final  bool streaming;
@override@JsonKey() final  bool interim;
@override@JsonKey() final  DeliveryState delivery;
@override final  String? error;
 final  List<LocalAttachment> _attachments;
@override@JsonKey() List<LocalAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

 final  List<MediaRef> _media;
@override@JsonKey() List<MediaRef> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

/// The slash command typed, for a command row.
@override final  String? command;
/// The line that ends one conversation with the bot. Carries no text.
@override@JsonKey() final  bool boundary;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.text, text) || other.text == text)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&const DeepCollectionEquality().equals(other.tools, _tools)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.rowId, rowId) || other.rowId == rowId)&&(identical(other.streaming, streaming) || other.streaming == streaming)&&(identical(other.interim, interim) || other.interim == interim)&&(identical(other.delivery, delivery) || other.delivery == delivery)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.attachments, _attachments)&&const DeepCollectionEquality().equals(other.media, _media)&&(identical(other.command, command) || other.command == command)&&(identical(other.boundary, boundary) || other.boundary == boundary));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,role,text,reasoning,const DeepCollectionEquality().hash(_tools),timestamp,rowId,streaming,interim,delivery,error,const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_media),command,boundary);
}

@override
String toString() {
    return 'ChatMessage(id: $id, role: $role, text: $text, reasoning: $reasoning, tools: $tools, timestamp: $timestamp, rowId: $rowId, streaming: $streaming, interim: $interim, delivery: $delivery, error: $error, attachments: $attachments, media: $media, command: $command, boundary: $boundary)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, ChatRole role, String text, String reasoning, List<ToolCall> tools, DateTime? timestamp, int? rowId, bool streaming, bool interim, DeliveryState delivery, String? error, List<LocalAttachment> attachments, List<MediaRef> media, String? command, bool boundary
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? role = null,Object? text = null,Object? reasoning = null,Object? tools = null,Object? timestamp = freezed,Object? rowId = freezed,Object? streaming = null,Object? interim = null,Object? delivery = null,Object? error = freezed,Object? attachments = null,Object? media = null,Object? command = freezed,Object? boundary = null,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ChatRole,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,tools: null == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolCall>,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,rowId: freezed == rowId ? _self.rowId : rowId // ignore: cast_nullable_to_non_nullable
as int?,streaming: null == streaming ? _self.streaming : streaming // ignore: cast_nullable_to_non_nullable
as bool,interim: null == interim ? _self.interim : interim // ignore: cast_nullable_to_non_nullable
as bool,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as DeliveryState,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<LocalAttachment>,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,command: freezed == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String?,boundary: null == boundary ? _self.boundary : boundary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ToolCall {

 String get id; String get name; String get context; ToolState get state; String? get resultText; String? get inlineDiff; double? get durationSeconds;
/// Create a copy of ToolCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToolCallCopyWith<ToolCall> get copyWith => _$ToolCallCopyWithImpl<ToolCall>(this as ToolCall, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ToolCall;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToolCall&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.context, _this.context) || other.context == _this.context)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.resultText, _this.resultText) || other.resultText == _this.resultText)&&(identical(other.inlineDiff, _this.inlineDiff) || other.inlineDiff == _this.inlineDiff)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds));
}


@override
int get hashCode {
  final _this = this as ToolCall;
  return Object.hash(runtimeType,_this.id,_this.name,_this.context,_this.state,_this.resultText,_this.inlineDiff,_this.durationSeconds);
}

@override
String toString() {
  final _this = this as ToolCall;
  return 'ToolCall(id: ${_this.id}, name: ${_this.name}, context: ${_this.context}, state: ${_this.state}, resultText: ${_this.resultText}, inlineDiff: ${_this.inlineDiff}, durationSeconds: ${_this.durationSeconds})';
}


}

/// @nodoc
abstract mixin class $ToolCallCopyWith<$Res>  {
  factory $ToolCallCopyWith(ToolCall value, $Res Function(ToolCall) _then) = _$ToolCallCopyWithImpl;
@useResult
$Res call({
 String id, String name, String context, ToolState state, String? resultText, String? inlineDiff, double? durationSeconds
});




}
/// @nodoc
class _$ToolCallCopyWithImpl<$Res>
    implements $ToolCallCopyWith<$Res> {
  _$ToolCallCopyWithImpl(this._self, this._then);

  final ToolCall _self;
  final $Res Function(ToolCall) _then;

/// Create a copy of ToolCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? context = null,Object? state = null,Object? resultText = freezed,Object? inlineDiff = freezed,Object? durationSeconds = freezed,}) {
  return _then(ToolCall(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ToolState,resultText: freezed == resultText ? _self.resultText : resultText // ignore: cast_nullable_to_non_nullable
as String?,inlineDiff: freezed == inlineDiff ? _self.inlineDiff : inlineDiff // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ToolCall].
extension ToolCallPatterns on ToolCall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToolCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToolCall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToolCall value)  $default,){
final _that = this;
switch (_that) {
case _ToolCall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToolCall value)?  $default,){
final _that = this;
switch (_that) {
case _ToolCall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String context,  ToolState state,  String? resultText,  String? inlineDiff,  double? durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToolCall() when $default != null:
return $default(_that.id,_that.name,_that.context,_that.state,_that.resultText,_that.inlineDiff,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String context,  ToolState state,  String? resultText,  String? inlineDiff,  double? durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _ToolCall():
return $default(_that.id,_that.name,_that.context,_that.state,_that.resultText,_that.inlineDiff,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String context,  ToolState state,  String? resultText,  String? inlineDiff,  double? durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _ToolCall() when $default != null:
return $default(_that.id,_that.name,_that.context,_that.state,_that.resultText,_that.inlineDiff,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _ToolCall implements ToolCall {
  const _ToolCall({required this.id, required this.name, this.context = '', this.state = ToolState.running, this.resultText, this.inlineDiff, this.durationSeconds});
  

@override final  String id;
@override final  String name;
@override@JsonKey() final  String context;
@override@JsonKey() final  ToolState state;
@override final  String? resultText;
@override final  String? inlineDiff;
@override final  double? durationSeconds;

/// Create a copy of ToolCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolCallCopyWith<_ToolCall> get copyWith => __$ToolCallCopyWithImpl<_ToolCall>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolCall&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.context, context) || other.context == context)&&(identical(other.state, state) || other.state == state)&&(identical(other.resultText, resultText) || other.resultText == resultText)&&(identical(other.inlineDiff, inlineDiff) || other.inlineDiff == inlineDiff)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,context,state,resultText,inlineDiff,durationSeconds);
}

@override
String toString() {
    return 'ToolCall(id: $id, name: $name, context: $context, state: $state, resultText: $resultText, inlineDiff: $inlineDiff, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$ToolCallCopyWith<$Res> implements $ToolCallCopyWith<$Res> {
  factory _$ToolCallCopyWith(_ToolCall value, $Res Function(_ToolCall) _then) = __$ToolCallCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String context, ToolState state, String? resultText, String? inlineDiff, double? durationSeconds
});




}
/// @nodoc
class __$ToolCallCopyWithImpl<$Res>
    implements _$ToolCallCopyWith<$Res> {
  __$ToolCallCopyWithImpl(this._self, this._then);

  final _ToolCall _self;
  final $Res Function(_ToolCall) _then;

/// Create a copy of ToolCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? context = null,Object? state = null,Object? resultText = freezed,Object? inlineDiff = freezed,Object? durationSeconds = freezed,}) {
  return _then(_ToolCall(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ToolState,resultText: freezed == resultText ? _self.resultText : resultText // ignore: cast_nullable_to_non_nullable
as String?,inlineDiff: freezed == inlineDiff ? _self.inlineDiff : inlineDiff // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$MediaRef {

 String get path; AttachmentKind get kind; String? get dataUrl;
/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaRefCopyWith<MediaRef> get copyWith => _$MediaRefCopyWithImpl<MediaRef>(this as MediaRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaRef&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.dataUrl, _this.dataUrl) || other.dataUrl == _this.dataUrl));
}


@override
int get hashCode {
  final _this = this as MediaRef;
  return Object.hash(runtimeType,_this.path,_this.kind,_this.dataUrl);
}

@override
String toString() {
  final _this = this as MediaRef;
  return 'MediaRef(path: ${_this.path}, kind: ${_this.kind}, dataUrl: ${_this.dataUrl})';
}


}

/// @nodoc
abstract mixin class $MediaRefCopyWith<$Res>  {
  factory $MediaRefCopyWith(MediaRef value, $Res Function(MediaRef) _then) = _$MediaRefCopyWithImpl;
@useResult
$Res call({
 String path, AttachmentKind kind, String? dataUrl
});




}
/// @nodoc
class _$MediaRefCopyWithImpl<$Res>
    implements $MediaRefCopyWith<$Res> {
  _$MediaRefCopyWithImpl(this._self, this._then);

  final MediaRef _self;
  final $Res Function(MediaRef) _then;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? kind = null,Object? dataUrl = freezed,}) {
  return _then(MediaRef(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AttachmentKind,dataUrl: freezed == dataUrl ? _self.dataUrl : dataUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaRef].
extension MediaRefPatterns on MediaRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaRef value)  $default,){
final _that = this;
switch (_that) {
case _MediaRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaRef value)?  $default,){
final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  AttachmentKind kind,  String? dataUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
return $default(_that.path,_that.kind,_that.dataUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  AttachmentKind kind,  String? dataUrl)  $default,) {final _that = this;
switch (_that) {
case _MediaRef():
return $default(_that.path,_that.kind,_that.dataUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  AttachmentKind kind,  String? dataUrl)?  $default,) {final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
return $default(_that.path,_that.kind,_that.dataUrl);case _:
  return null;

}
}

}

/// @nodoc


class _MediaRef extends MediaRef {
  const _MediaRef({required this.path, required this.kind, this.dataUrl}): super._();
  

@override final  String path;
@override final  AttachmentKind kind;
@override final  String? dataUrl;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaRefCopyWith<_MediaRef> get copyWith => __$MediaRefCopyWithImpl<_MediaRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaRef&&(identical(other.path, path) || other.path == path)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.dataUrl, dataUrl) || other.dataUrl == dataUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,kind,dataUrl);
}

@override
String toString() {
    return 'MediaRef(path: $path, kind: $kind, dataUrl: $dataUrl)';
}


}

/// @nodoc
abstract mixin class _$MediaRefCopyWith<$Res> implements $MediaRefCopyWith<$Res> {
  factory _$MediaRefCopyWith(_MediaRef value, $Res Function(_MediaRef) _then) = __$MediaRefCopyWithImpl;
@override @useResult
$Res call({
 String path, AttachmentKind kind, String? dataUrl
});




}
/// @nodoc
class __$MediaRefCopyWithImpl<$Res>
    implements _$MediaRefCopyWith<$Res> {
  __$MediaRefCopyWithImpl(this._self, this._then);

  final _MediaRef _self;
  final $Res Function(_MediaRef) _then;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? kind = null,Object? dataUrl = freezed,}) {
  return _then(_MediaRef(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AttachmentKind,dataUrl: freezed == dataUrl ? _self.dataUrl : dataUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
