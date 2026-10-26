// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionMessage {

@LooseString() String get role;@LooseString() String get text;@JsonKey(fromJson: dateTimeFromEpochSeconds) DateTime? get timestamp;@JsonKey(name: 'row_id')@LooseIntOrNull() int? get rowId;@LooseIntOrNull() int? get id;@LooseStringOrNull() String? get reasoning;@JsonKey(name: 'reasoning_content')@LooseStringOrNull() String? get reasoningContent;@JsonKey(name: 'display_kind')@LooseStringOrNull() String? get displayKind;@LooseStringOrNull() String? get name;@LooseString() String get context;@ContentText() String get content;@JsonKey(name: 'display_content')@LooseStringOrNull() String? get displayContent;@JsonKey(name: 'tool_name')@LooseStringOrNull() String? get storedToolName;
/// Create a copy of SessionMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionMessageCopyWith<SessionMessage> get copyWith => _$SessionMessageCopyWithImpl<SessionMessage>(this as SessionMessage, _$identity);

  /// Serializes this SessionMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionMessage&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&(identical(other.rowId, _this.rowId) || other.rowId == _this.rowId)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reasoning, _this.reasoning) || other.reasoning == _this.reasoning)&&(identical(other.reasoningContent, _this.reasoningContent) || other.reasoningContent == _this.reasoningContent)&&(identical(other.displayKind, _this.displayKind) || other.displayKind == _this.displayKind)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.context, _this.context) || other.context == _this.context)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.displayContent, _this.displayContent) || other.displayContent == _this.displayContent)&&(identical(other.storedToolName, _this.storedToolName) || other.storedToolName == _this.storedToolName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionMessage;
  return Object.hash(runtimeType,_this.role,_this.text,_this.timestamp,_this.rowId,_this.id,_this.reasoning,_this.reasoningContent,_this.displayKind,_this.name,_this.context,_this.content,_this.displayContent,_this.storedToolName);
}

@override
String toString() {
  final _this = this as SessionMessage;
  return 'SessionMessage(role: ${_this.role}, text: ${_this.text}, timestamp: ${_this.timestamp}, rowId: ${_this.rowId}, id: ${_this.id}, reasoning: ${_this.reasoning}, reasoningContent: ${_this.reasoningContent}, displayKind: ${_this.displayKind}, name: ${_this.name}, context: ${_this.context}, content: ${_this.content}, displayContent: ${_this.displayContent}, storedToolName: ${_this.storedToolName})';
}


}

/// @nodoc
abstract mixin class $SessionMessageCopyWith<$Res>  {
  factory $SessionMessageCopyWith(SessionMessage value, $Res Function(SessionMessage) _then) = _$SessionMessageCopyWithImpl;
@useResult
$Res call({
@LooseString() String role,@LooseString() String text,@JsonKey(fromJson: dateTimeFromEpochSeconds) DateTime? timestamp,@JsonKey(name: 'row_id')@LooseIntOrNull() int? rowId,@LooseIntOrNull() int? id,@LooseStringOrNull() String? reasoning,@JsonKey(name: 'reasoning_content')@LooseStringOrNull() String? reasoningContent,@JsonKey(name: 'display_kind')@LooseStringOrNull() String? displayKind,@LooseStringOrNull() String? name,@LooseString() String context,@ContentText() String content,@JsonKey(name: 'display_content')@LooseStringOrNull() String? displayContent,@JsonKey(name: 'tool_name')@LooseStringOrNull() String? storedToolName
});




}
/// @nodoc
class _$SessionMessageCopyWithImpl<$Res>
    implements $SessionMessageCopyWith<$Res> {
  _$SessionMessageCopyWithImpl(this._self, this._then);

  final SessionMessage _self;
  final $Res Function(SessionMessage) _then;

/// Create a copy of SessionMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? text = null,Object? timestamp = freezed,Object? rowId = freezed,Object? id = freezed,Object? reasoning = freezed,Object? reasoningContent = freezed,Object? displayKind = freezed,Object? name = freezed,Object? context = null,Object? content = null,Object? displayContent = freezed,Object? storedToolName = freezed,}) {
  return _then(SessionMessage(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,rowId: freezed == rowId ? _self.rowId : rowId // ignore: cast_nullable_to_non_nullable
as int?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,reasoning: freezed == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String?,reasoningContent: freezed == reasoningContent ? _self.reasoningContent : reasoningContent // ignore: cast_nullable_to_non_nullable
as String?,displayKind: freezed == displayKind ? _self.displayKind : displayKind // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,displayContent: freezed == displayContent ? _self.displayContent : displayContent // ignore: cast_nullable_to_non_nullable
as String?,storedToolName: freezed == storedToolName ? _self.storedToolName : storedToolName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionMessage].
extension SessionMessagePatterns on SessionMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionMessage value)  $default,){
final _that = this;
switch (_that) {
case _SessionMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionMessage value)?  $default,){
final _that = this;
switch (_that) {
case _SessionMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String role, @LooseString()  String text, @JsonKey(fromJson: dateTimeFromEpochSeconds)  DateTime? timestamp, @JsonKey(name: 'row_id')@LooseIntOrNull()  int? rowId, @LooseIntOrNull()  int? id, @LooseStringOrNull()  String? reasoning, @JsonKey(name: 'reasoning_content')@LooseStringOrNull()  String? reasoningContent, @JsonKey(name: 'display_kind')@LooseStringOrNull()  String? displayKind, @LooseStringOrNull()  String? name, @LooseString()  String context, @ContentText()  String content, @JsonKey(name: 'display_content')@LooseStringOrNull()  String? displayContent, @JsonKey(name: 'tool_name')@LooseStringOrNull()  String? storedToolName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionMessage() when $default != null:
return $default(_that.role,_that.text,_that.timestamp,_that.rowId,_that.id,_that.reasoning,_that.reasoningContent,_that.displayKind,_that.name,_that.context,_that.content,_that.displayContent,_that.storedToolName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String role, @LooseString()  String text, @JsonKey(fromJson: dateTimeFromEpochSeconds)  DateTime? timestamp, @JsonKey(name: 'row_id')@LooseIntOrNull()  int? rowId, @LooseIntOrNull()  int? id, @LooseStringOrNull()  String? reasoning, @JsonKey(name: 'reasoning_content')@LooseStringOrNull()  String? reasoningContent, @JsonKey(name: 'display_kind')@LooseStringOrNull()  String? displayKind, @LooseStringOrNull()  String? name, @LooseString()  String context, @ContentText()  String content, @JsonKey(name: 'display_content')@LooseStringOrNull()  String? displayContent, @JsonKey(name: 'tool_name')@LooseStringOrNull()  String? storedToolName)  $default,) {final _that = this;
switch (_that) {
case _SessionMessage():
return $default(_that.role,_that.text,_that.timestamp,_that.rowId,_that.id,_that.reasoning,_that.reasoningContent,_that.displayKind,_that.name,_that.context,_that.content,_that.displayContent,_that.storedToolName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String role, @LooseString()  String text, @JsonKey(fromJson: dateTimeFromEpochSeconds)  DateTime? timestamp, @JsonKey(name: 'row_id')@LooseIntOrNull()  int? rowId, @LooseIntOrNull()  int? id, @LooseStringOrNull()  String? reasoning, @JsonKey(name: 'reasoning_content')@LooseStringOrNull()  String? reasoningContent, @JsonKey(name: 'display_kind')@LooseStringOrNull()  String? displayKind, @LooseStringOrNull()  String? name, @LooseString()  String context, @ContentText()  String content, @JsonKey(name: 'display_content')@LooseStringOrNull()  String? displayContent, @JsonKey(name: 'tool_name')@LooseStringOrNull()  String? storedToolName)?  $default,) {final _that = this;
switch (_that) {
case _SessionMessage() when $default != null:
return $default(_that.role,_that.text,_that.timestamp,_that.rowId,_that.id,_that.reasoning,_that.reasoningContent,_that.displayKind,_that.name,_that.context,_that.content,_that.displayContent,_that.storedToolName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionMessage extends SessionMessage {
  const _SessionMessage({@LooseString() this.role = '', @LooseString() this.text = '', @JsonKey(fromJson: dateTimeFromEpochSeconds) this.timestamp, @JsonKey(name: 'row_id')@LooseIntOrNull() this.rowId, @LooseIntOrNull() this.id, @LooseStringOrNull() this.reasoning, @JsonKey(name: 'reasoning_content')@LooseStringOrNull() this.reasoningContent, @JsonKey(name: 'display_kind')@LooseStringOrNull() this.displayKind, @LooseStringOrNull() this.name, @LooseString() this.context = '', @ContentText() this.content = '', @JsonKey(name: 'display_content')@LooseStringOrNull() this.displayContent, @JsonKey(name: 'tool_name')@LooseStringOrNull() this.storedToolName}): super._();
  factory _SessionMessage.fromJson(Map<String, dynamic> json) => _$SessionMessageFromJson(json);

@override@JsonKey()@LooseString() final  String role;
@override@JsonKey()@LooseString() final  String text;
@override@JsonKey(fromJson: dateTimeFromEpochSeconds) final  DateTime? timestamp;
@override@JsonKey(name: 'row_id')@LooseIntOrNull() final  int? rowId;
@override@LooseIntOrNull() final  int? id;
@override@LooseStringOrNull() final  String? reasoning;
@override@JsonKey(name: 'reasoning_content')@LooseStringOrNull() final  String? reasoningContent;
@override@JsonKey(name: 'display_kind')@LooseStringOrNull() final  String? displayKind;
@override@LooseStringOrNull() final  String? name;
@override@JsonKey()@LooseString() final  String context;
@override@JsonKey()@ContentText() final  String content;
@override@JsonKey(name: 'display_content')@LooseStringOrNull() final  String? displayContent;
@override@JsonKey(name: 'tool_name')@LooseStringOrNull() final  String? storedToolName;

/// Create a copy of SessionMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionMessageCopyWith<_SessionMessage> get copyWith => __$SessionMessageCopyWithImpl<_SessionMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionMessageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.text, text) || other.text == text)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.rowId, rowId) || other.rowId == rowId)&&(identical(other.id, id) || other.id == id)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&(identical(other.reasoningContent, reasoningContent) || other.reasoningContent == reasoningContent)&&(identical(other.displayKind, displayKind) || other.displayKind == displayKind)&&(identical(other.name, name) || other.name == name)&&(identical(other.context, context) || other.context == context)&&(identical(other.content, content) || other.content == content)&&(identical(other.displayContent, displayContent) || other.displayContent == displayContent)&&(identical(other.storedToolName, storedToolName) || other.storedToolName == storedToolName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,role,text,timestamp,rowId,id,reasoning,reasoningContent,displayKind,name,context,content,displayContent,storedToolName);
}

@override
String toString() {
    return 'SessionMessage(role: $role, text: $text, timestamp: $timestamp, rowId: $rowId, id: $id, reasoning: $reasoning, reasoningContent: $reasoningContent, displayKind: $displayKind, name: $name, context: $context, content: $content, displayContent: $displayContent, storedToolName: $storedToolName)';
}


}

/// @nodoc
abstract mixin class _$SessionMessageCopyWith<$Res> implements $SessionMessageCopyWith<$Res> {
  factory _$SessionMessageCopyWith(_SessionMessage value, $Res Function(_SessionMessage) _then) = __$SessionMessageCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String role,@LooseString() String text,@JsonKey(fromJson: dateTimeFromEpochSeconds) DateTime? timestamp,@JsonKey(name: 'row_id')@LooseIntOrNull() int? rowId,@LooseIntOrNull() int? id,@LooseStringOrNull() String? reasoning,@JsonKey(name: 'reasoning_content')@LooseStringOrNull() String? reasoningContent,@JsonKey(name: 'display_kind')@LooseStringOrNull() String? displayKind,@LooseStringOrNull() String? name,@LooseString() String context,@ContentText() String content,@JsonKey(name: 'display_content')@LooseStringOrNull() String? displayContent,@JsonKey(name: 'tool_name')@LooseStringOrNull() String? storedToolName
});




}
/// @nodoc
class __$SessionMessageCopyWithImpl<$Res>
    implements _$SessionMessageCopyWith<$Res> {
  __$SessionMessageCopyWithImpl(this._self, this._then);

  final _SessionMessage _self;
  final $Res Function(_SessionMessage) _then;

/// Create a copy of SessionMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? text = null,Object? timestamp = freezed,Object? rowId = freezed,Object? id = freezed,Object? reasoning = freezed,Object? reasoningContent = freezed,Object? displayKind = freezed,Object? name = freezed,Object? context = null,Object? content = null,Object? displayContent = freezed,Object? storedToolName = freezed,}) {
  return _then(_SessionMessage(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,rowId: freezed == rowId ? _self.rowId : rowId // ignore: cast_nullable_to_non_nullable
as int?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,reasoning: freezed == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String?,reasoningContent: freezed == reasoningContent ? _self.reasoningContent : reasoningContent // ignore: cast_nullable_to_non_nullable
as String?,displayKind: freezed == displayKind ? _self.displayKind : displayKind // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,displayContent: freezed == displayContent ? _self.displayContent : displayContent // ignore: cast_nullable_to_non_nullable
as String?,storedToolName: freezed == storedToolName ? _self.storedToolName : storedToolName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
