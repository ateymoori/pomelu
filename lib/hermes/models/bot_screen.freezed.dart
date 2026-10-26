// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_screen.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScreenLease {

@JsonKey(unknownEnumValue: ScreenHolder.agent) ScreenHolder get holder;@JsonKey(name: 'viewer_hash')@LooseStringOrNull() String? get viewerHash;@LooseInt() int get epoch;
/// Create a copy of ScreenLease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScreenLeaseCopyWith<ScreenLease> get copyWith => _$ScreenLeaseCopyWithImpl<ScreenLease>(this as ScreenLease, _$identity);

  /// Serializes this ScreenLease to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScreenLease;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScreenLease&&(identical(other.holder, _this.holder) || other.holder == _this.holder)&&(identical(other.viewerHash, _this.viewerHash) || other.viewerHash == _this.viewerHash)&&(identical(other.epoch, _this.epoch) || other.epoch == _this.epoch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScreenLease;
  return Object.hash(runtimeType,_this.holder,_this.viewerHash,_this.epoch);
}

@override
String toString() {
  final _this = this as ScreenLease;
  return 'ScreenLease(holder: ${_this.holder}, viewerHash: ${_this.viewerHash}, epoch: ${_this.epoch})';
}


}

/// @nodoc
abstract mixin class $ScreenLeaseCopyWith<$Res>  {
  factory $ScreenLeaseCopyWith(ScreenLease value, $Res Function(ScreenLease) _then) = _$ScreenLeaseCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: ScreenHolder.agent) ScreenHolder holder,@JsonKey(name: 'viewer_hash')@LooseStringOrNull() String? viewerHash,@LooseInt() int epoch
});




}
/// @nodoc
class _$ScreenLeaseCopyWithImpl<$Res>
    implements $ScreenLeaseCopyWith<$Res> {
  _$ScreenLeaseCopyWithImpl(this._self, this._then);

  final ScreenLease _self;
  final $Res Function(ScreenLease) _then;

/// Create a copy of ScreenLease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? holder = null,Object? viewerHash = freezed,Object? epoch = null,}) {
  return _then(ScreenLease(
holder: null == holder ? _self.holder : holder // ignore: cast_nullable_to_non_nullable
as ScreenHolder,viewerHash: freezed == viewerHash ? _self.viewerHash : viewerHash // ignore: cast_nullable_to_non_nullable
as String?,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ScreenLease].
extension ScreenLeasePatterns on ScreenLease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScreenLease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScreenLease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScreenLease value)  $default,){
final _that = this;
switch (_that) {
case _ScreenLease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScreenLease value)?  $default,){
final _that = this;
switch (_that) {
case _ScreenLease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ScreenHolder.agent)  ScreenHolder holder, @JsonKey(name: 'viewer_hash')@LooseStringOrNull()  String? viewerHash, @LooseInt()  int epoch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScreenLease() when $default != null:
return $default(_that.holder,_that.viewerHash,_that.epoch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ScreenHolder.agent)  ScreenHolder holder, @JsonKey(name: 'viewer_hash')@LooseStringOrNull()  String? viewerHash, @LooseInt()  int epoch)  $default,) {final _that = this;
switch (_that) {
case _ScreenLease():
return $default(_that.holder,_that.viewerHash,_that.epoch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: ScreenHolder.agent)  ScreenHolder holder, @JsonKey(name: 'viewer_hash')@LooseStringOrNull()  String? viewerHash, @LooseInt()  int epoch)?  $default,) {final _that = this;
switch (_that) {
case _ScreenLease() when $default != null:
return $default(_that.holder,_that.viewerHash,_that.epoch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScreenLease extends ScreenLease {
  const _ScreenLease({@JsonKey(unknownEnumValue: ScreenHolder.agent) this.holder = ScreenHolder.agent, @JsonKey(name: 'viewer_hash')@LooseStringOrNull() this.viewerHash, @LooseInt() this.epoch = 0}): super._();
  factory _ScreenLease.fromJson(Map<String, dynamic> json) => _$ScreenLeaseFromJson(json);

@override@JsonKey(unknownEnumValue: ScreenHolder.agent) final  ScreenHolder holder;
@override@JsonKey(name: 'viewer_hash')@LooseStringOrNull() final  String? viewerHash;
@override@JsonKey()@LooseInt() final  int epoch;

/// Create a copy of ScreenLease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScreenLeaseCopyWith<_ScreenLease> get copyWith => __$ScreenLeaseCopyWithImpl<_ScreenLease>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScreenLeaseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScreenLease&&(identical(other.holder, holder) || other.holder == holder)&&(identical(other.viewerHash, viewerHash) || other.viewerHash == viewerHash)&&(identical(other.epoch, epoch) || other.epoch == epoch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,holder,viewerHash,epoch);
}

@override
String toString() {
    return 'ScreenLease(holder: $holder, viewerHash: $viewerHash, epoch: $epoch)';
}


}

/// @nodoc
abstract mixin class _$ScreenLeaseCopyWith<$Res> implements $ScreenLeaseCopyWith<$Res> {
  factory _$ScreenLeaseCopyWith(_ScreenLease value, $Res Function(_ScreenLease) _then) = __$ScreenLeaseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: ScreenHolder.agent) ScreenHolder holder,@JsonKey(name: 'viewer_hash')@LooseStringOrNull() String? viewerHash,@LooseInt() int epoch
});




}
/// @nodoc
class __$ScreenLeaseCopyWithImpl<$Res>
    implements _$ScreenLeaseCopyWith<$Res> {
  __$ScreenLeaseCopyWithImpl(this._self, this._then);

  final _ScreenLease _self;
  final $Res Function(_ScreenLease) _then;

/// Create a copy of ScreenLease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? holder = null,Object? viewerHash = freezed,Object? epoch = null,}) {
  return _then(_ScreenLease(
holder: null == holder ? _self.holder : holder // ignore: cast_nullable_to_non_nullable
as ScreenHolder,viewerHash: freezed == viewerHash ? _self.viewerHash : viewerHash // ignore: cast_nullable_to_non_nullable
as String?,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ScreenStatus {

/// False off a Linux host.
@LooseBool() bool get supported;/// False until the desktop packages are on the host.
@LooseBool() bool get installed;@LooseBool() bool get running;/// Why a start would be refused now (host memory), when it would.
@LooseStringOrNull() String? get blocker; ScreenLease get lease;/// The bot's home on the host; matches the events that are its own.
@JsonKey(name: 'profile_key')@LooseString() String get profileKey;
/// Create a copy of ScreenStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScreenStatusCopyWith<ScreenStatus> get copyWith => _$ScreenStatusCopyWithImpl<ScreenStatus>(this as ScreenStatus, _$identity);

  /// Serializes this ScreenStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScreenStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScreenStatus&&(identical(other.supported, _this.supported) || other.supported == _this.supported)&&(identical(other.installed, _this.installed) || other.installed == _this.installed)&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.blocker, _this.blocker) || other.blocker == _this.blocker)&&(identical(other.lease, _this.lease) || other.lease == _this.lease)&&(identical(other.profileKey, _this.profileKey) || other.profileKey == _this.profileKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScreenStatus;
  return Object.hash(runtimeType,_this.supported,_this.installed,_this.running,_this.blocker,_this.lease,_this.profileKey);
}

@override
String toString() {
  final _this = this as ScreenStatus;
  return 'ScreenStatus(supported: ${_this.supported}, installed: ${_this.installed}, running: ${_this.running}, blocker: ${_this.blocker}, lease: ${_this.lease}, profileKey: ${_this.profileKey})';
}


}

/// @nodoc
abstract mixin class $ScreenStatusCopyWith<$Res>  {
  factory $ScreenStatusCopyWith(ScreenStatus value, $Res Function(ScreenStatus) _then) = _$ScreenStatusCopyWithImpl;
@useResult
$Res call({
@LooseBool() bool supported,@LooseBool() bool installed,@LooseBool() bool running,@LooseStringOrNull() String? blocker, ScreenLease lease,@JsonKey(name: 'profile_key')@LooseString() String profileKey
});


$ScreenLeaseCopyWith<$Res> get lease;

}
/// @nodoc
class _$ScreenStatusCopyWithImpl<$Res>
    implements $ScreenStatusCopyWith<$Res> {
  _$ScreenStatusCopyWithImpl(this._self, this._then);

  final ScreenStatus _self;
  final $Res Function(ScreenStatus) _then;

/// Create a copy of ScreenStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supported = null,Object? installed = null,Object? running = null,Object? blocker = freezed,Object? lease = null,Object? profileKey = null,}) {
  return _then(ScreenStatus(
supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,installed: null == installed ? _self.installed : installed // ignore: cast_nullable_to_non_nullable
as bool,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,blocker: freezed == blocker ? _self.blocker : blocker // ignore: cast_nullable_to_non_nullable
as String?,lease: null == lease ? _self.lease : lease // ignore: cast_nullable_to_non_nullable
as ScreenLease,profileKey: null == profileKey ? _self.profileKey : profileKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ScreenStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScreenLeaseCopyWith<$Res> get lease {
  
  return $ScreenLeaseCopyWith<$Res>(_self.lease, (value) {
    return _then(_self.copyWith(lease: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScreenStatus].
extension ScreenStatusPatterns on ScreenStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScreenStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScreenStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScreenStatus value)  $default,){
final _that = this;
switch (_that) {
case _ScreenStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScreenStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ScreenStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseBool()  bool supported, @LooseBool()  bool installed, @LooseBool()  bool running, @LooseStringOrNull()  String? blocker,  ScreenLease lease, @JsonKey(name: 'profile_key')@LooseString()  String profileKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScreenStatus() when $default != null:
return $default(_that.supported,_that.installed,_that.running,_that.blocker,_that.lease,_that.profileKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseBool()  bool supported, @LooseBool()  bool installed, @LooseBool()  bool running, @LooseStringOrNull()  String? blocker,  ScreenLease lease, @JsonKey(name: 'profile_key')@LooseString()  String profileKey)  $default,) {final _that = this;
switch (_that) {
case _ScreenStatus():
return $default(_that.supported,_that.installed,_that.running,_that.blocker,_that.lease,_that.profileKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseBool()  bool supported, @LooseBool()  bool installed, @LooseBool()  bool running, @LooseStringOrNull()  String? blocker,  ScreenLease lease, @JsonKey(name: 'profile_key')@LooseString()  String profileKey)?  $default,) {final _that = this;
switch (_that) {
case _ScreenStatus() when $default != null:
return $default(_that.supported,_that.installed,_that.running,_that.blocker,_that.lease,_that.profileKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScreenStatus extends ScreenStatus {
  const _ScreenStatus({@LooseBool() this.supported = false, @LooseBool() this.installed = false, @LooseBool() this.running = false, @LooseStringOrNull() this.blocker, this.lease = const ScreenLease(), @JsonKey(name: 'profile_key')@LooseString() this.profileKey = ''}): super._();
  factory _ScreenStatus.fromJson(Map<String, dynamic> json) => _$ScreenStatusFromJson(json);

/// False off a Linux host.
@override@JsonKey()@LooseBool() final  bool supported;
/// False until the desktop packages are on the host.
@override@JsonKey()@LooseBool() final  bool installed;
@override@JsonKey()@LooseBool() final  bool running;
/// Why a start would be refused now (host memory), when it would.
@override@LooseStringOrNull() final  String? blocker;
@override@JsonKey() final  ScreenLease lease;
/// The bot's home on the host; matches the events that are its own.
@override@JsonKey(name: 'profile_key')@LooseString() final  String profileKey;

/// Create a copy of ScreenStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScreenStatusCopyWith<_ScreenStatus> get copyWith => __$ScreenStatusCopyWithImpl<_ScreenStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScreenStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScreenStatus&&(identical(other.supported, supported) || other.supported == supported)&&(identical(other.installed, installed) || other.installed == installed)&&(identical(other.running, running) || other.running == running)&&(identical(other.blocker, blocker) || other.blocker == blocker)&&(identical(other.lease, lease) || other.lease == lease)&&(identical(other.profileKey, profileKey) || other.profileKey == profileKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,supported,installed,running,blocker,lease,profileKey);
}

@override
String toString() {
    return 'ScreenStatus(supported: $supported, installed: $installed, running: $running, blocker: $blocker, lease: $lease, profileKey: $profileKey)';
}


}

/// @nodoc
abstract mixin class _$ScreenStatusCopyWith<$Res> implements $ScreenStatusCopyWith<$Res> {
  factory _$ScreenStatusCopyWith(_ScreenStatus value, $Res Function(_ScreenStatus) _then) = __$ScreenStatusCopyWithImpl;
@override @useResult
$Res call({
@LooseBool() bool supported,@LooseBool() bool installed,@LooseBool() bool running,@LooseStringOrNull() String? blocker, ScreenLease lease,@JsonKey(name: 'profile_key')@LooseString() String profileKey
});


@override $ScreenLeaseCopyWith<$Res> get lease;

}
/// @nodoc
class __$ScreenStatusCopyWithImpl<$Res>
    implements _$ScreenStatusCopyWith<$Res> {
  __$ScreenStatusCopyWithImpl(this._self, this._then);

  final _ScreenStatus _self;
  final $Res Function(_ScreenStatus) _then;

/// Create a copy of ScreenStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supported = null,Object? installed = null,Object? running = null,Object? blocker = freezed,Object? lease = null,Object? profileKey = null,}) {
  return _then(_ScreenStatus(
supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,installed: null == installed ? _self.installed : installed // ignore: cast_nullable_to_non_nullable
as bool,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,blocker: freezed == blocker ? _self.blocker : blocker // ignore: cast_nullable_to_non_nullable
as String?,lease: null == lease ? _self.lease : lease // ignore: cast_nullable_to_non_nullable
as ScreenLease,profileKey: null == profileKey ? _self.profileKey : profileKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ScreenStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScreenLeaseCopyWith<$Res> get lease {
  
  return $ScreenLeaseCopyWith<$Res>(_self.lease, (value) {
    return _then(_self.copyWith(lease: value));
  });
}
}

// dart format on
