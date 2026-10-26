// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cron_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CronSchedule {

@LooseString() String get kind;@LooseString() String get expr;@LooseInt() int get minutes;@JsonKey(name: 'run_at')@LooseDateTime() DateTime? get runAt;@LooseString() String get display;
/// Create a copy of CronSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CronScheduleCopyWith<CronSchedule> get copyWith => _$CronScheduleCopyWithImpl<CronSchedule>(this as CronSchedule, _$identity);

  /// Serializes this CronSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CronSchedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CronSchedule&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.expr, _this.expr) || other.expr == _this.expr)&&(identical(other.minutes, _this.minutes) || other.minutes == _this.minutes)&&(identical(other.runAt, _this.runAt) || other.runAt == _this.runAt)&&(identical(other.display, _this.display) || other.display == _this.display));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CronSchedule;
  return Object.hash(runtimeType,_this.kind,_this.expr,_this.minutes,_this.runAt,_this.display);
}

@override
String toString() {
  final _this = this as CronSchedule;
  return 'CronSchedule(kind: ${_this.kind}, expr: ${_this.expr}, minutes: ${_this.minutes}, runAt: ${_this.runAt}, display: ${_this.display})';
}


}

/// @nodoc
abstract mixin class $CronScheduleCopyWith<$Res>  {
  factory $CronScheduleCopyWith(CronSchedule value, $Res Function(CronSchedule) _then) = _$CronScheduleCopyWithImpl;
@useResult
$Res call({
@LooseString() String kind,@LooseString() String expr,@LooseInt() int minutes,@JsonKey(name: 'run_at')@LooseDateTime() DateTime? runAt,@LooseString() String display
});




}
/// @nodoc
class _$CronScheduleCopyWithImpl<$Res>
    implements $CronScheduleCopyWith<$Res> {
  _$CronScheduleCopyWithImpl(this._self, this._then);

  final CronSchedule _self;
  final $Res Function(CronSchedule) _then;

/// Create a copy of CronSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? expr = null,Object? minutes = null,Object? runAt = freezed,Object? display = null,}) {
  return _then(CronSchedule(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,expr: null == expr ? _self.expr : expr // ignore: cast_nullable_to_non_nullable
as String,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,runAt: freezed == runAt ? _self.runAt : runAt // ignore: cast_nullable_to_non_nullable
as DateTime?,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CronSchedule].
extension CronSchedulePatterns on CronSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CronSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CronSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CronSchedule value)  $default,){
final _that = this;
switch (_that) {
case _CronSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CronSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _CronSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String kind, @LooseString()  String expr, @LooseInt()  int minutes, @JsonKey(name: 'run_at')@LooseDateTime()  DateTime? runAt, @LooseString()  String display)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CronSchedule() when $default != null:
return $default(_that.kind,_that.expr,_that.minutes,_that.runAt,_that.display);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String kind, @LooseString()  String expr, @LooseInt()  int minutes, @JsonKey(name: 'run_at')@LooseDateTime()  DateTime? runAt, @LooseString()  String display)  $default,) {final _that = this;
switch (_that) {
case _CronSchedule():
return $default(_that.kind,_that.expr,_that.minutes,_that.runAt,_that.display);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String kind, @LooseString()  String expr, @LooseInt()  int minutes, @JsonKey(name: 'run_at')@LooseDateTime()  DateTime? runAt, @LooseString()  String display)?  $default,) {final _that = this;
switch (_that) {
case _CronSchedule() when $default != null:
return $default(_that.kind,_that.expr,_that.minutes,_that.runAt,_that.display);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CronSchedule implements CronSchedule {
  const _CronSchedule({@LooseString() this.kind = '', @LooseString() this.expr = '', @LooseInt() this.minutes = 0, @JsonKey(name: 'run_at')@LooseDateTime() this.runAt, @LooseString() this.display = ''});
  factory _CronSchedule.fromJson(Map<String, dynamic> json) => _$CronScheduleFromJson(json);

@override@JsonKey()@LooseString() final  String kind;
@override@JsonKey()@LooseString() final  String expr;
@override@JsonKey()@LooseInt() final  int minutes;
@override@JsonKey(name: 'run_at')@LooseDateTime() final  DateTime? runAt;
@override@JsonKey()@LooseString() final  String display;

/// Create a copy of CronSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CronScheduleCopyWith<_CronSchedule> get copyWith => __$CronScheduleCopyWithImpl<_CronSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CronScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CronSchedule&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.expr, expr) || other.expr == expr)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.runAt, runAt) || other.runAt == runAt)&&(identical(other.display, display) || other.display == display));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,expr,minutes,runAt,display);
}

@override
String toString() {
    return 'CronSchedule(kind: $kind, expr: $expr, minutes: $minutes, runAt: $runAt, display: $display)';
}


}

/// @nodoc
abstract mixin class _$CronScheduleCopyWith<$Res> implements $CronScheduleCopyWith<$Res> {
  factory _$CronScheduleCopyWith(_CronSchedule value, $Res Function(_CronSchedule) _then) = __$CronScheduleCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String kind,@LooseString() String expr,@LooseInt() int minutes,@JsonKey(name: 'run_at')@LooseDateTime() DateTime? runAt,@LooseString() String display
});




}
/// @nodoc
class __$CronScheduleCopyWithImpl<$Res>
    implements _$CronScheduleCopyWith<$Res> {
  __$CronScheduleCopyWithImpl(this._self, this._then);

  final _CronSchedule _self;
  final $Res Function(_CronSchedule) _then;

/// Create a copy of CronSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? expr = null,Object? minutes = null,Object? runAt = freezed,Object? display = null,}) {
  return _then(_CronSchedule(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,expr: null == expr ? _self.expr : expr // ignore: cast_nullable_to_non_nullable
as String,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,runAt: freezed == runAt ? _self.runAt : runAt // ignore: cast_nullable_to_non_nullable
as DateTime?,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
