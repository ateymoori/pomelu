// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BotGroup {

 HermesProfile get profile; bool get working;
/// Create a copy of BotGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotGroupCopyWith<BotGroup> get copyWith => _$BotGroupCopyWithImpl<BotGroup>(this as BotGroup, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BotGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotGroup&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.working, _this.working) || other.working == _this.working));
}


@override
int get hashCode {
  final _this = this as BotGroup;
  return Object.hash(runtimeType,_this.profile,_this.working);
}

@override
String toString() {
  final _this = this as BotGroup;
  return 'BotGroup(profile: ${_this.profile}, working: ${_this.working})';
}


}

/// @nodoc
abstract mixin class $BotGroupCopyWith<$Res>  {
  factory $BotGroupCopyWith(BotGroup value, $Res Function(BotGroup) _then) = _$BotGroupCopyWithImpl;
@useResult
$Res call({
 HermesProfile profile, bool working
});


$HermesProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$BotGroupCopyWithImpl<$Res>
    implements $BotGroupCopyWith<$Res> {
  _$BotGroupCopyWithImpl(this._self, this._then);

  final BotGroup _self;
  final $Res Function(BotGroup) _then;

/// Create a copy of BotGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,Object? working = null,}) {
  return _then(BotGroup(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as HermesProfile,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of BotGroup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HermesProfileCopyWith<$Res> get profile {
  
  return $HermesProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [BotGroup].
extension BotGroupPatterns on BotGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotGroup value)  $default,){
final _that = this;
switch (_that) {
case _BotGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotGroup value)?  $default,){
final _that = this;
switch (_that) {
case _BotGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HermesProfile profile,  bool working)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotGroup() when $default != null:
return $default(_that.profile,_that.working);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HermesProfile profile,  bool working)  $default,) {final _that = this;
switch (_that) {
case _BotGroup():
return $default(_that.profile,_that.working);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HermesProfile profile,  bool working)?  $default,) {final _that = this;
switch (_that) {
case _BotGroup() when $default != null:
return $default(_that.profile,_that.working);case _:
  return null;

}
}

}

/// @nodoc


class _BotGroup extends BotGroup {
  const _BotGroup({required this.profile, this.working = false}): super._();
  

@override final  HermesProfile profile;
@override@JsonKey() final  bool working;

/// Create a copy of BotGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotGroupCopyWith<_BotGroup> get copyWith => __$BotGroupCopyWithImpl<_BotGroup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotGroup&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.working, working) || other.working == working));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profile,working);
}

@override
String toString() {
    return 'BotGroup(profile: $profile, working: $working)';
}


}

/// @nodoc
abstract mixin class _$BotGroupCopyWith<$Res> implements $BotGroupCopyWith<$Res> {
  factory _$BotGroupCopyWith(_BotGroup value, $Res Function(_BotGroup) _then) = __$BotGroupCopyWithImpl;
@override @useResult
$Res call({
 HermesProfile profile, bool working
});


@override $HermesProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$BotGroupCopyWithImpl<$Res>
    implements _$BotGroupCopyWith<$Res> {
  __$BotGroupCopyWithImpl(this._self, this._then);

  final _BotGroup _self;
  final $Res Function(_BotGroup) _then;

/// Create a copy of BotGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? working = null,}) {
  return _then(_BotGroup(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as HermesProfile,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of BotGroup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HermesProfileCopyWith<$Res> get profile {
  
  return $HermesProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
