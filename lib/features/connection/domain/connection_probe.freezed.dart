// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_probe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProbeResult {

 bool get reachable; GatewayStatus? get status; List<AuthProvider> get providers;/// Why the gateway could not be reached; the screen words it.
 HermesFailure? get failure;
/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProbeResultCopyWith<ProbeResult> get copyWith => _$ProbeResultCopyWithImpl<ProbeResult>(this as ProbeResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProbeResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeResult&&(identical(other.reachable, _this.reachable) || other.reachable == _this.reachable)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.providers, _this.providers)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as ProbeResult;
  return Object.hash(runtimeType,_this.reachable,_this.status,const DeepCollectionEquality().hash(_this.providers),_this.failure);
}

@override
String toString() {
  final _this = this as ProbeResult;
  return 'ProbeResult(reachable: ${_this.reachable}, status: ${_this.status}, providers: ${_this.providers}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $ProbeResultCopyWith<$Res>  {
  factory $ProbeResultCopyWith(ProbeResult value, $Res Function(ProbeResult) _then) = _$ProbeResultCopyWithImpl;
@useResult
$Res call({
 bool reachable, GatewayStatus? status, List<AuthProvider> providers, HermesFailure? failure
});


$GatewayStatusCopyWith<$Res>? get status;

}
/// @nodoc
class _$ProbeResultCopyWithImpl<$Res>
    implements $ProbeResultCopyWith<$Res> {
  _$ProbeResultCopyWithImpl(this._self, this._then);

  final ProbeResult _self;
  final $Res Function(ProbeResult) _then;

/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reachable = null,Object? status = freezed,Object? providers = null,Object? failure = freezed,}) {
  return _then(ProbeResult(
reachable: null == reachable ? _self.reachable : reachable // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GatewayStatus?,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<AuthProvider>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HermesFailure?,
  ));
}
/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GatewayStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $GatewayStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProbeResult].
extension ProbeResultPatterns on ProbeResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProbeResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProbeResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProbeResult value)  $default,){
final _that = this;
switch (_that) {
case _ProbeResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProbeResult value)?  $default,){
final _that = this;
switch (_that) {
case _ProbeResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool reachable,  GatewayStatus? status,  List<AuthProvider> providers,  HermesFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProbeResult() when $default != null:
return $default(_that.reachable,_that.status,_that.providers,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool reachable,  GatewayStatus? status,  List<AuthProvider> providers,  HermesFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _ProbeResult():
return $default(_that.reachable,_that.status,_that.providers,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool reachable,  GatewayStatus? status,  List<AuthProvider> providers,  HermesFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _ProbeResult() when $default != null:
return $default(_that.reachable,_that.status,_that.providers,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _ProbeResult extends ProbeResult {
  const _ProbeResult({required this.reachable, this.status,  List<AuthProvider> providers = const <AuthProvider>[], this.failure}): _providers = providers,super._();
  

@override final  bool reachable;
@override final  GatewayStatus? status;
 final  List<AuthProvider> _providers;
@override@JsonKey() List<AuthProvider> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}

/// Why the gateway could not be reached; the screen words it.
@override final  HermesFailure? failure;

/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProbeResultCopyWith<_ProbeResult> get copyWith => __$ProbeResultCopyWithImpl<_ProbeResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProbeResult&&(identical(other.reachable, reachable) || other.reachable == reachable)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.providers, _providers)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reachable,status,const DeepCollectionEquality().hash(_providers),failure);
}

@override
String toString() {
    return 'ProbeResult(reachable: $reachable, status: $status, providers: $providers, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$ProbeResultCopyWith<$Res> implements $ProbeResultCopyWith<$Res> {
  factory _$ProbeResultCopyWith(_ProbeResult value, $Res Function(_ProbeResult) _then) = __$ProbeResultCopyWithImpl;
@override @useResult
$Res call({
 bool reachable, GatewayStatus? status, List<AuthProvider> providers, HermesFailure? failure
});


@override $GatewayStatusCopyWith<$Res>? get status;

}
/// @nodoc
class __$ProbeResultCopyWithImpl<$Res>
    implements _$ProbeResultCopyWith<$Res> {
  __$ProbeResultCopyWithImpl(this._self, this._then);

  final _ProbeResult _self;
  final $Res Function(_ProbeResult) _then;

/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reachable = null,Object? status = freezed,Object? providers = null,Object? failure = freezed,}) {
  return _then(_ProbeResult(
reachable: null == reachable ? _self.reachable : reachable // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GatewayStatus?,providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<AuthProvider>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HermesFailure?,
  ));
}

/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GatewayStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $GatewayStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}

/// @nodoc
mixin _$TestResult {

 bool get httpOk; bool get wsOk; String? get version;/// Why a leg failed; the screen words it.
 HermesFailure? get failure;/// How the socket closed, as the transport saw it (`HTTP 403`,
/// `close 4401`, `timeout`), secrets taken out; null when it said nothing.
 String? get detail;
/// Create a copy of TestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestResultCopyWith<TestResult> get copyWith => _$TestResultCopyWithImpl<TestResult>(this as TestResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TestResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestResult&&(identical(other.httpOk, _this.httpOk) || other.httpOk == _this.httpOk)&&(identical(other.wsOk, _this.wsOk) || other.wsOk == _this.wsOk)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.detail, _this.detail) || other.detail == _this.detail));
}


@override
int get hashCode {
  final _this = this as TestResult;
  return Object.hash(runtimeType,_this.httpOk,_this.wsOk,_this.version,_this.failure,_this.detail);
}

@override
String toString() {
  final _this = this as TestResult;
  return 'TestResult(httpOk: ${_this.httpOk}, wsOk: ${_this.wsOk}, version: ${_this.version}, failure: ${_this.failure}, detail: ${_this.detail})';
}


}

/// @nodoc
abstract mixin class $TestResultCopyWith<$Res>  {
  factory $TestResultCopyWith(TestResult value, $Res Function(TestResult) _then) = _$TestResultCopyWithImpl;
@useResult
$Res call({
 bool httpOk, bool wsOk, String? version, HermesFailure? failure, String? detail
});




}
/// @nodoc
class _$TestResultCopyWithImpl<$Res>
    implements $TestResultCopyWith<$Res> {
  _$TestResultCopyWithImpl(this._self, this._then);

  final TestResult _self;
  final $Res Function(TestResult) _then;

/// Create a copy of TestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? httpOk = null,Object? wsOk = null,Object? version = freezed,Object? failure = freezed,Object? detail = freezed,}) {
  return _then(TestResult(
httpOk: null == httpOk ? _self.httpOk : httpOk // ignore: cast_nullable_to_non_nullable
as bool,wsOk: null == wsOk ? _self.wsOk : wsOk // ignore: cast_nullable_to_non_nullable
as bool,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HermesFailure?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TestResult].
extension TestResultPatterns on TestResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestResult value)  $default,){
final _that = this;
switch (_that) {
case _TestResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestResult value)?  $default,){
final _that = this;
switch (_that) {
case _TestResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool httpOk,  bool wsOk,  String? version,  HermesFailure? failure,  String? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestResult() when $default != null:
return $default(_that.httpOk,_that.wsOk,_that.version,_that.failure,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool httpOk,  bool wsOk,  String? version,  HermesFailure? failure,  String? detail)  $default,) {final _that = this;
switch (_that) {
case _TestResult():
return $default(_that.httpOk,_that.wsOk,_that.version,_that.failure,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool httpOk,  bool wsOk,  String? version,  HermesFailure? failure,  String? detail)?  $default,) {final _that = this;
switch (_that) {
case _TestResult() when $default != null:
return $default(_that.httpOk,_that.wsOk,_that.version,_that.failure,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _TestResult extends TestResult {
  const _TestResult({required this.httpOk, required this.wsOk, this.version, this.failure, this.detail}): super._();
  

@override final  bool httpOk;
@override final  bool wsOk;
@override final  String? version;
/// Why a leg failed; the screen words it.
@override final  HermesFailure? failure;
/// How the socket closed, as the transport saw it (`HTTP 403`,
/// `close 4401`, `timeout`), secrets taken out; null when it said nothing.
@override final  String? detail;

/// Create a copy of TestResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestResultCopyWith<_TestResult> get copyWith => __$TestResultCopyWithImpl<_TestResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestResult&&(identical(other.httpOk, httpOk) || other.httpOk == httpOk)&&(identical(other.wsOk, wsOk) || other.wsOk == wsOk)&&(identical(other.version, version) || other.version == version)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode {
    return Object.hash(runtimeType,httpOk,wsOk,version,failure,detail);
}

@override
String toString() {
    return 'TestResult(httpOk: $httpOk, wsOk: $wsOk, version: $version, failure: $failure, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$TestResultCopyWith<$Res> implements $TestResultCopyWith<$Res> {
  factory _$TestResultCopyWith(_TestResult value, $Res Function(_TestResult) _then) = __$TestResultCopyWithImpl;
@override @useResult
$Res call({
 bool httpOk, bool wsOk, String? version, HermesFailure? failure, String? detail
});




}
/// @nodoc
class __$TestResultCopyWithImpl<$Res>
    implements _$TestResultCopyWith<$Res> {
  __$TestResultCopyWithImpl(this._self, this._then);

  final _TestResult _self;
  final $Res Function(_TestResult) _then;

/// Create a copy of TestResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? httpOk = null,Object? wsOk = null,Object? version = freezed,Object? failure = freezed,Object? detail = freezed,}) {
  return _then(_TestResult(
httpOk: null == httpOk ? _self.httpOk : httpOk // ignore: cast_nullable_to_non_nullable
as bool,wsOk: null == wsOk ? _self.wsOk : wsOk // ignore: cast_nullable_to_non_nullable
as bool,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HermesFailure?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
