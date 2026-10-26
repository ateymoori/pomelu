// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'turn_payloads.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ToolEvent {

/// `tool_id`, else `tool_call_id`, else `id`; empty when none came.
@JsonKey(readValue: _toolId)@LooseString() String get id;@LooseString() String get name;@LooseString() String get context;/// `result_text`, else the raw `result` as text; null when neither came.
@JsonKey(name: 'result_text', readValue: _resultText)@LooseStringOrNull() String? get resultText;@JsonKey(name: 'inline_diff')@LooseString() String get inlineDiff;@JsonKey(name: 'duration_s')@LooseDouble() double? get durationSeconds;/// Any `error` but `false` marks the call failed.
@JsonKey(name: 'error', fromJson: _isError) bool get failed;
/// Create a copy of ToolEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToolEventCopyWith<ToolEvent> get copyWith => _$ToolEventCopyWithImpl<ToolEvent>(this as ToolEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ToolEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToolEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.context, _this.context) || other.context == _this.context)&&(identical(other.resultText, _this.resultText) || other.resultText == _this.resultText)&&(identical(other.inlineDiff, _this.inlineDiff) || other.inlineDiff == _this.inlineDiff)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.failed, _this.failed) || other.failed == _this.failed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ToolEvent;
  return Object.hash(runtimeType,_this.id,_this.name,_this.context,_this.resultText,_this.inlineDiff,_this.durationSeconds,_this.failed);
}

@override
String toString() {
  final _this = this as ToolEvent;
  return 'ToolEvent(id: ${_this.id}, name: ${_this.name}, context: ${_this.context}, resultText: ${_this.resultText}, inlineDiff: ${_this.inlineDiff}, durationSeconds: ${_this.durationSeconds}, failed: ${_this.failed})';
}


}

/// @nodoc
abstract mixin class $ToolEventCopyWith<$Res>  {
  factory $ToolEventCopyWith(ToolEvent value, $Res Function(ToolEvent) _then) = _$ToolEventCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _toolId)@LooseString() String id,@LooseString() String name,@LooseString() String context,@JsonKey(name: 'result_text', readValue: _resultText)@LooseStringOrNull() String? resultText,@JsonKey(name: 'inline_diff')@LooseString() String inlineDiff,@JsonKey(name: 'duration_s')@LooseDouble() double? durationSeconds,@JsonKey(name: 'error', fromJson: _isError) bool failed
});




}
/// @nodoc
class _$ToolEventCopyWithImpl<$Res>
    implements $ToolEventCopyWith<$Res> {
  _$ToolEventCopyWithImpl(this._self, this._then);

  final ToolEvent _self;
  final $Res Function(ToolEvent) _then;

/// Create a copy of ToolEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? context = null,Object? resultText = freezed,Object? inlineDiff = null,Object? durationSeconds = freezed,Object? failed = null,}) {
  return _then(ToolEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,resultText: freezed == resultText ? _self.resultText : resultText // ignore: cast_nullable_to_non_nullable
as String?,inlineDiff: null == inlineDiff ? _self.inlineDiff : inlineDiff // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double?,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ToolEvent].
extension ToolEventPatterns on ToolEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToolEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToolEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToolEvent value)  $default,){
final _that = this;
switch (_that) {
case _ToolEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToolEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ToolEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _toolId)@LooseString()  String id, @LooseString()  String name, @LooseString()  String context, @JsonKey(name: 'result_text', readValue: _resultText)@LooseStringOrNull()  String? resultText, @JsonKey(name: 'inline_diff')@LooseString()  String inlineDiff, @JsonKey(name: 'duration_s')@LooseDouble()  double? durationSeconds, @JsonKey(name: 'error', fromJson: _isError)  bool failed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToolEvent() when $default != null:
return $default(_that.id,_that.name,_that.context,_that.resultText,_that.inlineDiff,_that.durationSeconds,_that.failed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _toolId)@LooseString()  String id, @LooseString()  String name, @LooseString()  String context, @JsonKey(name: 'result_text', readValue: _resultText)@LooseStringOrNull()  String? resultText, @JsonKey(name: 'inline_diff')@LooseString()  String inlineDiff, @JsonKey(name: 'duration_s')@LooseDouble()  double? durationSeconds, @JsonKey(name: 'error', fromJson: _isError)  bool failed)  $default,) {final _that = this;
switch (_that) {
case _ToolEvent():
return $default(_that.id,_that.name,_that.context,_that.resultText,_that.inlineDiff,_that.durationSeconds,_that.failed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _toolId)@LooseString()  String id, @LooseString()  String name, @LooseString()  String context, @JsonKey(name: 'result_text', readValue: _resultText)@LooseStringOrNull()  String? resultText, @JsonKey(name: 'inline_diff')@LooseString()  String inlineDiff, @JsonKey(name: 'duration_s')@LooseDouble()  double? durationSeconds, @JsonKey(name: 'error', fromJson: _isError)  bool failed)?  $default,) {final _that = this;
switch (_that) {
case _ToolEvent() when $default != null:
return $default(_that.id,_that.name,_that.context,_that.resultText,_that.inlineDiff,_that.durationSeconds,_that.failed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _ToolEvent implements ToolEvent {
  const _ToolEvent({@JsonKey(readValue: _toolId)@LooseString() this.id = '', @LooseString() this.name = '', @LooseString() this.context = '', @JsonKey(name: 'result_text', readValue: _resultText)@LooseStringOrNull() this.resultText, @JsonKey(name: 'inline_diff')@LooseString() this.inlineDiff = '', @JsonKey(name: 'duration_s')@LooseDouble() this.durationSeconds, @JsonKey(name: 'error', fromJson: _isError) this.failed = false});
  factory _ToolEvent.fromJson(Map<String, dynamic> json) => _$ToolEventFromJson(json);

/// `tool_id`, else `tool_call_id`, else `id`; empty when none came.
@override@JsonKey(readValue: _toolId)@LooseString() final  String id;
@override@JsonKey()@LooseString() final  String name;
@override@JsonKey()@LooseString() final  String context;
/// `result_text`, else the raw `result` as text; null when neither came.
@override@JsonKey(name: 'result_text', readValue: _resultText)@LooseStringOrNull() final  String? resultText;
@override@JsonKey(name: 'inline_diff')@LooseString() final  String inlineDiff;
@override@JsonKey(name: 'duration_s')@LooseDouble() final  double? durationSeconds;
/// Any `error` but `false` marks the call failed.
@override@JsonKey(name: 'error', fromJson: _isError) final  bool failed;

/// Create a copy of ToolEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolEventCopyWith<_ToolEvent> get copyWith => __$ToolEventCopyWithImpl<_ToolEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.context, context) || other.context == context)&&(identical(other.resultText, resultText) || other.resultText == resultText)&&(identical(other.inlineDiff, inlineDiff) || other.inlineDiff == inlineDiff)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.failed, failed) || other.failed == failed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,context,resultText,inlineDiff,durationSeconds,failed);
}

@override
String toString() {
    return 'ToolEvent(id: $id, name: $name, context: $context, resultText: $resultText, inlineDiff: $inlineDiff, durationSeconds: $durationSeconds, failed: $failed)';
}


}

/// @nodoc
abstract mixin class _$ToolEventCopyWith<$Res> implements $ToolEventCopyWith<$Res> {
  factory _$ToolEventCopyWith(_ToolEvent value, $Res Function(_ToolEvent) _then) = __$ToolEventCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _toolId)@LooseString() String id,@LooseString() String name,@LooseString() String context,@JsonKey(name: 'result_text', readValue: _resultText)@LooseStringOrNull() String? resultText,@JsonKey(name: 'inline_diff')@LooseString() String inlineDiff,@JsonKey(name: 'duration_s')@LooseDouble() double? durationSeconds,@JsonKey(name: 'error', fromJson: _isError) bool failed
});




}
/// @nodoc
class __$ToolEventCopyWithImpl<$Res>
    implements _$ToolEventCopyWith<$Res> {
  __$ToolEventCopyWithImpl(this._self, this._then);

  final _ToolEvent _self;
  final $Res Function(_ToolEvent) _then;

/// Create a copy of ToolEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? context = null,Object? resultText = freezed,Object? inlineDiff = null,Object? durationSeconds = freezed,Object? failed = null,}) {
  return _then(_ToolEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,resultText: freezed == resultText ? _self.resultText : resultText // ignore: cast_nullable_to_non_nullable
as String?,inlineDiff: null == inlineDiff ? _self.inlineDiff : inlineDiff // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double?,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TurnComplete {

@LooseString() String get text;@LooseString() String get reasoning;@LooseString() String get status;@LooseString() String get error;
/// Create a copy of TurnComplete
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TurnCompleteCopyWith<TurnComplete> get copyWith => _$TurnCompleteCopyWithImpl<TurnComplete>(this as TurnComplete, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TurnComplete;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TurnComplete&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.reasoning, _this.reasoning) || other.reasoning == _this.reasoning)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TurnComplete;
  return Object.hash(runtimeType,_this.text,_this.reasoning,_this.status,_this.error);
}

@override
String toString() {
  final _this = this as TurnComplete;
  return 'TurnComplete(text: ${_this.text}, reasoning: ${_this.reasoning}, status: ${_this.status}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $TurnCompleteCopyWith<$Res>  {
  factory $TurnCompleteCopyWith(TurnComplete value, $Res Function(TurnComplete) _then) = _$TurnCompleteCopyWithImpl;
@useResult
$Res call({
@LooseString() String text,@LooseString() String reasoning,@LooseString() String status,@LooseString() String error
});




}
/// @nodoc
class _$TurnCompleteCopyWithImpl<$Res>
    implements $TurnCompleteCopyWith<$Res> {
  _$TurnCompleteCopyWithImpl(this._self, this._then);

  final TurnComplete _self;
  final $Res Function(TurnComplete) _then;

/// Create a copy of TurnComplete
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? reasoning = null,Object? status = null,Object? error = null,}) {
  return _then(TurnComplete(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TurnComplete].
extension TurnCompletePatterns on TurnComplete {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TurnComplete value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TurnComplete() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TurnComplete value)  $default,){
final _that = this;
switch (_that) {
case _TurnComplete():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TurnComplete value)?  $default,){
final _that = this;
switch (_that) {
case _TurnComplete() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String text, @LooseString()  String reasoning, @LooseString()  String status, @LooseString()  String error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TurnComplete() when $default != null:
return $default(_that.text,_that.reasoning,_that.status,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String text, @LooseString()  String reasoning, @LooseString()  String status, @LooseString()  String error)  $default,) {final _that = this;
switch (_that) {
case _TurnComplete():
return $default(_that.text,_that.reasoning,_that.status,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String text, @LooseString()  String reasoning, @LooseString()  String status, @LooseString()  String error)?  $default,) {final _that = this;
switch (_that) {
case _TurnComplete() when $default != null:
return $default(_that.text,_that.reasoning,_that.status,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _TurnComplete implements TurnComplete {
  const _TurnComplete({@LooseString() this.text = '', @LooseString() this.reasoning = '', @LooseString() this.status = '', @LooseString() this.error = ''});
  factory _TurnComplete.fromJson(Map<String, dynamic> json) => _$TurnCompleteFromJson(json);

@override@JsonKey()@LooseString() final  String text;
@override@JsonKey()@LooseString() final  String reasoning;
@override@JsonKey()@LooseString() final  String status;
@override@JsonKey()@LooseString() final  String error;

/// Create a copy of TurnComplete
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TurnCompleteCopyWith<_TurnComplete> get copyWith => __$TurnCompleteCopyWithImpl<_TurnComplete>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TurnComplete&&(identical(other.text, text) || other.text == text)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,reasoning,status,error);
}

@override
String toString() {
    return 'TurnComplete(text: $text, reasoning: $reasoning, status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class _$TurnCompleteCopyWith<$Res> implements $TurnCompleteCopyWith<$Res> {
  factory _$TurnCompleteCopyWith(_TurnComplete value, $Res Function(_TurnComplete) _then) = __$TurnCompleteCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String text,@LooseString() String reasoning,@LooseString() String status,@LooseString() String error
});




}
/// @nodoc
class __$TurnCompleteCopyWithImpl<$Res>
    implements _$TurnCompleteCopyWith<$Res> {
  __$TurnCompleteCopyWithImpl(this._self, this._then);

  final _TurnComplete _self;
  final $Res Function(_TurnComplete) _then;

/// Create a copy of TurnComplete
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? reasoning = null,Object? status = null,Object? error = null,}) {
  return _then(_TurnComplete(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$InterimMessage {

@LooseString() String get text;/// Its words came as deltas already.
@JsonKey(name: 'already_streamed')@LooseBool() bool get alreadyStreamed;
/// Create a copy of InterimMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterimMessageCopyWith<InterimMessage> get copyWith => _$InterimMessageCopyWithImpl<InterimMessage>(this as InterimMessage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InterimMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterimMessage&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.alreadyStreamed, _this.alreadyStreamed) || other.alreadyStreamed == _this.alreadyStreamed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InterimMessage;
  return Object.hash(runtimeType,_this.text,_this.alreadyStreamed);
}

@override
String toString() {
  final _this = this as InterimMessage;
  return 'InterimMessage(text: ${_this.text}, alreadyStreamed: ${_this.alreadyStreamed})';
}


}

/// @nodoc
abstract mixin class $InterimMessageCopyWith<$Res>  {
  factory $InterimMessageCopyWith(InterimMessage value, $Res Function(InterimMessage) _then) = _$InterimMessageCopyWithImpl;
@useResult
$Res call({
@LooseString() String text,@JsonKey(name: 'already_streamed')@LooseBool() bool alreadyStreamed
});




}
/// @nodoc
class _$InterimMessageCopyWithImpl<$Res>
    implements $InterimMessageCopyWith<$Res> {
  _$InterimMessageCopyWithImpl(this._self, this._then);

  final InterimMessage _self;
  final $Res Function(InterimMessage) _then;

/// Create a copy of InterimMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? alreadyStreamed = null,}) {
  return _then(InterimMessage(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,alreadyStreamed: null == alreadyStreamed ? _self.alreadyStreamed : alreadyStreamed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InterimMessage].
extension InterimMessagePatterns on InterimMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterimMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterimMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterimMessage value)  $default,){
final _that = this;
switch (_that) {
case _InterimMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterimMessage value)?  $default,){
final _that = this;
switch (_that) {
case _InterimMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String text, @JsonKey(name: 'already_streamed')@LooseBool()  bool alreadyStreamed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterimMessage() when $default != null:
return $default(_that.text,_that.alreadyStreamed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String text, @JsonKey(name: 'already_streamed')@LooseBool()  bool alreadyStreamed)  $default,) {final _that = this;
switch (_that) {
case _InterimMessage():
return $default(_that.text,_that.alreadyStreamed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String text, @JsonKey(name: 'already_streamed')@LooseBool()  bool alreadyStreamed)?  $default,) {final _that = this;
switch (_that) {
case _InterimMessage() when $default != null:
return $default(_that.text,_that.alreadyStreamed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _InterimMessage implements InterimMessage {
  const _InterimMessage({@LooseString() this.text = '', @JsonKey(name: 'already_streamed')@LooseBool() this.alreadyStreamed = false});
  factory _InterimMessage.fromJson(Map<String, dynamic> json) => _$InterimMessageFromJson(json);

@override@JsonKey()@LooseString() final  String text;
/// Its words came as deltas already.
@override@JsonKey(name: 'already_streamed')@LooseBool() final  bool alreadyStreamed;

/// Create a copy of InterimMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterimMessageCopyWith<_InterimMessage> get copyWith => __$InterimMessageCopyWithImpl<_InterimMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterimMessage&&(identical(other.text, text) || other.text == text)&&(identical(other.alreadyStreamed, alreadyStreamed) || other.alreadyStreamed == alreadyStreamed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,alreadyStreamed);
}

@override
String toString() {
    return 'InterimMessage(text: $text, alreadyStreamed: $alreadyStreamed)';
}


}

/// @nodoc
abstract mixin class _$InterimMessageCopyWith<$Res> implements $InterimMessageCopyWith<$Res> {
  factory _$InterimMessageCopyWith(_InterimMessage value, $Res Function(_InterimMessage) _then) = __$InterimMessageCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String text,@JsonKey(name: 'already_streamed')@LooseBool() bool alreadyStreamed
});




}
/// @nodoc
class __$InterimMessageCopyWithImpl<$Res>
    implements _$InterimMessageCopyWith<$Res> {
  __$InterimMessageCopyWithImpl(this._self, this._then);

  final _InterimMessage _self;
  final $Res Function(_InterimMessage) _then;

/// Create a copy of InterimMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? alreadyStreamed = null,}) {
  return _then(_InterimMessage(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,alreadyStreamed: null == alreadyStreamed ? _self.alreadyStreamed : alreadyStreamed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SessionInfoEvent {

@LooseString() String get model;@JsonKey(name: 'reasoning_effort')@LooseString() String get reasoningEffort;@LooseString() String get provider;@JsonKey(fromJson: _strictBool) bool? get running;
/// Create a copy of SessionInfoEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionInfoEventCopyWith<SessionInfoEvent> get copyWith => _$SessionInfoEventCopyWithImpl<SessionInfoEvent>(this as SessionInfoEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionInfoEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionInfoEvent&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.reasoningEffort, _this.reasoningEffort) || other.reasoningEffort == _this.reasoningEffort)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.running, _this.running) || other.running == _this.running));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionInfoEvent;
  return Object.hash(runtimeType,_this.model,_this.reasoningEffort,_this.provider,_this.running);
}

@override
String toString() {
  final _this = this as SessionInfoEvent;
  return 'SessionInfoEvent(model: ${_this.model}, reasoningEffort: ${_this.reasoningEffort}, provider: ${_this.provider}, running: ${_this.running})';
}


}

/// @nodoc
abstract mixin class $SessionInfoEventCopyWith<$Res>  {
  factory $SessionInfoEventCopyWith(SessionInfoEvent value, $Res Function(SessionInfoEvent) _then) = _$SessionInfoEventCopyWithImpl;
@useResult
$Res call({
@LooseString() String model,@JsonKey(name: 'reasoning_effort')@LooseString() String reasoningEffort,@LooseString() String provider,@JsonKey(fromJson: _strictBool) bool? running
});




}
/// @nodoc
class _$SessionInfoEventCopyWithImpl<$Res>
    implements $SessionInfoEventCopyWith<$Res> {
  _$SessionInfoEventCopyWithImpl(this._self, this._then);

  final SessionInfoEvent _self;
  final $Res Function(SessionInfoEvent) _then;

/// Create a copy of SessionInfoEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? model = null,Object? reasoningEffort = null,Object? provider = null,Object? running = freezed,}) {
  return _then(SessionInfoEvent(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,reasoningEffort: null == reasoningEffort ? _self.reasoningEffort : reasoningEffort // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,running: freezed == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionInfoEvent].
extension SessionInfoEventPatterns on SessionInfoEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionInfoEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionInfoEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionInfoEvent value)  $default,){
final _that = this;
switch (_that) {
case _SessionInfoEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionInfoEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SessionInfoEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String model, @JsonKey(name: 'reasoning_effort')@LooseString()  String reasoningEffort, @LooseString()  String provider, @JsonKey(fromJson: _strictBool)  bool? running)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionInfoEvent() when $default != null:
return $default(_that.model,_that.reasoningEffort,_that.provider,_that.running);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String model, @JsonKey(name: 'reasoning_effort')@LooseString()  String reasoningEffort, @LooseString()  String provider, @JsonKey(fromJson: _strictBool)  bool? running)  $default,) {final _that = this;
switch (_that) {
case _SessionInfoEvent():
return $default(_that.model,_that.reasoningEffort,_that.provider,_that.running);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String model, @JsonKey(name: 'reasoning_effort')@LooseString()  String reasoningEffort, @LooseString()  String provider, @JsonKey(fromJson: _strictBool)  bool? running)?  $default,) {final _that = this;
switch (_that) {
case _SessionInfoEvent() when $default != null:
return $default(_that.model,_that.reasoningEffort,_that.provider,_that.running);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _SessionInfoEvent implements SessionInfoEvent {
  const _SessionInfoEvent({@LooseString() this.model = '', @JsonKey(name: 'reasoning_effort')@LooseString() this.reasoningEffort = '', @LooseString() this.provider = '', @JsonKey(fromJson: _strictBool) this.running});
  factory _SessionInfoEvent.fromJson(Map<String, dynamic> json) => _$SessionInfoEventFromJson(json);

@override@JsonKey()@LooseString() final  String model;
@override@JsonKey(name: 'reasoning_effort')@LooseString() final  String reasoningEffort;
@override@JsonKey()@LooseString() final  String provider;
@override@JsonKey(fromJson: _strictBool) final  bool? running;

/// Create a copy of SessionInfoEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionInfoEventCopyWith<_SessionInfoEvent> get copyWith => __$SessionInfoEventCopyWithImpl<_SessionInfoEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionInfoEvent&&(identical(other.model, model) || other.model == model)&&(identical(other.reasoningEffort, reasoningEffort) || other.reasoningEffort == reasoningEffort)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.running, running) || other.running == running));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,model,reasoningEffort,provider,running);
}

@override
String toString() {
    return 'SessionInfoEvent(model: $model, reasoningEffort: $reasoningEffort, provider: $provider, running: $running)';
}


}

/// @nodoc
abstract mixin class _$SessionInfoEventCopyWith<$Res> implements $SessionInfoEventCopyWith<$Res> {
  factory _$SessionInfoEventCopyWith(_SessionInfoEvent value, $Res Function(_SessionInfoEvent) _then) = __$SessionInfoEventCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String model,@JsonKey(name: 'reasoning_effort')@LooseString() String reasoningEffort,@LooseString() String provider,@JsonKey(fromJson: _strictBool) bool? running
});




}
/// @nodoc
class __$SessionInfoEventCopyWithImpl<$Res>
    implements _$SessionInfoEventCopyWith<$Res> {
  __$SessionInfoEventCopyWithImpl(this._self, this._then);

  final _SessionInfoEvent _self;
  final $Res Function(_SessionInfoEvent) _then;

/// Create a copy of SessionInfoEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? model = null,Object? reasoningEffort = null,Object? provider = null,Object? running = freezed,}) {
  return _then(_SessionInfoEvent(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,reasoningEffort: null == reasoningEffort ? _self.reasoningEffort : reasoningEffort // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,running: freezed == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
