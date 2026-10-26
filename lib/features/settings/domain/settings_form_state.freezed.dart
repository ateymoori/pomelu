// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsFormState {

 String get url; String get username; String get password; String get token; ProbeResult? get probe; bool get probing; bool get signingIn; bool get testing; bool get saving; TestResult? get testResult; String? get signedInAs; Object? get error; AuthCredential? get pendingCredential;/// The stored auth mode while the form shows the saved gateway; it
/// stands while the probe has no answer.
 AuthMode get savedAuthMode;
/// Create a copy of SettingsFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsFormStateCopyWith<SettingsFormState> get copyWith => _$SettingsFormStateCopyWithImpl<SettingsFormState>(this as SettingsFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SettingsFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsFormState&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.probe, _this.probe) || other.probe == _this.probe)&&(identical(other.probing, _this.probing) || other.probing == _this.probing)&&(identical(other.signingIn, _this.signingIn) || other.signingIn == _this.signingIn)&&(identical(other.testing, _this.testing) || other.testing == _this.testing)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.testResult, _this.testResult) || other.testResult == _this.testResult)&&(identical(other.signedInAs, _this.signedInAs) || other.signedInAs == _this.signedInAs)&&const DeepCollectionEquality().equals(other.error, _this.error)&&(identical(other.pendingCredential, _this.pendingCredential) || other.pendingCredential == _this.pendingCredential)&&(identical(other.savedAuthMode, _this.savedAuthMode) || other.savedAuthMode == _this.savedAuthMode));
}


@override
int get hashCode {
  final _this = this as SettingsFormState;
  return Object.hash(runtimeType,_this.url,_this.username,_this.password,_this.token,_this.probe,_this.probing,_this.signingIn,_this.testing,_this.saving,_this.testResult,_this.signedInAs,const DeepCollectionEquality().hash(_this.error),_this.pendingCredential,_this.savedAuthMode);
}



}

/// @nodoc
abstract mixin class $SettingsFormStateCopyWith<$Res>  {
  factory $SettingsFormStateCopyWith(SettingsFormState value, $Res Function(SettingsFormState) _then) = _$SettingsFormStateCopyWithImpl;
@useResult
$Res call({
 String url, String username, String password, String token, ProbeResult? probe, bool probing, bool signingIn, bool testing, bool saving, TestResult? testResult, String? signedInAs, Object? error, AuthCredential? pendingCredential, AuthMode savedAuthMode
});


$ProbeResultCopyWith<$Res>? get probe;$TestResultCopyWith<$Res>? get testResult;

}
/// @nodoc
class _$SettingsFormStateCopyWithImpl<$Res>
    implements $SettingsFormStateCopyWith<$Res> {
  _$SettingsFormStateCopyWithImpl(this._self, this._then);

  final SettingsFormState _self;
  final $Res Function(SettingsFormState) _then;

/// Create a copy of SettingsFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? username = null,Object? password = null,Object? token = null,Object? probe = freezed,Object? probing = null,Object? signingIn = null,Object? testing = null,Object? saving = null,Object? testResult = freezed,Object? signedInAs = freezed,Object? error = freezed,Object? pendingCredential = freezed,Object? savedAuthMode = null,}) {
  return _then(SettingsFormState(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,probe: freezed == probe ? _self.probe : probe // ignore: cast_nullable_to_non_nullable
as ProbeResult?,probing: null == probing ? _self.probing : probing // ignore: cast_nullable_to_non_nullable
as bool,signingIn: null == signingIn ? _self.signingIn : signingIn // ignore: cast_nullable_to_non_nullable
as bool,testing: null == testing ? _self.testing : testing // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,testResult: freezed == testResult ? _self.testResult : testResult // ignore: cast_nullable_to_non_nullable
as TestResult?,signedInAs: freezed == signedInAs ? _self.signedInAs : signedInAs // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error ,pendingCredential: freezed == pendingCredential ? _self.pendingCredential : pendingCredential // ignore: cast_nullable_to_non_nullable
as AuthCredential?,savedAuthMode: null == savedAuthMode ? _self.savedAuthMode : savedAuthMode // ignore: cast_nullable_to_non_nullable
as AuthMode,
  ));
}
/// Create a copy of SettingsFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProbeResultCopyWith<$Res>? get probe {
    if (_self.probe == null) {
    return null;
  }

  return $ProbeResultCopyWith<$Res>(_self.probe!, (value) {
    return _then(_self.copyWith(probe: value));
  });
}/// Create a copy of SettingsFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestResultCopyWith<$Res>? get testResult {
    if (_self.testResult == null) {
    return null;
  }

  return $TestResultCopyWith<$Res>(_self.testResult!, (value) {
    return _then(_self.copyWith(testResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [SettingsFormState].
extension SettingsFormStatePatterns on SettingsFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsFormState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsFormState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String username,  String password,  String token,  ProbeResult? probe,  bool probing,  bool signingIn,  bool testing,  bool saving,  TestResult? testResult,  String? signedInAs,  Object? error,  AuthCredential? pendingCredential,  AuthMode savedAuthMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsFormState() when $default != null:
return $default(_that.url,_that.username,_that.password,_that.token,_that.probe,_that.probing,_that.signingIn,_that.testing,_that.saving,_that.testResult,_that.signedInAs,_that.error,_that.pendingCredential,_that.savedAuthMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String username,  String password,  String token,  ProbeResult? probe,  bool probing,  bool signingIn,  bool testing,  bool saving,  TestResult? testResult,  String? signedInAs,  Object? error,  AuthCredential? pendingCredential,  AuthMode savedAuthMode)  $default,) {final _that = this;
switch (_that) {
case _SettingsFormState():
return $default(_that.url,_that.username,_that.password,_that.token,_that.probe,_that.probing,_that.signingIn,_that.testing,_that.saving,_that.testResult,_that.signedInAs,_that.error,_that.pendingCredential,_that.savedAuthMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String username,  String password,  String token,  ProbeResult? probe,  bool probing,  bool signingIn,  bool testing,  bool saving,  TestResult? testResult,  String? signedInAs,  Object? error,  AuthCredential? pendingCredential,  AuthMode savedAuthMode)?  $default,) {final _that = this;
switch (_that) {
case _SettingsFormState() when $default != null:
return $default(_that.url,_that.username,_that.password,_that.token,_that.probe,_that.probing,_that.signingIn,_that.testing,_that.saving,_that.testResult,_that.signedInAs,_that.error,_that.pendingCredential,_that.savedAuthMode);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsFormState extends SettingsFormState {
  const _SettingsFormState({this.url = '', this.username = '', this.password = '', this.token = '', this.probe, this.probing = false, this.signingIn = false, this.testing = false, this.saving = false, this.testResult, this.signedInAs, this.error, this.pendingCredential, this.savedAuthMode = AuthMode.none}): super._();
  

@override@JsonKey() final  String url;
@override@JsonKey() final  String username;
@override@JsonKey() final  String password;
@override@JsonKey() final  String token;
@override final  ProbeResult? probe;
@override@JsonKey() final  bool probing;
@override@JsonKey() final  bool signingIn;
@override@JsonKey() final  bool testing;
@override@JsonKey() final  bool saving;
@override final  TestResult? testResult;
@override final  String? signedInAs;
@override final  Object? error;
@override final  AuthCredential? pendingCredential;
/// The stored auth mode while the form shows the saved gateway; it
/// stands while the probe has no answer.
@override@JsonKey() final  AuthMode savedAuthMode;

/// Create a copy of SettingsFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsFormStateCopyWith<_SettingsFormState> get copyWith => __$SettingsFormStateCopyWithImpl<_SettingsFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsFormState&&(identical(other.url, url) || other.url == url)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.token, token) || other.token == token)&&(identical(other.probe, probe) || other.probe == probe)&&(identical(other.probing, probing) || other.probing == probing)&&(identical(other.signingIn, signingIn) || other.signingIn == signingIn)&&(identical(other.testing, testing) || other.testing == testing)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.testResult, testResult) || other.testResult == testResult)&&(identical(other.signedInAs, signedInAs) || other.signedInAs == signedInAs)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.pendingCredential, pendingCredential) || other.pendingCredential == pendingCredential)&&(identical(other.savedAuthMode, savedAuthMode) || other.savedAuthMode == savedAuthMode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,username,password,token,probe,probing,signingIn,testing,saving,testResult,signedInAs,const DeepCollectionEquality().hash(error),pendingCredential,savedAuthMode);
}



}

/// @nodoc
abstract mixin class _$SettingsFormStateCopyWith<$Res> implements $SettingsFormStateCopyWith<$Res> {
  factory _$SettingsFormStateCopyWith(_SettingsFormState value, $Res Function(_SettingsFormState) _then) = __$SettingsFormStateCopyWithImpl;
@override @useResult
$Res call({
 String url, String username, String password, String token, ProbeResult? probe, bool probing, bool signingIn, bool testing, bool saving, TestResult? testResult, String? signedInAs, Object? error, AuthCredential? pendingCredential, AuthMode savedAuthMode
});


@override $ProbeResultCopyWith<$Res>? get probe;@override $TestResultCopyWith<$Res>? get testResult;

}
/// @nodoc
class __$SettingsFormStateCopyWithImpl<$Res>
    implements _$SettingsFormStateCopyWith<$Res> {
  __$SettingsFormStateCopyWithImpl(this._self, this._then);

  final _SettingsFormState _self;
  final $Res Function(_SettingsFormState) _then;

/// Create a copy of SettingsFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? username = null,Object? password = null,Object? token = null,Object? probe = freezed,Object? probing = null,Object? signingIn = null,Object? testing = null,Object? saving = null,Object? testResult = freezed,Object? signedInAs = freezed,Object? error = freezed,Object? pendingCredential = freezed,Object? savedAuthMode = null,}) {
  return _then(_SettingsFormState(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,probe: freezed == probe ? _self.probe : probe // ignore: cast_nullable_to_non_nullable
as ProbeResult?,probing: null == probing ? _self.probing : probing // ignore: cast_nullable_to_non_nullable
as bool,signingIn: null == signingIn ? _self.signingIn : signingIn // ignore: cast_nullable_to_non_nullable
as bool,testing: null == testing ? _self.testing : testing // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,testResult: freezed == testResult ? _self.testResult : testResult // ignore: cast_nullable_to_non_nullable
as TestResult?,signedInAs: freezed == signedInAs ? _self.signedInAs : signedInAs // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error ,pendingCredential: freezed == pendingCredential ? _self.pendingCredential : pendingCredential // ignore: cast_nullable_to_non_nullable
as AuthCredential?,savedAuthMode: null == savedAuthMode ? _self.savedAuthMode : savedAuthMode // ignore: cast_nullable_to_non_nullable
as AuthMode,
  ));
}

/// Create a copy of SettingsFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProbeResultCopyWith<$Res>? get probe {
    if (_self.probe == null) {
    return null;
  }

  return $ProbeResultCopyWith<$Res>(_self.probe!, (value) {
    return _then(_self.copyWith(probe: value));
  });
}/// Create a copy of SettingsFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestResultCopyWith<$Res>? get testResult {
    if (_self.testResult == null) {
    return null;
  }

  return $TestResultCopyWith<$Res>(_self.testResult!, (value) {
    return _then(_self.copyWith(testResult: value));
  });
}
}

// dart format on
