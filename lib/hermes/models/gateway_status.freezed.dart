// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gateway_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GatewayStatus {

@LooseString() String get version;@JsonKey(name: 'auth_required')@LooseBool() bool get authRequired;@JsonKey(name: 'auth_providers')@LooseStringList() List<String>? get authProviders;
/// Create a copy of GatewayStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GatewayStatusCopyWith<GatewayStatus> get copyWith => _$GatewayStatusCopyWithImpl<GatewayStatus>(this as GatewayStatus, _$identity);

  /// Serializes this GatewayStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GatewayStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GatewayStatus&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.authRequired, _this.authRequired) || other.authRequired == _this.authRequired)&&const DeepCollectionEquality().equals(other.authProviders, _this.authProviders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GatewayStatus;
  return Object.hash(runtimeType,_this.version,_this.authRequired,const DeepCollectionEquality().hash(_this.authProviders));
}

@override
String toString() {
  final _this = this as GatewayStatus;
  return 'GatewayStatus(version: ${_this.version}, authRequired: ${_this.authRequired}, authProviders: ${_this.authProviders})';
}


}

/// @nodoc
abstract mixin class $GatewayStatusCopyWith<$Res>  {
  factory $GatewayStatusCopyWith(GatewayStatus value, $Res Function(GatewayStatus) _then) = _$GatewayStatusCopyWithImpl;
@useResult
$Res call({
@LooseString() String version,@JsonKey(name: 'auth_required')@LooseBool() bool authRequired,@JsonKey(name: 'auth_providers')@LooseStringList() List<String>? authProviders
});




}
/// @nodoc
class _$GatewayStatusCopyWithImpl<$Res>
    implements $GatewayStatusCopyWith<$Res> {
  _$GatewayStatusCopyWithImpl(this._self, this._then);

  final GatewayStatus _self;
  final $Res Function(GatewayStatus) _then;

/// Create a copy of GatewayStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? authRequired = null,Object? authProviders = freezed,}) {
  return _then(GatewayStatus(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,authRequired: null == authRequired ? _self.authRequired : authRequired // ignore: cast_nullable_to_non_nullable
as bool,authProviders: freezed == authProviders ? _self.authProviders : authProviders // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GatewayStatus].
extension GatewayStatusPatterns on GatewayStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GatewayStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GatewayStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GatewayStatus value)  $default,){
final _that = this;
switch (_that) {
case _GatewayStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GatewayStatus value)?  $default,){
final _that = this;
switch (_that) {
case _GatewayStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String version, @JsonKey(name: 'auth_required')@LooseBool()  bool authRequired, @JsonKey(name: 'auth_providers')@LooseStringList()  List<String>? authProviders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GatewayStatus() when $default != null:
return $default(_that.version,_that.authRequired,_that.authProviders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String version, @JsonKey(name: 'auth_required')@LooseBool()  bool authRequired, @JsonKey(name: 'auth_providers')@LooseStringList()  List<String>? authProviders)  $default,) {final _that = this;
switch (_that) {
case _GatewayStatus():
return $default(_that.version,_that.authRequired,_that.authProviders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String version, @JsonKey(name: 'auth_required')@LooseBool()  bool authRequired, @JsonKey(name: 'auth_providers')@LooseStringList()  List<String>? authProviders)?  $default,) {final _that = this;
switch (_that) {
case _GatewayStatus() when $default != null:
return $default(_that.version,_that.authRequired,_that.authProviders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GatewayStatus implements GatewayStatus {
  const _GatewayStatus({@LooseString() this.version = '', @JsonKey(name: 'auth_required')@LooseBool() this.authRequired = false, @JsonKey(name: 'auth_providers')@LooseStringList()  List<String>? authProviders}): _authProviders = authProviders;
  factory _GatewayStatus.fromJson(Map<String, dynamic> json) => _$GatewayStatusFromJson(json);

@override@JsonKey()@LooseString() final  String version;
@override@JsonKey(name: 'auth_required')@LooseBool() final  bool authRequired;
 final  List<String>? _authProviders;
@override@JsonKey(name: 'auth_providers')@LooseStringList() List<String>? get authProviders {
  final value = _authProviders;
  if (value == null) return null;
  if (_authProviders is EqualUnmodifiableListView) return _authProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of GatewayStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GatewayStatusCopyWith<_GatewayStatus> get copyWith => __$GatewayStatusCopyWithImpl<_GatewayStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GatewayStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GatewayStatus&&(identical(other.version, version) || other.version == version)&&(identical(other.authRequired, authRequired) || other.authRequired == authRequired)&&const DeepCollectionEquality().equals(other.authProviders, _authProviders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,authRequired,const DeepCollectionEquality().hash(_authProviders));
}

@override
String toString() {
    return 'GatewayStatus(version: $version, authRequired: $authRequired, authProviders: $authProviders)';
}


}

/// @nodoc
abstract mixin class _$GatewayStatusCopyWith<$Res> implements $GatewayStatusCopyWith<$Res> {
  factory _$GatewayStatusCopyWith(_GatewayStatus value, $Res Function(_GatewayStatus) _then) = __$GatewayStatusCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String version,@JsonKey(name: 'auth_required')@LooseBool() bool authRequired,@JsonKey(name: 'auth_providers')@LooseStringList() List<String>? authProviders
});




}
/// @nodoc
class __$GatewayStatusCopyWithImpl<$Res>
    implements _$GatewayStatusCopyWith<$Res> {
  __$GatewayStatusCopyWithImpl(this._self, this._then);

  final _GatewayStatus _self;
  final $Res Function(_GatewayStatus) _then;

/// Create a copy of GatewayStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? authRequired = null,Object? authProviders = freezed,}) {
  return _then(_GatewayStatus(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,authRequired: null == authRequired ? _self.authRequired : authRequired // ignore: cast_nullable_to_non_nullable
as bool,authProviders: freezed == authProviders ? _self._authProviders : authProviders // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
