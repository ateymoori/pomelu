// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_payloads.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GatewayNotice {

@JsonKey(includeFromJson: false) String get sessionId;@_Trimmed() String get text;@JsonKey(fromJson: _level) String get level;@LooseString() String get key;@LooseString() String get id;@JsonKey(name: 'ttl_ms')@LooseIntOrNull() int? get ttlMs;
/// Create a copy of GatewayNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GatewayNoticeCopyWith<GatewayNotice> get copyWith => _$GatewayNoticeCopyWithImpl<GatewayNotice>(this as GatewayNotice, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GatewayNotice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GatewayNotice&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.ttlMs, _this.ttlMs) || other.ttlMs == _this.ttlMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GatewayNotice;
  return Object.hash(runtimeType,_this.sessionId,_this.text,_this.level,_this.key,_this.id,_this.ttlMs);
}

@override
String toString() {
  final _this = this as GatewayNotice;
  return 'GatewayNotice(sessionId: ${_this.sessionId}, text: ${_this.text}, level: ${_this.level}, key: ${_this.key}, id: ${_this.id}, ttlMs: ${_this.ttlMs})';
}


}

/// @nodoc
abstract mixin class $GatewayNoticeCopyWith<$Res>  {
  factory $GatewayNoticeCopyWith(GatewayNotice value, $Res Function(GatewayNotice) _then) = _$GatewayNoticeCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false) String sessionId,@_Trimmed() String text,@JsonKey(fromJson: _level) String level,@LooseString() String key,@LooseString() String id,@JsonKey(name: 'ttl_ms')@LooseIntOrNull() int? ttlMs
});




}
/// @nodoc
class _$GatewayNoticeCopyWithImpl<$Res>
    implements $GatewayNoticeCopyWith<$Res> {
  _$GatewayNoticeCopyWithImpl(this._self, this._then);

  final GatewayNotice _self;
  final $Res Function(GatewayNotice) _then;

/// Create a copy of GatewayNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? text = null,Object? level = null,Object? key = null,Object? id = null,Object? ttlMs = freezed,}) {
  return _then(GatewayNotice(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ttlMs: freezed == ttlMs ? _self.ttlMs : ttlMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [GatewayNotice].
extension GatewayNoticePatterns on GatewayNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GatewayNotice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GatewayNotice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GatewayNotice value)  $default,){
final _that = this;
switch (_that) {
case _GatewayNotice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GatewayNotice value)?  $default,){
final _that = this;
switch (_that) {
case _GatewayNotice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false)  String sessionId, @_Trimmed()  String text, @JsonKey(fromJson: _level)  String level, @LooseString()  String key, @LooseString()  String id, @JsonKey(name: 'ttl_ms')@LooseIntOrNull()  int? ttlMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GatewayNotice() when $default != null:
return $default(_that.sessionId,_that.text,_that.level,_that.key,_that.id,_that.ttlMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false)  String sessionId, @_Trimmed()  String text, @JsonKey(fromJson: _level)  String level, @LooseString()  String key, @LooseString()  String id, @JsonKey(name: 'ttl_ms')@LooseIntOrNull()  int? ttlMs)  $default,) {final _that = this;
switch (_that) {
case _GatewayNotice():
return $default(_that.sessionId,_that.text,_that.level,_that.key,_that.id,_that.ttlMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false)  String sessionId, @_Trimmed()  String text, @JsonKey(fromJson: _level)  String level, @LooseString()  String key, @LooseString()  String id, @JsonKey(name: 'ttl_ms')@LooseIntOrNull()  int? ttlMs)?  $default,) {final _that = this;
switch (_that) {
case _GatewayNotice() when $default != null:
return $default(_that.sessionId,_that.text,_that.level,_that.key,_that.id,_that.ttlMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _GatewayNotice extends GatewayNotice {
  const _GatewayNotice({@JsonKey(includeFromJson: false) this.sessionId = '', @_Trimmed() this.text = '', @JsonKey(fromJson: _level) this.level = GatewayNotice.levelInfo, @LooseString() this.key = '', @LooseString() this.id = '', @JsonKey(name: 'ttl_ms')@LooseIntOrNull() this.ttlMs}): super._();
  factory _GatewayNotice.fromJson(Map<String, dynamic> json) => _$GatewayNoticeFromJson(json);

@override@JsonKey(includeFromJson: false) final  String sessionId;
@override@JsonKey()@_Trimmed() final  String text;
@override@JsonKey(fromJson: _level) final  String level;
@override@JsonKey()@LooseString() final  String key;
@override@JsonKey()@LooseString() final  String id;
@override@JsonKey(name: 'ttl_ms')@LooseIntOrNull() final  int? ttlMs;

/// Create a copy of GatewayNotice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GatewayNoticeCopyWith<_GatewayNotice> get copyWith => __$GatewayNoticeCopyWithImpl<_GatewayNotice>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GatewayNotice&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.text, text) || other.text == text)&&(identical(other.level, level) || other.level == level)&&(identical(other.key, key) || other.key == key)&&(identical(other.id, id) || other.id == id)&&(identical(other.ttlMs, ttlMs) || other.ttlMs == ttlMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,text,level,key,id,ttlMs);
}

@override
String toString() {
    return 'GatewayNotice(sessionId: $sessionId, text: $text, level: $level, key: $key, id: $id, ttlMs: $ttlMs)';
}


}

/// @nodoc
abstract mixin class _$GatewayNoticeCopyWith<$Res> implements $GatewayNoticeCopyWith<$Res> {
  factory _$GatewayNoticeCopyWith(_GatewayNotice value, $Res Function(_GatewayNotice) _then) = __$GatewayNoticeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false) String sessionId,@_Trimmed() String text,@JsonKey(fromJson: _level) String level,@LooseString() String key,@LooseString() String id,@JsonKey(name: 'ttl_ms')@LooseIntOrNull() int? ttlMs
});




}
/// @nodoc
class __$GatewayNoticeCopyWithImpl<$Res>
    implements _$GatewayNoticeCopyWith<$Res> {
  __$GatewayNoticeCopyWithImpl(this._self, this._then);

  final _GatewayNotice _self;
  final $Res Function(_GatewayNotice) _then;

/// Create a copy of GatewayNotice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? text = null,Object? level = null,Object? key = null,Object? id = null,Object? ttlMs = freezed,}) {
  return _then(_GatewayNotice(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ttlMs: freezed == ttlMs ? _self.ttlMs : ttlMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$BackgroundResult {

@JsonKey(includeFromJson: false) String get sessionId;@JsonKey(name: 'task_id')@LooseString() String get taskId;@_Trimmed() String get text;
/// Create a copy of BackgroundResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackgroundResultCopyWith<BackgroundResult> get copyWith => _$BackgroundResultCopyWithImpl<BackgroundResult>(this as BackgroundResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BackgroundResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackgroundResult&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.text, _this.text) || other.text == _this.text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BackgroundResult;
  return Object.hash(runtimeType,_this.sessionId,_this.taskId,_this.text);
}

@override
String toString() {
  final _this = this as BackgroundResult;
  return 'BackgroundResult(sessionId: ${_this.sessionId}, taskId: ${_this.taskId}, text: ${_this.text})';
}


}

/// @nodoc
abstract mixin class $BackgroundResultCopyWith<$Res>  {
  factory $BackgroundResultCopyWith(BackgroundResult value, $Res Function(BackgroundResult) _then) = _$BackgroundResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false) String sessionId,@JsonKey(name: 'task_id')@LooseString() String taskId,@_Trimmed() String text
});




}
/// @nodoc
class _$BackgroundResultCopyWithImpl<$Res>
    implements $BackgroundResultCopyWith<$Res> {
  _$BackgroundResultCopyWithImpl(this._self, this._then);

  final BackgroundResult _self;
  final $Res Function(BackgroundResult) _then;

/// Create a copy of BackgroundResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? taskId = null,Object? text = null,}) {
  return _then(BackgroundResult(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BackgroundResult].
extension BackgroundResultPatterns on BackgroundResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackgroundResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackgroundResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackgroundResult value)  $default,){
final _that = this;
switch (_that) {
case _BackgroundResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackgroundResult value)?  $default,){
final _that = this;
switch (_that) {
case _BackgroundResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false)  String sessionId, @JsonKey(name: 'task_id')@LooseString()  String taskId, @_Trimmed()  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackgroundResult() when $default != null:
return $default(_that.sessionId,_that.taskId,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false)  String sessionId, @JsonKey(name: 'task_id')@LooseString()  String taskId, @_Trimmed()  String text)  $default,) {final _that = this;
switch (_that) {
case _BackgroundResult():
return $default(_that.sessionId,_that.taskId,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false)  String sessionId, @JsonKey(name: 'task_id')@LooseString()  String taskId, @_Trimmed()  String text)?  $default,) {final _that = this;
switch (_that) {
case _BackgroundResult() when $default != null:
return $default(_that.sessionId,_that.taskId,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _BackgroundResult extends BackgroundResult {
  const _BackgroundResult({@JsonKey(includeFromJson: false) this.sessionId = '', @JsonKey(name: 'task_id')@LooseString() this.taskId = '', @_Trimmed() this.text = ''}): super._();
  factory _BackgroundResult.fromJson(Map<String, dynamic> json) => _$BackgroundResultFromJson(json);

@override@JsonKey(includeFromJson: false) final  String sessionId;
@override@JsonKey(name: 'task_id')@LooseString() final  String taskId;
@override@JsonKey()@_Trimmed() final  String text;

/// Create a copy of BackgroundResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackgroundResultCopyWith<_BackgroundResult> get copyWith => __$BackgroundResultCopyWithImpl<_BackgroundResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackgroundResult&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,taskId,text);
}

@override
String toString() {
    return 'BackgroundResult(sessionId: $sessionId, taskId: $taskId, text: $text)';
}


}

/// @nodoc
abstract mixin class _$BackgroundResultCopyWith<$Res> implements $BackgroundResultCopyWith<$Res> {
  factory _$BackgroundResultCopyWith(_BackgroundResult value, $Res Function(_BackgroundResult) _then) = __$BackgroundResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false) String sessionId,@JsonKey(name: 'task_id')@LooseString() String taskId,@_Trimmed() String text
});




}
/// @nodoc
class __$BackgroundResultCopyWithImpl<$Res>
    implements _$BackgroundResultCopyWith<$Res> {
  __$BackgroundResultCopyWithImpl(this._self, this._then);

  final _BackgroundResult _self;
  final $Res Function(_BackgroundResult) _then;

/// Create a copy of BackgroundResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? taskId = null,Object? text = null,}) {
  return _then(_BackgroundResult(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SessionUsage {

@JsonKey(includeFromJson: false) String get sessionId;@LooseString() String get model;@LooseInt() int get input;@LooseInt() int get output;@LooseInt() int get reasoning;@LooseInt() int get total;@LooseInt() int get calls;@LooseInt() int get compressions;@JsonKey(name: 'cache_hit_pct')@LooseIntOrNull() int? get cacheHitPct;/// `context_percent`, else the older `context_pct`.
@JsonKey(name: 'context_percent', readValue: _contextPct)@LooseDouble() double? get contextPct;@JsonKey(name: 'context_used')@LooseIntOrNull() int? get contextUsed;@JsonKey(name: 'context_max')@LooseIntOrNull() int? get contextMax;
/// Create a copy of SessionUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionUsageCopyWith<SessionUsage> get copyWith => _$SessionUsageCopyWithImpl<SessionUsage>(this as SessionUsage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionUsage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionUsage&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.input, _this.input) || other.input == _this.input)&&(identical(other.output, _this.output) || other.output == _this.output)&&(identical(other.reasoning, _this.reasoning) || other.reasoning == _this.reasoning)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.calls, _this.calls) || other.calls == _this.calls)&&(identical(other.compressions, _this.compressions) || other.compressions == _this.compressions)&&(identical(other.cacheHitPct, _this.cacheHitPct) || other.cacheHitPct == _this.cacheHitPct)&&(identical(other.contextPct, _this.contextPct) || other.contextPct == _this.contextPct)&&(identical(other.contextUsed, _this.contextUsed) || other.contextUsed == _this.contextUsed)&&(identical(other.contextMax, _this.contextMax) || other.contextMax == _this.contextMax));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionUsage;
  return Object.hash(runtimeType,_this.sessionId,_this.model,_this.input,_this.output,_this.reasoning,_this.total,_this.calls,_this.compressions,_this.cacheHitPct,_this.contextPct,_this.contextUsed,_this.contextMax);
}

@override
String toString() {
  final _this = this as SessionUsage;
  return 'SessionUsage(sessionId: ${_this.sessionId}, model: ${_this.model}, input: ${_this.input}, output: ${_this.output}, reasoning: ${_this.reasoning}, total: ${_this.total}, calls: ${_this.calls}, compressions: ${_this.compressions}, cacheHitPct: ${_this.cacheHitPct}, contextPct: ${_this.contextPct}, contextUsed: ${_this.contextUsed}, contextMax: ${_this.contextMax})';
}


}

/// @nodoc
abstract mixin class $SessionUsageCopyWith<$Res>  {
  factory $SessionUsageCopyWith(SessionUsage value, $Res Function(SessionUsage) _then) = _$SessionUsageCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false) String sessionId,@LooseString() String model,@LooseInt() int input,@LooseInt() int output,@LooseInt() int reasoning,@LooseInt() int total,@LooseInt() int calls,@LooseInt() int compressions,@JsonKey(name: 'cache_hit_pct')@LooseIntOrNull() int? cacheHitPct,@JsonKey(name: 'context_percent', readValue: _contextPct)@LooseDouble() double? contextPct,@JsonKey(name: 'context_used')@LooseIntOrNull() int? contextUsed,@JsonKey(name: 'context_max')@LooseIntOrNull() int? contextMax
});




}
/// @nodoc
class _$SessionUsageCopyWithImpl<$Res>
    implements $SessionUsageCopyWith<$Res> {
  _$SessionUsageCopyWithImpl(this._self, this._then);

  final SessionUsage _self;
  final $Res Function(SessionUsage) _then;

/// Create a copy of SessionUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? model = null,Object? input = null,Object? output = null,Object? reasoning = null,Object? total = null,Object? calls = null,Object? compressions = null,Object? cacheHitPct = freezed,Object? contextPct = freezed,Object? contextUsed = freezed,Object? contextMax = freezed,}) {
  return _then(SessionUsage(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as int,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as int,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,calls: null == calls ? _self.calls : calls // ignore: cast_nullable_to_non_nullable
as int,compressions: null == compressions ? _self.compressions : compressions // ignore: cast_nullable_to_non_nullable
as int,cacheHitPct: freezed == cacheHitPct ? _self.cacheHitPct : cacheHitPct // ignore: cast_nullable_to_non_nullable
as int?,contextPct: freezed == contextPct ? _self.contextPct : contextPct // ignore: cast_nullable_to_non_nullable
as double?,contextUsed: freezed == contextUsed ? _self.contextUsed : contextUsed // ignore: cast_nullable_to_non_nullable
as int?,contextMax: freezed == contextMax ? _self.contextMax : contextMax // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionUsage].
extension SessionUsagePatterns on SessionUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionUsage value)  $default,){
final _that = this;
switch (_that) {
case _SessionUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionUsage value)?  $default,){
final _that = this;
switch (_that) {
case _SessionUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false)  String sessionId, @LooseString()  String model, @LooseInt()  int input, @LooseInt()  int output, @LooseInt()  int reasoning, @LooseInt()  int total, @LooseInt()  int calls, @LooseInt()  int compressions, @JsonKey(name: 'cache_hit_pct')@LooseIntOrNull()  int? cacheHitPct, @JsonKey(name: 'context_percent', readValue: _contextPct)@LooseDouble()  double? contextPct, @JsonKey(name: 'context_used')@LooseIntOrNull()  int? contextUsed, @JsonKey(name: 'context_max')@LooseIntOrNull()  int? contextMax)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionUsage() when $default != null:
return $default(_that.sessionId,_that.model,_that.input,_that.output,_that.reasoning,_that.total,_that.calls,_that.compressions,_that.cacheHitPct,_that.contextPct,_that.contextUsed,_that.contextMax);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false)  String sessionId, @LooseString()  String model, @LooseInt()  int input, @LooseInt()  int output, @LooseInt()  int reasoning, @LooseInt()  int total, @LooseInt()  int calls, @LooseInt()  int compressions, @JsonKey(name: 'cache_hit_pct')@LooseIntOrNull()  int? cacheHitPct, @JsonKey(name: 'context_percent', readValue: _contextPct)@LooseDouble()  double? contextPct, @JsonKey(name: 'context_used')@LooseIntOrNull()  int? contextUsed, @JsonKey(name: 'context_max')@LooseIntOrNull()  int? contextMax)  $default,) {final _that = this;
switch (_that) {
case _SessionUsage():
return $default(_that.sessionId,_that.model,_that.input,_that.output,_that.reasoning,_that.total,_that.calls,_that.compressions,_that.cacheHitPct,_that.contextPct,_that.contextUsed,_that.contextMax);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false)  String sessionId, @LooseString()  String model, @LooseInt()  int input, @LooseInt()  int output, @LooseInt()  int reasoning, @LooseInt()  int total, @LooseInt()  int calls, @LooseInt()  int compressions, @JsonKey(name: 'cache_hit_pct')@LooseIntOrNull()  int? cacheHitPct, @JsonKey(name: 'context_percent', readValue: _contextPct)@LooseDouble()  double? contextPct, @JsonKey(name: 'context_used')@LooseIntOrNull()  int? contextUsed, @JsonKey(name: 'context_max')@LooseIntOrNull()  int? contextMax)?  $default,) {final _that = this;
switch (_that) {
case _SessionUsage() when $default != null:
return $default(_that.sessionId,_that.model,_that.input,_that.output,_that.reasoning,_that.total,_that.calls,_that.compressions,_that.cacheHitPct,_that.contextPct,_that.contextUsed,_that.contextMax);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _SessionUsage extends SessionUsage {
  const _SessionUsage({@JsonKey(includeFromJson: false) this.sessionId = '', @LooseString() this.model = '', @LooseInt() this.input = 0, @LooseInt() this.output = 0, @LooseInt() this.reasoning = 0, @LooseInt() this.total = 0, @LooseInt() this.calls = 0, @LooseInt() this.compressions = 0, @JsonKey(name: 'cache_hit_pct')@LooseIntOrNull() this.cacheHitPct, @JsonKey(name: 'context_percent', readValue: _contextPct)@LooseDouble() this.contextPct, @JsonKey(name: 'context_used')@LooseIntOrNull() this.contextUsed, @JsonKey(name: 'context_max')@LooseIntOrNull() this.contextMax}): super._();
  factory _SessionUsage.fromJson(Map<String, dynamic> json) => _$SessionUsageFromJson(json);

@override@JsonKey(includeFromJson: false) final  String sessionId;
@override@JsonKey()@LooseString() final  String model;
@override@JsonKey()@LooseInt() final  int input;
@override@JsonKey()@LooseInt() final  int output;
@override@JsonKey()@LooseInt() final  int reasoning;
@override@JsonKey()@LooseInt() final  int total;
@override@JsonKey()@LooseInt() final  int calls;
@override@JsonKey()@LooseInt() final  int compressions;
@override@JsonKey(name: 'cache_hit_pct')@LooseIntOrNull() final  int? cacheHitPct;
/// `context_percent`, else the older `context_pct`.
@override@JsonKey(name: 'context_percent', readValue: _contextPct)@LooseDouble() final  double? contextPct;
@override@JsonKey(name: 'context_used')@LooseIntOrNull() final  int? contextUsed;
@override@JsonKey(name: 'context_max')@LooseIntOrNull() final  int? contextMax;

/// Create a copy of SessionUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionUsageCopyWith<_SessionUsage> get copyWith => __$SessionUsageCopyWithImpl<_SessionUsage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionUsage&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.model, model) || other.model == model)&&(identical(other.input, input) || other.input == input)&&(identical(other.output, output) || other.output == output)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&(identical(other.total, total) || other.total == total)&&(identical(other.calls, calls) || other.calls == calls)&&(identical(other.compressions, compressions) || other.compressions == compressions)&&(identical(other.cacheHitPct, cacheHitPct) || other.cacheHitPct == cacheHitPct)&&(identical(other.contextPct, contextPct) || other.contextPct == contextPct)&&(identical(other.contextUsed, contextUsed) || other.contextUsed == contextUsed)&&(identical(other.contextMax, contextMax) || other.contextMax == contextMax));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,model,input,output,reasoning,total,calls,compressions,cacheHitPct,contextPct,contextUsed,contextMax);
}

@override
String toString() {
    return 'SessionUsage(sessionId: $sessionId, model: $model, input: $input, output: $output, reasoning: $reasoning, total: $total, calls: $calls, compressions: $compressions, cacheHitPct: $cacheHitPct, contextPct: $contextPct, contextUsed: $contextUsed, contextMax: $contextMax)';
}


}

/// @nodoc
abstract mixin class _$SessionUsageCopyWith<$Res> implements $SessionUsageCopyWith<$Res> {
  factory _$SessionUsageCopyWith(_SessionUsage value, $Res Function(_SessionUsage) _then) = __$SessionUsageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false) String sessionId,@LooseString() String model,@LooseInt() int input,@LooseInt() int output,@LooseInt() int reasoning,@LooseInt() int total,@LooseInt() int calls,@LooseInt() int compressions,@JsonKey(name: 'cache_hit_pct')@LooseIntOrNull() int? cacheHitPct,@JsonKey(name: 'context_percent', readValue: _contextPct)@LooseDouble() double? contextPct,@JsonKey(name: 'context_used')@LooseIntOrNull() int? contextUsed,@JsonKey(name: 'context_max')@LooseIntOrNull() int? contextMax
});




}
/// @nodoc
class __$SessionUsageCopyWithImpl<$Res>
    implements _$SessionUsageCopyWith<$Res> {
  __$SessionUsageCopyWithImpl(this._self, this._then);

  final _SessionUsage _self;
  final $Res Function(_SessionUsage) _then;

/// Create a copy of SessionUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? model = null,Object? input = null,Object? output = null,Object? reasoning = null,Object? total = null,Object? calls = null,Object? compressions = null,Object? cacheHitPct = freezed,Object? contextPct = freezed,Object? contextUsed = freezed,Object? contextMax = freezed,}) {
  return _then(_SessionUsage(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as int,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as int,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,calls: null == calls ? _self.calls : calls // ignore: cast_nullable_to_non_nullable
as int,compressions: null == compressions ? _self.compressions : compressions // ignore: cast_nullable_to_non_nullable
as int,cacheHitPct: freezed == cacheHitPct ? _self.cacheHitPct : cacheHitPct // ignore: cast_nullable_to_non_nullable
as int?,contextPct: freezed == contextPct ? _self.contextPct : contextPct // ignore: cast_nullable_to_non_nullable
as double?,contextUsed: freezed == contextUsed ? _self.contextUsed : contextUsed // ignore: cast_nullable_to_non_nullable
as int?,contextMax: freezed == contextMax ? _self.contextMax : contextMax // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SessionRef {

@JsonKey(includeFromJson: false) String get runtimeId;@JsonKey(name: 'stored_session_id')@LooseString() String get storedId;@JsonKey(name: 'profile_name')@LooseString() String get profile;@LooseString() String get title;
/// Create a copy of SessionRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionRefCopyWith<SessionRef> get copyWith => _$SessionRefCopyWithImpl<SessionRef>(this as SessionRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionRef&&(identical(other.runtimeId, _this.runtimeId) || other.runtimeId == _this.runtimeId)&&(identical(other.storedId, _this.storedId) || other.storedId == _this.storedId)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.title, _this.title) || other.title == _this.title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionRef;
  return Object.hash(runtimeType,_this.runtimeId,_this.storedId,_this.profile,_this.title);
}

@override
String toString() {
  final _this = this as SessionRef;
  return 'SessionRef(runtimeId: ${_this.runtimeId}, storedId: ${_this.storedId}, profile: ${_this.profile}, title: ${_this.title})';
}


}

/// @nodoc
abstract mixin class $SessionRefCopyWith<$Res>  {
  factory $SessionRefCopyWith(SessionRef value, $Res Function(SessionRef) _then) = _$SessionRefCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false) String runtimeId,@JsonKey(name: 'stored_session_id')@LooseString() String storedId,@JsonKey(name: 'profile_name')@LooseString() String profile,@LooseString() String title
});




}
/// @nodoc
class _$SessionRefCopyWithImpl<$Res>
    implements $SessionRefCopyWith<$Res> {
  _$SessionRefCopyWithImpl(this._self, this._then);

  final SessionRef _self;
  final $Res Function(SessionRef) _then;

/// Create a copy of SessionRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? runtimeId = null,Object? storedId = null,Object? profile = null,Object? title = null,}) {
  return _then(SessionRef(
runtimeId: null == runtimeId ? _self.runtimeId : runtimeId // ignore: cast_nullable_to_non_nullable
as String,storedId: null == storedId ? _self.storedId : storedId // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionRef].
extension SessionRefPatterns on SessionRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionRef value)  $default,){
final _that = this;
switch (_that) {
case _SessionRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionRef value)?  $default,){
final _that = this;
switch (_that) {
case _SessionRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false)  String runtimeId, @JsonKey(name: 'stored_session_id')@LooseString()  String storedId, @JsonKey(name: 'profile_name')@LooseString()  String profile, @LooseString()  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionRef() when $default != null:
return $default(_that.runtimeId,_that.storedId,_that.profile,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false)  String runtimeId, @JsonKey(name: 'stored_session_id')@LooseString()  String storedId, @JsonKey(name: 'profile_name')@LooseString()  String profile, @LooseString()  String title)  $default,) {final _that = this;
switch (_that) {
case _SessionRef():
return $default(_that.runtimeId,_that.storedId,_that.profile,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false)  String runtimeId, @JsonKey(name: 'stored_session_id')@LooseString()  String storedId, @JsonKey(name: 'profile_name')@LooseString()  String profile, @LooseString()  String title)?  $default,) {final _that = this;
switch (_that) {
case _SessionRef() when $default != null:
return $default(_that.runtimeId,_that.storedId,_that.profile,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _SessionRef extends SessionRef {
  const _SessionRef({@JsonKey(includeFromJson: false) this.runtimeId = '', @JsonKey(name: 'stored_session_id')@LooseString() this.storedId = '', @JsonKey(name: 'profile_name')@LooseString() this.profile = '', @LooseString() this.title = ''}): super._();
  factory _SessionRef.fromJson(Map<String, dynamic> json) => _$SessionRefFromJson(json);

@override@JsonKey(includeFromJson: false) final  String runtimeId;
@override@JsonKey(name: 'stored_session_id')@LooseString() final  String storedId;
@override@JsonKey(name: 'profile_name')@LooseString() final  String profile;
@override@JsonKey()@LooseString() final  String title;

/// Create a copy of SessionRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionRefCopyWith<_SessionRef> get copyWith => __$SessionRefCopyWithImpl<_SessionRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionRef&&(identical(other.runtimeId, runtimeId) || other.runtimeId == runtimeId)&&(identical(other.storedId, storedId) || other.storedId == storedId)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,runtimeId,storedId,profile,title);
}

@override
String toString() {
    return 'SessionRef(runtimeId: $runtimeId, storedId: $storedId, profile: $profile, title: $title)';
}


}

/// @nodoc
abstract mixin class _$SessionRefCopyWith<$Res> implements $SessionRefCopyWith<$Res> {
  factory _$SessionRefCopyWith(_SessionRef value, $Res Function(_SessionRef) _then) = __$SessionRefCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false) String runtimeId,@JsonKey(name: 'stored_session_id')@LooseString() String storedId,@JsonKey(name: 'profile_name')@LooseString() String profile,@LooseString() String title
});




}
/// @nodoc
class __$SessionRefCopyWithImpl<$Res>
    implements _$SessionRefCopyWith<$Res> {
  __$SessionRefCopyWithImpl(this._self, this._then);

  final _SessionRef _self;
  final $Res Function(_SessionRef) _then;

/// Create a copy of SessionRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? runtimeId = null,Object? storedId = null,Object? profile = null,Object? title = null,}) {
  return _then(_SessionRef(
runtimeId: null == runtimeId ? _self.runtimeId : runtimeId // ignore: cast_nullable_to_non_nullable
as String,storedId: null == storedId ? _self.storedId : storedId // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
