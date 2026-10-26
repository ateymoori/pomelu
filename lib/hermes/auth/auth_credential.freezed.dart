// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionTokenCredential {

 String get token; String get origin;
/// Create a copy of SessionTokenCredential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionTokenCredentialCopyWith<SessionTokenCredential> get copyWith => _$SessionTokenCredentialCopyWithImpl<SessionTokenCredential>(this as SessionTokenCredential, _$identity);

  /// Serializes this SessionTokenCredential to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionTokenCredential;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionTokenCredential&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.origin, _this.origin) || other.origin == _this.origin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionTokenCredential;
  return Object.hash(runtimeType,_this.token,_this.origin);
}



}

/// @nodoc
abstract mixin class $SessionTokenCredentialCopyWith<$Res>  {
  factory $SessionTokenCredentialCopyWith(SessionTokenCredential value, $Res Function(SessionTokenCredential) _then) = _$SessionTokenCredentialCopyWithImpl;
@useResult
$Res call({
 String token, String origin
});




}
/// @nodoc
class _$SessionTokenCredentialCopyWithImpl<$Res>
    implements $SessionTokenCredentialCopyWith<$Res> {
  _$SessionTokenCredentialCopyWithImpl(this._self, this._then);

  final SessionTokenCredential _self;
  final $Res Function(SessionTokenCredential) _then;

/// Create a copy of SessionTokenCredential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? origin = null,}) {
  return _then(SessionTokenCredential(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionTokenCredential].
extension SessionTokenCredentialPatterns on SessionTokenCredential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionTokenCredential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionTokenCredential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionTokenCredential value)  $default,){
final _that = this;
switch (_that) {
case _SessionTokenCredential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionTokenCredential value)?  $default,){
final _that = this;
switch (_that) {
case _SessionTokenCredential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String origin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionTokenCredential() when $default != null:
return $default(_that.token,_that.origin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String origin)  $default,) {final _that = this;
switch (_that) {
case _SessionTokenCredential():
return $default(_that.token,_that.origin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String origin)?  $default,) {final _that = this;
switch (_that) {
case _SessionTokenCredential() when $default != null:
return $default(_that.token,_that.origin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionTokenCredential extends SessionTokenCredential {
  const _SessionTokenCredential(this.token, {this.origin = ''}): super._();
  factory _SessionTokenCredential.fromJson(Map<String, dynamic> json) => _$SessionTokenCredentialFromJson(json);

@override final  String token;
@override@JsonKey() final  String origin;

/// Create a copy of SessionTokenCredential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionTokenCredentialCopyWith<_SessionTokenCredential> get copyWith => __$SessionTokenCredentialCopyWithImpl<_SessionTokenCredential>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionTokenCredentialToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionTokenCredential&&(identical(other.token, token) || other.token == token)&&(identical(other.origin, origin) || other.origin == origin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,origin);
}



}

/// @nodoc
abstract mixin class _$SessionTokenCredentialCopyWith<$Res> implements $SessionTokenCredentialCopyWith<$Res> {
  factory _$SessionTokenCredentialCopyWith(_SessionTokenCredential value, $Res Function(_SessionTokenCredential) _then) = __$SessionTokenCredentialCopyWithImpl;
@override @useResult
$Res call({
 String token, String origin
});




}
/// @nodoc
class __$SessionTokenCredentialCopyWithImpl<$Res>
    implements _$SessionTokenCredentialCopyWith<$Res> {
  __$SessionTokenCredentialCopyWithImpl(this._self, this._then);

  final _SessionTokenCredential _self;
  final $Res Function(_SessionTokenCredential) _then;

/// Create a copy of SessionTokenCredential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? origin = null,}) {
  return _then(_SessionTokenCredential(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BearerCredential {

@LooseString() String get accessToken;@LooseStringOrNull() String? get refreshToken;@LooseString() String get provider;@LooseDateTime() DateTime? get expiresAt;@LooseString() String get username;@LooseString() String get origin;
/// Create a copy of BearerCredential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BearerCredentialCopyWith<BearerCredential> get copyWith => _$BearerCredentialCopyWithImpl<BearerCredential>(this as BearerCredential, _$identity);

  /// Serializes this BearerCredential to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BearerCredential;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BearerCredential&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.origin, _this.origin) || other.origin == _this.origin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BearerCredential;
  return Object.hash(runtimeType,_this.accessToken,_this.refreshToken,_this.provider,_this.expiresAt,_this.username,_this.origin);
}



}

/// @nodoc
abstract mixin class $BearerCredentialCopyWith<$Res>  {
  factory $BearerCredentialCopyWith(BearerCredential value, $Res Function(BearerCredential) _then) = _$BearerCredentialCopyWithImpl;
@useResult
$Res call({
@LooseString() String accessToken,@LooseStringOrNull() String? refreshToken,@LooseString() String provider,@LooseDateTime() DateTime? expiresAt,@LooseString() String username,@LooseString() String origin
});




}
/// @nodoc
class _$BearerCredentialCopyWithImpl<$Res>
    implements $BearerCredentialCopyWith<$Res> {
  _$BearerCredentialCopyWithImpl(this._self, this._then);

  final BearerCredential _self;
  final $Res Function(BearerCredential) _then;

/// Create a copy of BearerCredential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = freezed,Object? provider = null,Object? expiresAt = freezed,Object? username = null,Object? origin = null,}) {
  return _then(BearerCredential(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BearerCredential].
extension BearerCredentialPatterns on BearerCredential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BearerCredential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BearerCredential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BearerCredential value)  $default,){
final _that = this;
switch (_that) {
case _BearerCredential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BearerCredential value)?  $default,){
final _that = this;
switch (_that) {
case _BearerCredential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String accessToken, @LooseStringOrNull()  String? refreshToken, @LooseString()  String provider, @LooseDateTime()  DateTime? expiresAt, @LooseString()  String username, @LooseString()  String origin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BearerCredential() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.provider,_that.expiresAt,_that.username,_that.origin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String accessToken, @LooseStringOrNull()  String? refreshToken, @LooseString()  String provider, @LooseDateTime()  DateTime? expiresAt, @LooseString()  String username, @LooseString()  String origin)  $default,) {final _that = this;
switch (_that) {
case _BearerCredential():
return $default(_that.accessToken,_that.refreshToken,_that.provider,_that.expiresAt,_that.username,_that.origin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String accessToken, @LooseStringOrNull()  String? refreshToken, @LooseString()  String provider, @LooseDateTime()  DateTime? expiresAt, @LooseString()  String username, @LooseString()  String origin)?  $default,) {final _that = this;
switch (_that) {
case _BearerCredential() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.provider,_that.expiresAt,_that.username,_that.origin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BearerCredential extends BearerCredential {
  const _BearerCredential({@LooseString() required this.accessToken, @LooseStringOrNull() this.refreshToken, @LooseString() this.provider = '', @LooseDateTime() this.expiresAt, @LooseString() this.username = '', @LooseString() this.origin = ''}): super._();
  factory _BearerCredential.fromJson(Map<String, dynamic> json) => _$BearerCredentialFromJson(json);

@override@LooseString() final  String accessToken;
@override@LooseStringOrNull() final  String? refreshToken;
@override@JsonKey()@LooseString() final  String provider;
@override@LooseDateTime() final  DateTime? expiresAt;
@override@JsonKey()@LooseString() final  String username;
@override@JsonKey()@LooseString() final  String origin;

/// Create a copy of BearerCredential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BearerCredentialCopyWith<_BearerCredential> get copyWith => __$BearerCredentialCopyWithImpl<_BearerCredential>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BearerCredentialToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BearerCredential&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.username, username) || other.username == username)&&(identical(other.origin, origin) || other.origin == origin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,refreshToken,provider,expiresAt,username,origin);
}



}

/// @nodoc
abstract mixin class _$BearerCredentialCopyWith<$Res> implements $BearerCredentialCopyWith<$Res> {
  factory _$BearerCredentialCopyWith(_BearerCredential value, $Res Function(_BearerCredential) _then) = __$BearerCredentialCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String accessToken,@LooseStringOrNull() String? refreshToken,@LooseString() String provider,@LooseDateTime() DateTime? expiresAt,@LooseString() String username,@LooseString() String origin
});




}
/// @nodoc
class __$BearerCredentialCopyWithImpl<$Res>
    implements _$BearerCredentialCopyWith<$Res> {
  __$BearerCredentialCopyWithImpl(this._self, this._then);

  final _BearerCredential _self;
  final $Res Function(_BearerCredential) _then;

/// Create a copy of BearerCredential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = freezed,Object? provider = null,Object? expiresAt = freezed,Object? username = null,Object? origin = null,}) {
  return _then(_BearerCredential(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
