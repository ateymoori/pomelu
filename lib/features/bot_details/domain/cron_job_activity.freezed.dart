// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cron_job_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CronJobActivity {

 CronAction? get doing; HermesFailure? get failure;
/// Create a copy of CronJobActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CronJobActivityCopyWith<CronJobActivity> get copyWith => _$CronJobActivityCopyWithImpl<CronJobActivity>(this as CronJobActivity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CronJobActivity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CronJobActivity&&(identical(other.doing, _this.doing) || other.doing == _this.doing)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as CronJobActivity;
  return Object.hash(runtimeType,_this.doing,_this.failure);
}

@override
String toString() {
  final _this = this as CronJobActivity;
  return 'CronJobActivity(doing: ${_this.doing}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $CronJobActivityCopyWith<$Res>  {
  factory $CronJobActivityCopyWith(CronJobActivity value, $Res Function(CronJobActivity) _then) = _$CronJobActivityCopyWithImpl;
@useResult
$Res call({
 CronAction? doing, HermesFailure? failure
});




}
/// @nodoc
class _$CronJobActivityCopyWithImpl<$Res>
    implements $CronJobActivityCopyWith<$Res> {
  _$CronJobActivityCopyWithImpl(this._self, this._then);

  final CronJobActivity _self;
  final $Res Function(CronJobActivity) _then;

/// Create a copy of CronJobActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? doing = freezed,Object? failure = freezed,}) {
  return _then(CronJobActivity(
doing: freezed == doing ? _self.doing : doing // ignore: cast_nullable_to_non_nullable
as CronAction?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HermesFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [CronJobActivity].
extension CronJobActivityPatterns on CronJobActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CronJobActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CronJobActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CronJobActivity value)  $default,){
final _that = this;
switch (_that) {
case _CronJobActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CronJobActivity value)?  $default,){
final _that = this;
switch (_that) {
case _CronJobActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CronAction? doing,  HermesFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CronJobActivity() when $default != null:
return $default(_that.doing,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CronAction? doing,  HermesFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _CronJobActivity():
return $default(_that.doing,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CronAction? doing,  HermesFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _CronJobActivity() when $default != null:
return $default(_that.doing,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _CronJobActivity extends CronJobActivity {
  const _CronJobActivity({this.doing, this.failure}): super._();
  

@override final  CronAction? doing;
@override final  HermesFailure? failure;

/// Create a copy of CronJobActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CronJobActivityCopyWith<_CronJobActivity> get copyWith => __$CronJobActivityCopyWithImpl<_CronJobActivity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CronJobActivity&&(identical(other.doing, doing) || other.doing == doing)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,doing,failure);
}

@override
String toString() {
    return 'CronJobActivity(doing: $doing, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$CronJobActivityCopyWith<$Res> implements $CronJobActivityCopyWith<$Res> {
  factory _$CronJobActivityCopyWith(_CronJobActivity value, $Res Function(_CronJobActivity) _then) = __$CronJobActivityCopyWithImpl;
@override @useResult
$Res call({
 CronAction? doing, HermesFailure? failure
});




}
/// @nodoc
class __$CronJobActivityCopyWithImpl<$Res>
    implements _$CronJobActivityCopyWith<$Res> {
  __$CronJobActivityCopyWithImpl(this._self, this._then);

  final _CronJobActivity _self;
  final $Res Function(_CronJobActivity) _then;

/// Create a copy of CronJobActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? doing = freezed,Object? failure = freezed,}) {
  return _then(_CronJobActivity(
doing: freezed == doing ? _self.doing : doing // ignore: cast_nullable_to_non_nullable
as CronAction?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HermesFailure?,
  ));
}


}

// dart format on
