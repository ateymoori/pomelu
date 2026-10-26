// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hermes_auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthProvider {

@LooseString() String get name;@JsonKey(name: 'display_name')@LooseString() String get displayName;@JsonKey(name: 'supports_password')@LooseBool() bool get supportsPassword;
/// Create a copy of AuthProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthProviderCopyWith<AuthProvider> get copyWith => _$AuthProviderCopyWithImpl<AuthProvider>(this as AuthProvider, _$identity);

  /// Serializes this AuthProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthProvider;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthProvider&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.supportsPassword, _this.supportsPassword) || other.supportsPassword == _this.supportsPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthProvider;
  return Object.hash(runtimeType,_this.name,_this.displayName,_this.supportsPassword);
}

@override
String toString() {
  final _this = this as AuthProvider;
  return 'AuthProvider(name: ${_this.name}, displayName: ${_this.displayName}, supportsPassword: ${_this.supportsPassword})';
}


}

/// @nodoc
abstract mixin class $AuthProviderCopyWith<$Res>  {
  factory $AuthProviderCopyWith(AuthProvider value, $Res Function(AuthProvider) _then) = _$AuthProviderCopyWithImpl;
@useResult
$Res call({
@LooseString() String name,@JsonKey(name: 'display_name')@LooseString() String displayName,@JsonKey(name: 'supports_password')@LooseBool() bool supportsPassword
});




}
/// @nodoc
class _$AuthProviderCopyWithImpl<$Res>
    implements $AuthProviderCopyWith<$Res> {
  _$AuthProviderCopyWithImpl(this._self, this._then);

  final AuthProvider _self;
  final $Res Function(AuthProvider) _then;

/// Create a copy of AuthProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? displayName = null,Object? supportsPassword = null,}) {
  return _then(AuthProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,supportsPassword: null == supportsPassword ? _self.supportsPassword : supportsPassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthProvider].
extension AuthProviderPatterns on AuthProvider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthProvider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthProvider value)  $default,){
final _that = this;
switch (_that) {
case _AuthProvider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthProvider value)?  $default,){
final _that = this;
switch (_that) {
case _AuthProvider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String name, @JsonKey(name: 'display_name')@LooseString()  String displayName, @JsonKey(name: 'supports_password')@LooseBool()  bool supportsPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthProvider() when $default != null:
return $default(_that.name,_that.displayName,_that.supportsPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String name, @JsonKey(name: 'display_name')@LooseString()  String displayName, @JsonKey(name: 'supports_password')@LooseBool()  bool supportsPassword)  $default,) {final _that = this;
switch (_that) {
case _AuthProvider():
return $default(_that.name,_that.displayName,_that.supportsPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String name, @JsonKey(name: 'display_name')@LooseString()  String displayName, @JsonKey(name: 'supports_password')@LooseBool()  bool supportsPassword)?  $default,) {final _that = this;
switch (_that) {
case _AuthProvider() when $default != null:
return $default(_that.name,_that.displayName,_that.supportsPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthProvider implements AuthProvider {
  const _AuthProvider({@LooseString() this.name = '', @JsonKey(name: 'display_name')@LooseString() this.displayName = '', @JsonKey(name: 'supports_password')@LooseBool() this.supportsPassword = false});
  factory _AuthProvider.fromJson(Map<String, dynamic> json) => _$AuthProviderFromJson(json);

@override@JsonKey()@LooseString() final  String name;
@override@JsonKey(name: 'display_name')@LooseString() final  String displayName;
@override@JsonKey(name: 'supports_password')@LooseBool() final  bool supportsPassword;

/// Create a copy of AuthProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthProviderCopyWith<_AuthProvider> get copyWith => __$AuthProviderCopyWithImpl<_AuthProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthProviderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthProvider&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.supportsPassword, supportsPassword) || other.supportsPassword == supportsPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,displayName,supportsPassword);
}

@override
String toString() {
    return 'AuthProvider(name: $name, displayName: $displayName, supportsPassword: $supportsPassword)';
}


}

/// @nodoc
abstract mixin class _$AuthProviderCopyWith<$Res> implements $AuthProviderCopyWith<$Res> {
  factory _$AuthProviderCopyWith(_AuthProvider value, $Res Function(_AuthProvider) _then) = __$AuthProviderCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String name,@JsonKey(name: 'display_name')@LooseString() String displayName,@JsonKey(name: 'supports_password')@LooseBool() bool supportsPassword
});




}
/// @nodoc
class __$AuthProviderCopyWithImpl<$Res>
    implements _$AuthProviderCopyWith<$Res> {
  __$AuthProviderCopyWithImpl(this._self, this._then);

  final _AuthProvider _self;
  final $Res Function(_AuthProvider) _then;

/// Create a copy of AuthProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? displayName = null,Object? supportsPassword = null,}) {
  return _then(_AuthProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,supportsPassword: null == supportsPassword ? _self.supportsPassword : supportsPassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TokenRefresh {

@JsonKey(name: 'access_token')@LooseString() String get accessToken;@JsonKey(name: 'refresh_token')@LooseStringOrNull() String? get refreshToken;@LooseStringOrNull() String? get provider;@JsonKey(name: 'expires_at')@LooseDateTime() DateTime? get expiresAt;
/// Create a copy of TokenRefresh
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenRefreshCopyWith<TokenRefresh> get copyWith => _$TokenRefreshCopyWithImpl<TokenRefresh>(this as TokenRefresh, _$identity);

  /// Serializes this TokenRefresh to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TokenRefresh;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenRefresh&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TokenRefresh;
  return Object.hash(runtimeType,_this.accessToken,_this.refreshToken,_this.provider,_this.expiresAt);
}



}

/// @nodoc
abstract mixin class $TokenRefreshCopyWith<$Res>  {
  factory $TokenRefreshCopyWith(TokenRefresh value, $Res Function(TokenRefresh) _then) = _$TokenRefreshCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'access_token')@LooseString() String accessToken,@JsonKey(name: 'refresh_token')@LooseStringOrNull() String? refreshToken,@LooseStringOrNull() String? provider,@JsonKey(name: 'expires_at')@LooseDateTime() DateTime? expiresAt
});




}
/// @nodoc
class _$TokenRefreshCopyWithImpl<$Res>
    implements $TokenRefreshCopyWith<$Res> {
  _$TokenRefreshCopyWithImpl(this._self, this._then);

  final TokenRefresh _self;
  final $Res Function(TokenRefresh) _then;

/// Create a copy of TokenRefresh
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = freezed,Object? provider = freezed,Object? expiresAt = freezed,}) {
  return _then(TokenRefresh(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenRefresh].
extension TokenRefreshPatterns on TokenRefresh {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenRefresh value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenRefresh() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenRefresh value)  $default,){
final _that = this;
switch (_that) {
case _TokenRefresh():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenRefresh value)?  $default,){
final _that = this;
switch (_that) {
case _TokenRefresh() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')@LooseString()  String accessToken, @JsonKey(name: 'refresh_token')@LooseStringOrNull()  String? refreshToken, @LooseStringOrNull()  String? provider, @JsonKey(name: 'expires_at')@LooseDateTime()  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenRefresh() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.provider,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')@LooseString()  String accessToken, @JsonKey(name: 'refresh_token')@LooseStringOrNull()  String? refreshToken, @LooseStringOrNull()  String? provider, @JsonKey(name: 'expires_at')@LooseDateTime()  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _TokenRefresh():
return $default(_that.accessToken,_that.refreshToken,_that.provider,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'access_token')@LooseString()  String accessToken, @JsonKey(name: 'refresh_token')@LooseStringOrNull()  String? refreshToken, @LooseStringOrNull()  String? provider, @JsonKey(name: 'expires_at')@LooseDateTime()  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _TokenRefresh() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.provider,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenRefresh extends TokenRefresh {
  const _TokenRefresh({@JsonKey(name: 'access_token')@LooseString() this.accessToken = '', @JsonKey(name: 'refresh_token')@LooseStringOrNull() this.refreshToken, @LooseStringOrNull() this.provider, @JsonKey(name: 'expires_at')@LooseDateTime() this.expiresAt}): super._();
  factory _TokenRefresh.fromJson(Map<String, dynamic> json) => _$TokenRefreshFromJson(json);

@override@JsonKey(name: 'access_token')@LooseString() final  String accessToken;
@override@JsonKey(name: 'refresh_token')@LooseStringOrNull() final  String? refreshToken;
@override@LooseStringOrNull() final  String? provider;
@override@JsonKey(name: 'expires_at')@LooseDateTime() final  DateTime? expiresAt;

/// Create a copy of TokenRefresh
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenRefreshCopyWith<_TokenRefresh> get copyWith => __$TokenRefreshCopyWithImpl<_TokenRefresh>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenRefreshToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenRefresh&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,refreshToken,provider,expiresAt);
}



}

/// @nodoc
abstract mixin class _$TokenRefreshCopyWith<$Res> implements $TokenRefreshCopyWith<$Res> {
  factory _$TokenRefreshCopyWith(_TokenRefresh value, $Res Function(_TokenRefresh) _then) = __$TokenRefreshCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'access_token')@LooseString() String accessToken,@JsonKey(name: 'refresh_token')@LooseStringOrNull() String? refreshToken,@LooseStringOrNull() String? provider,@JsonKey(name: 'expires_at')@LooseDateTime() DateTime? expiresAt
});




}
/// @nodoc
class __$TokenRefreshCopyWithImpl<$Res>
    implements _$TokenRefreshCopyWith<$Res> {
  __$TokenRefreshCopyWithImpl(this._self, this._then);

  final _TokenRefresh _self;
  final $Res Function(_TokenRefresh) _then;

/// Create a copy of TokenRefresh
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = freezed,Object? provider = freezed,Object? expiresAt = freezed,}) {
  return _then(_TokenRefresh(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
