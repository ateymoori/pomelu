// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionSummary {

@LooseString() String get id;@LooseString() String get title;@LooseString() String get preview;@LooseString() String get profile;@LooseString() String get model;@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? get lastActive;@JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds) DateTime? get startedAt;@JsonKey(name: 'message_count')@LooseInt() int get messageCount;@JsonKey(name: 'parent_session_id')@LooseStringOrNull() String? get parentSessionId;@JsonKey(name: 'resolved_id')@LooseStringOrNull() String? get resolvedId;/// Why the session ended (`compression` for a compaction rotation);
/// only on a single-session read.
@JsonKey(name: 'end_reason')@LooseStringOrNull() String? get endReason;@LooseBool() bool get hidden;@JsonKey(name: 'is_active')@LooseBool() bool get isActive;
/// Create a copy of SessionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSummaryCopyWith<SessionSummary> get copyWith => _$SessionSummaryCopyWithImpl<SessionSummary>(this as SessionSummary, _$identity);

  /// Serializes this SessionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.preview, _this.preview) || other.preview == _this.preview)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.lastActive, _this.lastActive) || other.lastActive == _this.lastActive)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.messageCount, _this.messageCount) || other.messageCount == _this.messageCount)&&(identical(other.parentSessionId, _this.parentSessionId) || other.parentSessionId == _this.parentSessionId)&&(identical(other.resolvedId, _this.resolvedId) || other.resolvedId == _this.resolvedId)&&(identical(other.endReason, _this.endReason) || other.endReason == _this.endReason)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionSummary;
  return Object.hash(runtimeType,_this.id,_this.title,_this.preview,_this.profile,_this.model,_this.lastActive,_this.startedAt,_this.messageCount,_this.parentSessionId,_this.resolvedId,_this.endReason,_this.hidden,_this.isActive);
}

@override
String toString() {
  final _this = this as SessionSummary;
  return 'SessionSummary(id: ${_this.id}, title: ${_this.title}, preview: ${_this.preview}, profile: ${_this.profile}, model: ${_this.model}, lastActive: ${_this.lastActive}, startedAt: ${_this.startedAt}, messageCount: ${_this.messageCount}, parentSessionId: ${_this.parentSessionId}, resolvedId: ${_this.resolvedId}, endReason: ${_this.endReason}, hidden: ${_this.hidden}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $SessionSummaryCopyWith<$Res>  {
  factory $SessionSummaryCopyWith(SessionSummary value, $Res Function(SessionSummary) _then) = _$SessionSummaryCopyWithImpl;
@useResult
$Res call({
@LooseString() String id,@LooseString() String title,@LooseString() String preview,@LooseString() String profile,@LooseString() String model,@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? lastActive,@JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds) DateTime? startedAt,@JsonKey(name: 'message_count')@LooseInt() int messageCount,@JsonKey(name: 'parent_session_id')@LooseStringOrNull() String? parentSessionId,@JsonKey(name: 'resolved_id')@LooseStringOrNull() String? resolvedId,@JsonKey(name: 'end_reason')@LooseStringOrNull() String? endReason,@LooseBool() bool hidden,@JsonKey(name: 'is_active')@LooseBool() bool isActive
});




}
/// @nodoc
class _$SessionSummaryCopyWithImpl<$Res>
    implements $SessionSummaryCopyWith<$Res> {
  _$SessionSummaryCopyWithImpl(this._self, this._then);

  final SessionSummary _self;
  final $Res Function(SessionSummary) _then;

/// Create a copy of SessionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? profile = null,Object? model = null,Object? lastActive = freezed,Object? startedAt = freezed,Object? messageCount = null,Object? parentSessionId = freezed,Object? resolvedId = freezed,Object? endReason = freezed,Object? hidden = null,Object? isActive = null,}) {
  return _then(SessionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,parentSessionId: freezed == parentSessionId ? _self.parentSessionId : parentSessionId // ignore: cast_nullable_to_non_nullable
as String?,resolvedId: freezed == resolvedId ? _self.resolvedId : resolvedId // ignore: cast_nullable_to_non_nullable
as String?,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as String?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionSummary].
extension SessionSummaryPatterns on SessionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSummary value)  $default,){
final _that = this;
switch (_that) {
case _SessionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String title, @LooseString()  String preview, @LooseString()  String profile, @LooseString()  String model, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds)  DateTime? startedAt, @JsonKey(name: 'message_count')@LooseInt()  int messageCount, @JsonKey(name: 'parent_session_id')@LooseStringOrNull()  String? parentSessionId, @JsonKey(name: 'resolved_id')@LooseStringOrNull()  String? resolvedId, @JsonKey(name: 'end_reason')@LooseStringOrNull()  String? endReason, @LooseBool()  bool hidden, @JsonKey(name: 'is_active')@LooseBool()  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSummary() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.profile,_that.model,_that.lastActive,_that.startedAt,_that.messageCount,_that.parentSessionId,_that.resolvedId,_that.endReason,_that.hidden,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String title, @LooseString()  String preview, @LooseString()  String profile, @LooseString()  String model, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds)  DateTime? startedAt, @JsonKey(name: 'message_count')@LooseInt()  int messageCount, @JsonKey(name: 'parent_session_id')@LooseStringOrNull()  String? parentSessionId, @JsonKey(name: 'resolved_id')@LooseStringOrNull()  String? resolvedId, @JsonKey(name: 'end_reason')@LooseStringOrNull()  String? endReason, @LooseBool()  bool hidden, @JsonKey(name: 'is_active')@LooseBool()  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _SessionSummary():
return $default(_that.id,_that.title,_that.preview,_that.profile,_that.model,_that.lastActive,_that.startedAt,_that.messageCount,_that.parentSessionId,_that.resolvedId,_that.endReason,_that.hidden,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String id, @LooseString()  String title, @LooseString()  String preview, @LooseString()  String profile, @LooseString()  String model, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds)  DateTime? startedAt, @JsonKey(name: 'message_count')@LooseInt()  int messageCount, @JsonKey(name: 'parent_session_id')@LooseStringOrNull()  String? parentSessionId, @JsonKey(name: 'resolved_id')@LooseStringOrNull()  String? resolvedId, @JsonKey(name: 'end_reason')@LooseStringOrNull()  String? endReason, @LooseBool()  bool hidden, @JsonKey(name: 'is_active')@LooseBool()  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _SessionSummary() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.profile,_that.model,_that.lastActive,_that.startedAt,_that.messageCount,_that.parentSessionId,_that.resolvedId,_that.endReason,_that.hidden,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionSummary extends SessionSummary {
  const _SessionSummary({@LooseString() this.id = '', @LooseString() this.title = '', @LooseString() this.preview = '', @LooseString() this.profile = '', @LooseString() this.model = '', @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) this.lastActive, @JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds) this.startedAt, @JsonKey(name: 'message_count')@LooseInt() this.messageCount = 0, @JsonKey(name: 'parent_session_id')@LooseStringOrNull() this.parentSessionId, @JsonKey(name: 'resolved_id')@LooseStringOrNull() this.resolvedId, @JsonKey(name: 'end_reason')@LooseStringOrNull() this.endReason, @LooseBool() this.hidden = false, @JsonKey(name: 'is_active')@LooseBool() this.isActive = false}): super._();
  factory _SessionSummary.fromJson(Map<String, dynamic> json) => _$SessionSummaryFromJson(json);

@override@JsonKey()@LooseString() final  String id;
@override@JsonKey()@LooseString() final  String title;
@override@JsonKey()@LooseString() final  String preview;
@override@JsonKey()@LooseString() final  String profile;
@override@JsonKey()@LooseString() final  String model;
@override@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) final  DateTime? lastActive;
@override@JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds) final  DateTime? startedAt;
@override@JsonKey(name: 'message_count')@LooseInt() final  int messageCount;
@override@JsonKey(name: 'parent_session_id')@LooseStringOrNull() final  String? parentSessionId;
@override@JsonKey(name: 'resolved_id')@LooseStringOrNull() final  String? resolvedId;
/// Why the session ended (`compression` for a compaction rotation);
/// only on a single-session read.
@override@JsonKey(name: 'end_reason')@LooseStringOrNull() final  String? endReason;
@override@JsonKey()@LooseBool() final  bool hidden;
@override@JsonKey(name: 'is_active')@LooseBool() final  bool isActive;

/// Create a copy of SessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSummaryCopyWith<_SessionSummary> get copyWith => __$SessionSummaryCopyWithImpl<_SessionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.model, model) || other.model == model)&&(identical(other.lastActive, lastActive) || other.lastActive == lastActive)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.parentSessionId, parentSessionId) || other.parentSessionId == parentSessionId)&&(identical(other.resolvedId, resolvedId) || other.resolvedId == resolvedId)&&(identical(other.endReason, endReason) || other.endReason == endReason)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,preview,profile,model,lastActive,startedAt,messageCount,parentSessionId,resolvedId,endReason,hidden,isActive);
}

@override
String toString() {
    return 'SessionSummary(id: $id, title: $title, preview: $preview, profile: $profile, model: $model, lastActive: $lastActive, startedAt: $startedAt, messageCount: $messageCount, parentSessionId: $parentSessionId, resolvedId: $resolvedId, endReason: $endReason, hidden: $hidden, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$SessionSummaryCopyWith<$Res> implements $SessionSummaryCopyWith<$Res> {
  factory _$SessionSummaryCopyWith(_SessionSummary value, $Res Function(_SessionSummary) _then) = __$SessionSummaryCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String id,@LooseString() String title,@LooseString() String preview,@LooseString() String profile,@LooseString() String model,@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? lastActive,@JsonKey(name: 'started_at', fromJson: dateTimeFromEpochSeconds) DateTime? startedAt,@JsonKey(name: 'message_count')@LooseInt() int messageCount,@JsonKey(name: 'parent_session_id')@LooseStringOrNull() String? parentSessionId,@JsonKey(name: 'resolved_id')@LooseStringOrNull() String? resolvedId,@JsonKey(name: 'end_reason')@LooseStringOrNull() String? endReason,@LooseBool() bool hidden,@JsonKey(name: 'is_active')@LooseBool() bool isActive
});




}
/// @nodoc
class __$SessionSummaryCopyWithImpl<$Res>
    implements _$SessionSummaryCopyWith<$Res> {
  __$SessionSummaryCopyWithImpl(this._self, this._then);

  final _SessionSummary _self;
  final $Res Function(_SessionSummary) _then;

/// Create a copy of SessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? profile = null,Object? model = null,Object? lastActive = freezed,Object? startedAt = freezed,Object? messageCount = null,Object? parentSessionId = freezed,Object? resolvedId = freezed,Object? endReason = freezed,Object? hidden = null,Object? isActive = null,}) {
  return _then(_SessionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,parentSessionId: freezed == parentSessionId ? _self.parentSessionId : parentSessionId // ignore: cast_nullable_to_non_nullable
as String?,resolvedId: freezed == resolvedId ? _self.resolvedId : resolvedId // ignore: cast_nullable_to_non_nullable
as String?,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as String?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
