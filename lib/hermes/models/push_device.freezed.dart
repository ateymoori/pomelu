// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PushDevice {

 String get platform; String get token; String get key;/// APNs development: a debug build.
 bool get sandbox;
/// Create a copy of PushDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushDeviceCopyWith<PushDevice> get copyWith => _$PushDeviceCopyWithImpl<PushDevice>(this as PushDevice, _$identity);

  /// Serializes this PushDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PushDevice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushDevice&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.sandbox, _this.sandbox) || other.sandbox == _this.sandbox));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PushDevice;
  return Object.hash(runtimeType,_this.platform,_this.token,_this.key,_this.sandbox);
}

@override
String toString() {
  final _this = this as PushDevice;
  return 'PushDevice(platform: ${_this.platform}, token: ${_this.token}, key: ${_this.key}, sandbox: ${_this.sandbox})';
}


}

/// @nodoc
abstract mixin class $PushDeviceCopyWith<$Res>  {
  factory $PushDeviceCopyWith(PushDevice value, $Res Function(PushDevice) _then) = _$PushDeviceCopyWithImpl;
@useResult
$Res call({
 String platform, String token, String key, bool sandbox
});




}
/// @nodoc
class _$PushDeviceCopyWithImpl<$Res>
    implements $PushDeviceCopyWith<$Res> {
  _$PushDeviceCopyWithImpl(this._self, this._then);

  final PushDevice _self;
  final $Res Function(PushDevice) _then;

/// Create a copy of PushDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? token = null,Object? key = null,Object? sandbox = null,}) {
  return _then(PushDevice(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,sandbox: null == sandbox ? _self.sandbox : sandbox // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PushDevice].
extension PushDevicePatterns on PushDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushDevice value)  $default,){
final _that = this;
switch (_that) {
case _PushDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushDevice value)?  $default,){
final _that = this;
switch (_that) {
case _PushDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String platform,  String token,  String key,  bool sandbox)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushDevice() when $default != null:
return $default(_that.platform,_that.token,_that.key,_that.sandbox);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String platform,  String token,  String key,  bool sandbox)  $default,) {final _that = this;
switch (_that) {
case _PushDevice():
return $default(_that.platform,_that.token,_that.key,_that.sandbox);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String platform,  String token,  String key,  bool sandbox)?  $default,) {final _that = this;
switch (_that) {
case _PushDevice() when $default != null:
return $default(_that.platform,_that.token,_that.key,_that.sandbox);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PushDevice implements PushDevice {
  const _PushDevice({required this.platform, required this.token, required this.key, this.sandbox = false});
  factory _PushDevice.fromJson(Map<String, dynamic> json) => _$PushDeviceFromJson(json);

@override final  String platform;
@override final  String token;
@override final  String key;
/// APNs development: a debug build.
@override@JsonKey() final  bool sandbox;

/// Create a copy of PushDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushDeviceCopyWith<_PushDevice> get copyWith => __$PushDeviceCopyWithImpl<_PushDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PushDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushDevice&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.token, token) || other.token == token)&&(identical(other.key, key) || other.key == key)&&(identical(other.sandbox, sandbox) || other.sandbox == sandbox));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,platform,token,key,sandbox);
}

@override
String toString() {
    return 'PushDevice(platform: $platform, token: $token, key: $key, sandbox: $sandbox)';
}


}

/// @nodoc
abstract mixin class _$PushDeviceCopyWith<$Res> implements $PushDeviceCopyWith<$Res> {
  factory _$PushDeviceCopyWith(_PushDevice value, $Res Function(_PushDevice) _then) = __$PushDeviceCopyWithImpl;
@override @useResult
$Res call({
 String platform, String token, String key, bool sandbox
});




}
/// @nodoc
class __$PushDeviceCopyWithImpl<$Res>
    implements _$PushDeviceCopyWith<$Res> {
  __$PushDeviceCopyWithImpl(this._self, this._then);

  final _PushDevice _self;
  final $Res Function(_PushDevice) _then;

/// Create a copy of PushDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? token = null,Object? key = null,Object? sandbox = null,}) {
  return _then(_PushDevice(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,sandbox: null == sandbox ? _self.sandbox : sandbox // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
