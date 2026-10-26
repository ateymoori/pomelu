// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HermesProfile {

@LooseString() String get name;@JsonKey(name: 'is_default')@LooseBool() bool get isDefault;@LooseString() String get model;@LooseString() String get provider;@LooseString() String get description;@JsonKey(name: 'display_name')@LooseString() String get displayName;@JsonKey(name: 'last_session') SessionPreview? get lastSession;@JsonKey(name: 'worker_session') WorkerSession? get workerSession;@JsonKey(name: 'canonical_session') CanonicalSession? get canonicalSession;@JsonKey(name: 'ui_meta')@LooseMap() Map<String, dynamic>? get uiMeta;/// Per-key write counters of [uiMeta], for a compare-and-set; null on a
/// gateway without them.
@JsonKey(name: 'ui_meta_revisions')@LooseMap() Map<String, dynamic>? get uiMetaRevisions;
/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HermesProfileCopyWith<HermesProfile> get copyWith => _$HermesProfileCopyWithImpl<HermesProfile>(this as HermesProfile, _$identity);

  /// Serializes this HermesProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HermesProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HermesProfile&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.lastSession, _this.lastSession) || other.lastSession == _this.lastSession)&&(identical(other.workerSession, _this.workerSession) || other.workerSession == _this.workerSession)&&(identical(other.canonicalSession, _this.canonicalSession) || other.canonicalSession == _this.canonicalSession)&&const DeepCollectionEquality().equals(other.uiMeta, _this.uiMeta)&&const DeepCollectionEquality().equals(other.uiMetaRevisions, _this.uiMetaRevisions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HermesProfile;
  return Object.hash(runtimeType,_this.name,_this.isDefault,_this.model,_this.provider,_this.description,_this.displayName,_this.lastSession,_this.workerSession,_this.canonicalSession,const DeepCollectionEquality().hash(_this.uiMeta),const DeepCollectionEquality().hash(_this.uiMetaRevisions));
}

@override
String toString() {
  final _this = this as HermesProfile;
  return 'HermesProfile(name: ${_this.name}, isDefault: ${_this.isDefault}, model: ${_this.model}, provider: ${_this.provider}, description: ${_this.description}, displayName: ${_this.displayName}, lastSession: ${_this.lastSession}, workerSession: ${_this.workerSession}, canonicalSession: ${_this.canonicalSession}, uiMeta: ${_this.uiMeta}, uiMetaRevisions: ${_this.uiMetaRevisions})';
}


}

/// @nodoc
abstract mixin class $HermesProfileCopyWith<$Res>  {
  factory $HermesProfileCopyWith(HermesProfile value, $Res Function(HermesProfile) _then) = _$HermesProfileCopyWithImpl;
@useResult
$Res call({
@LooseString() String name,@JsonKey(name: 'is_default')@LooseBool() bool isDefault,@LooseString() String model,@LooseString() String provider,@LooseString() String description,@JsonKey(name: 'display_name')@LooseString() String displayName,@JsonKey(name: 'last_session') SessionPreview? lastSession,@JsonKey(name: 'worker_session') WorkerSession? workerSession,@JsonKey(name: 'canonical_session') CanonicalSession? canonicalSession,@JsonKey(name: 'ui_meta')@LooseMap() Map<String, dynamic>? uiMeta,@JsonKey(name: 'ui_meta_revisions')@LooseMap() Map<String, dynamic>? uiMetaRevisions
});


$SessionPreviewCopyWith<$Res>? get lastSession;$WorkerSessionCopyWith<$Res>? get workerSession;$CanonicalSessionCopyWith<$Res>? get canonicalSession;

}
/// @nodoc
class _$HermesProfileCopyWithImpl<$Res>
    implements $HermesProfileCopyWith<$Res> {
  _$HermesProfileCopyWithImpl(this._self, this._then);

  final HermesProfile _self;
  final $Res Function(HermesProfile) _then;

/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? isDefault = null,Object? model = null,Object? provider = null,Object? description = null,Object? displayName = null,Object? lastSession = freezed,Object? workerSession = freezed,Object? canonicalSession = freezed,Object? uiMeta = freezed,Object? uiMetaRevisions = freezed,}) {
  return _then(HermesProfile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,lastSession: freezed == lastSession ? _self.lastSession : lastSession // ignore: cast_nullable_to_non_nullable
as SessionPreview?,workerSession: freezed == workerSession ? _self.workerSession : workerSession // ignore: cast_nullable_to_non_nullable
as WorkerSession?,canonicalSession: freezed == canonicalSession ? _self.canonicalSession : canonicalSession // ignore: cast_nullable_to_non_nullable
as CanonicalSession?,uiMeta: freezed == uiMeta ? _self.uiMeta : uiMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,uiMetaRevisions: freezed == uiMetaRevisions ? _self.uiMetaRevisions : uiMetaRevisions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionPreviewCopyWith<$Res>? get lastSession {
    if (_self.lastSession == null) {
    return null;
  }

  return $SessionPreviewCopyWith<$Res>(_self.lastSession!, (value) {
    return _then(_self.copyWith(lastSession: value));
  });
}/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkerSessionCopyWith<$Res>? get workerSession {
    if (_self.workerSession == null) {
    return null;
  }

  return $WorkerSessionCopyWith<$Res>(_self.workerSession!, (value) {
    return _then(_self.copyWith(workerSession: value));
  });
}/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CanonicalSessionCopyWith<$Res>? get canonicalSession {
    if (_self.canonicalSession == null) {
    return null;
  }

  return $CanonicalSessionCopyWith<$Res>(_self.canonicalSession!, (value) {
    return _then(_self.copyWith(canonicalSession: value));
  });
}
}


/// Adds pattern-matching-related methods to [HermesProfile].
extension HermesProfilePatterns on HermesProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HermesProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HermesProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HermesProfile value)  $default,){
final _that = this;
switch (_that) {
case _HermesProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HermesProfile value)?  $default,){
final _that = this;
switch (_that) {
case _HermesProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String name, @JsonKey(name: 'is_default')@LooseBool()  bool isDefault, @LooseString()  String model, @LooseString()  String provider, @LooseString()  String description, @JsonKey(name: 'display_name')@LooseString()  String displayName, @JsonKey(name: 'last_session')  SessionPreview? lastSession, @JsonKey(name: 'worker_session')  WorkerSession? workerSession, @JsonKey(name: 'canonical_session')  CanonicalSession? canonicalSession, @JsonKey(name: 'ui_meta')@LooseMap()  Map<String, dynamic>? uiMeta, @JsonKey(name: 'ui_meta_revisions')@LooseMap()  Map<String, dynamic>? uiMetaRevisions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HermesProfile() when $default != null:
return $default(_that.name,_that.isDefault,_that.model,_that.provider,_that.description,_that.displayName,_that.lastSession,_that.workerSession,_that.canonicalSession,_that.uiMeta,_that.uiMetaRevisions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String name, @JsonKey(name: 'is_default')@LooseBool()  bool isDefault, @LooseString()  String model, @LooseString()  String provider, @LooseString()  String description, @JsonKey(name: 'display_name')@LooseString()  String displayName, @JsonKey(name: 'last_session')  SessionPreview? lastSession, @JsonKey(name: 'worker_session')  WorkerSession? workerSession, @JsonKey(name: 'canonical_session')  CanonicalSession? canonicalSession, @JsonKey(name: 'ui_meta')@LooseMap()  Map<String, dynamic>? uiMeta, @JsonKey(name: 'ui_meta_revisions')@LooseMap()  Map<String, dynamic>? uiMetaRevisions)  $default,) {final _that = this;
switch (_that) {
case _HermesProfile():
return $default(_that.name,_that.isDefault,_that.model,_that.provider,_that.description,_that.displayName,_that.lastSession,_that.workerSession,_that.canonicalSession,_that.uiMeta,_that.uiMetaRevisions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String name, @JsonKey(name: 'is_default')@LooseBool()  bool isDefault, @LooseString()  String model, @LooseString()  String provider, @LooseString()  String description, @JsonKey(name: 'display_name')@LooseString()  String displayName, @JsonKey(name: 'last_session')  SessionPreview? lastSession, @JsonKey(name: 'worker_session')  WorkerSession? workerSession, @JsonKey(name: 'canonical_session')  CanonicalSession? canonicalSession, @JsonKey(name: 'ui_meta')@LooseMap()  Map<String, dynamic>? uiMeta, @JsonKey(name: 'ui_meta_revisions')@LooseMap()  Map<String, dynamic>? uiMetaRevisions)?  $default,) {final _that = this;
switch (_that) {
case _HermesProfile() when $default != null:
return $default(_that.name,_that.isDefault,_that.model,_that.provider,_that.description,_that.displayName,_that.lastSession,_that.workerSession,_that.canonicalSession,_that.uiMeta,_that.uiMetaRevisions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HermesProfile extends HermesProfile {
  const _HermesProfile({@LooseString() this.name = '', @JsonKey(name: 'is_default')@LooseBool() this.isDefault = false, @LooseString() this.model = '', @LooseString() this.provider = '', @LooseString() this.description = '', @JsonKey(name: 'display_name')@LooseString() this.displayName = '', @JsonKey(name: 'last_session') this.lastSession, @JsonKey(name: 'worker_session') this.workerSession, @JsonKey(name: 'canonical_session') this.canonicalSession, @JsonKey(name: 'ui_meta')@LooseMap()  Map<String, dynamic>? uiMeta, @JsonKey(name: 'ui_meta_revisions')@LooseMap()  Map<String, dynamic>? uiMetaRevisions}): _uiMeta = uiMeta,_uiMetaRevisions = uiMetaRevisions,super._();
  factory _HermesProfile.fromJson(Map<String, dynamic> json) => _$HermesProfileFromJson(json);

@override@JsonKey()@LooseString() final  String name;
@override@JsonKey(name: 'is_default')@LooseBool() final  bool isDefault;
@override@JsonKey()@LooseString() final  String model;
@override@JsonKey()@LooseString() final  String provider;
@override@JsonKey()@LooseString() final  String description;
@override@JsonKey(name: 'display_name')@LooseString() final  String displayName;
@override@JsonKey(name: 'last_session') final  SessionPreview? lastSession;
@override@JsonKey(name: 'worker_session') final  WorkerSession? workerSession;
@override@JsonKey(name: 'canonical_session') final  CanonicalSession? canonicalSession;
 final  Map<String, dynamic>? _uiMeta;
@override@JsonKey(name: 'ui_meta')@LooseMap() Map<String, dynamic>? get uiMeta {
  final value = _uiMeta;
  if (value == null) return null;
  if (_uiMeta is EqualUnmodifiableMapView) return _uiMeta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Per-key write counters of [uiMeta], for a compare-and-set; null on a
/// gateway without them.
 final  Map<String, dynamic>? _uiMetaRevisions;
/// Per-key write counters of [uiMeta], for a compare-and-set; null on a
/// gateway without them.
@override@JsonKey(name: 'ui_meta_revisions')@LooseMap() Map<String, dynamic>? get uiMetaRevisions {
  final value = _uiMetaRevisions;
  if (value == null) return null;
  if (_uiMetaRevisions is EqualUnmodifiableMapView) return _uiMetaRevisions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HermesProfileCopyWith<_HermesProfile> get copyWith => __$HermesProfileCopyWithImpl<_HermesProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HermesProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HermesProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.model, model) || other.model == model)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.description, description) || other.description == description)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.lastSession, lastSession) || other.lastSession == lastSession)&&(identical(other.workerSession, workerSession) || other.workerSession == workerSession)&&(identical(other.canonicalSession, canonicalSession) || other.canonicalSession == canonicalSession)&&const DeepCollectionEquality().equals(other.uiMeta, _uiMeta)&&const DeepCollectionEquality().equals(other.uiMetaRevisions, _uiMetaRevisions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,isDefault,model,provider,description,displayName,lastSession,workerSession,canonicalSession,const DeepCollectionEquality().hash(_uiMeta),const DeepCollectionEquality().hash(_uiMetaRevisions));
}

@override
String toString() {
    return 'HermesProfile(name: $name, isDefault: $isDefault, model: $model, provider: $provider, description: $description, displayName: $displayName, lastSession: $lastSession, workerSession: $workerSession, canonicalSession: $canonicalSession, uiMeta: $uiMeta, uiMetaRevisions: $uiMetaRevisions)';
}


}

/// @nodoc
abstract mixin class _$HermesProfileCopyWith<$Res> implements $HermesProfileCopyWith<$Res> {
  factory _$HermesProfileCopyWith(_HermesProfile value, $Res Function(_HermesProfile) _then) = __$HermesProfileCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String name,@JsonKey(name: 'is_default')@LooseBool() bool isDefault,@LooseString() String model,@LooseString() String provider,@LooseString() String description,@JsonKey(name: 'display_name')@LooseString() String displayName,@JsonKey(name: 'last_session') SessionPreview? lastSession,@JsonKey(name: 'worker_session') WorkerSession? workerSession,@JsonKey(name: 'canonical_session') CanonicalSession? canonicalSession,@JsonKey(name: 'ui_meta')@LooseMap() Map<String, dynamic>? uiMeta,@JsonKey(name: 'ui_meta_revisions')@LooseMap() Map<String, dynamic>? uiMetaRevisions
});


@override $SessionPreviewCopyWith<$Res>? get lastSession;@override $WorkerSessionCopyWith<$Res>? get workerSession;@override $CanonicalSessionCopyWith<$Res>? get canonicalSession;

}
/// @nodoc
class __$HermesProfileCopyWithImpl<$Res>
    implements _$HermesProfileCopyWith<$Res> {
  __$HermesProfileCopyWithImpl(this._self, this._then);

  final _HermesProfile _self;
  final $Res Function(_HermesProfile) _then;

/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? isDefault = null,Object? model = null,Object? provider = null,Object? description = null,Object? displayName = null,Object? lastSession = freezed,Object? workerSession = freezed,Object? canonicalSession = freezed,Object? uiMeta = freezed,Object? uiMetaRevisions = freezed,}) {
  return _then(_HermesProfile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,lastSession: freezed == lastSession ? _self.lastSession : lastSession // ignore: cast_nullable_to_non_nullable
as SessionPreview?,workerSession: freezed == workerSession ? _self.workerSession : workerSession // ignore: cast_nullable_to_non_nullable
as WorkerSession?,canonicalSession: freezed == canonicalSession ? _self.canonicalSession : canonicalSession // ignore: cast_nullable_to_non_nullable
as CanonicalSession?,uiMeta: freezed == uiMeta ? _self._uiMeta : uiMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,uiMetaRevisions: freezed == uiMetaRevisions ? _self._uiMetaRevisions : uiMetaRevisions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionPreviewCopyWith<$Res>? get lastSession {
    if (_self.lastSession == null) {
    return null;
  }

  return $SessionPreviewCopyWith<$Res>(_self.lastSession!, (value) {
    return _then(_self.copyWith(lastSession: value));
  });
}/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkerSessionCopyWith<$Res>? get workerSession {
    if (_self.workerSession == null) {
    return null;
  }

  return $WorkerSessionCopyWith<$Res>(_self.workerSession!, (value) {
    return _then(_self.copyWith(workerSession: value));
  });
}/// Create a copy of HermesProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CanonicalSessionCopyWith<$Res>? get canonicalSession {
    if (_self.canonicalSession == null) {
    return null;
  }

  return $CanonicalSessionCopyWith<$Res>(_self.canonicalSession!, (value) {
    return _then(_self.copyWith(canonicalSession: value));
  });
}
}


/// @nodoc
mixin _$SessionPreview {

@LooseString() String get id;@LooseString() String get title;@LooseString() String get preview;@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? get lastActive;@JsonKey(name: 'message_count')@LooseInt() int get messageCount;
/// Create a copy of SessionPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionPreviewCopyWith<SessionPreview> get copyWith => _$SessionPreviewCopyWithImpl<SessionPreview>(this as SessionPreview, _$identity);

  /// Serializes this SessionPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionPreview&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.preview, _this.preview) || other.preview == _this.preview)&&(identical(other.lastActive, _this.lastActive) || other.lastActive == _this.lastActive)&&(identical(other.messageCount, _this.messageCount) || other.messageCount == _this.messageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionPreview;
  return Object.hash(runtimeType,_this.id,_this.title,_this.preview,_this.lastActive,_this.messageCount);
}

@override
String toString() {
  final _this = this as SessionPreview;
  return 'SessionPreview(id: ${_this.id}, title: ${_this.title}, preview: ${_this.preview}, lastActive: ${_this.lastActive}, messageCount: ${_this.messageCount})';
}


}

/// @nodoc
abstract mixin class $SessionPreviewCopyWith<$Res>  {
  factory $SessionPreviewCopyWith(SessionPreview value, $Res Function(SessionPreview) _then) = _$SessionPreviewCopyWithImpl;
@useResult
$Res call({
@LooseString() String id,@LooseString() String title,@LooseString() String preview,@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? lastActive,@JsonKey(name: 'message_count')@LooseInt() int messageCount
});




}
/// @nodoc
class _$SessionPreviewCopyWithImpl<$Res>
    implements $SessionPreviewCopyWith<$Res> {
  _$SessionPreviewCopyWithImpl(this._self, this._then);

  final SessionPreview _self;
  final $Res Function(SessionPreview) _then;

/// Create a copy of SessionPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? lastActive = freezed,Object? messageCount = null,}) {
  return _then(SessionPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionPreview].
extension SessionPreviewPatterns on SessionPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionPreview value)  $default,){
final _that = this;
switch (_that) {
case _SessionPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionPreview value)?  $default,){
final _that = this;
switch (_that) {
case _SessionPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String title, @LooseString()  String preview, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'message_count')@LooseInt()  int messageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionPreview() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.lastActive,_that.messageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String title, @LooseString()  String preview, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'message_count')@LooseInt()  int messageCount)  $default,) {final _that = this;
switch (_that) {
case _SessionPreview():
return $default(_that.id,_that.title,_that.preview,_that.lastActive,_that.messageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String id, @LooseString()  String title, @LooseString()  String preview, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'message_count')@LooseInt()  int messageCount)?  $default,) {final _that = this;
switch (_that) {
case _SessionPreview() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.lastActive,_that.messageCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionPreview extends SessionPreview {
  const _SessionPreview({@LooseString() this.id = '', @LooseString() this.title = '', @LooseString() this.preview = '', @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) this.lastActive, @JsonKey(name: 'message_count')@LooseInt() this.messageCount = 0}): super._();
  factory _SessionPreview.fromJson(Map<String, dynamic> json) => _$SessionPreviewFromJson(json);

@override@JsonKey()@LooseString() final  String id;
@override@JsonKey()@LooseString() final  String title;
@override@JsonKey()@LooseString() final  String preview;
@override@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) final  DateTime? lastActive;
@override@JsonKey(name: 'message_count')@LooseInt() final  int messageCount;

/// Create a copy of SessionPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionPreviewCopyWith<_SessionPreview> get copyWith => __$SessionPreviewCopyWithImpl<_SessionPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.lastActive, lastActive) || other.lastActive == lastActive)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,preview,lastActive,messageCount);
}

@override
String toString() {
    return 'SessionPreview(id: $id, title: $title, preview: $preview, lastActive: $lastActive, messageCount: $messageCount)';
}


}

/// @nodoc
abstract mixin class _$SessionPreviewCopyWith<$Res> implements $SessionPreviewCopyWith<$Res> {
  factory _$SessionPreviewCopyWith(_SessionPreview value, $Res Function(_SessionPreview) _then) = __$SessionPreviewCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String id,@LooseString() String title,@LooseString() String preview,@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? lastActive,@JsonKey(name: 'message_count')@LooseInt() int messageCount
});




}
/// @nodoc
class __$SessionPreviewCopyWithImpl<$Res>
    implements _$SessionPreviewCopyWith<$Res> {
  __$SessionPreviewCopyWithImpl(this._self, this._then);

  final _SessionPreview _self;
  final $Res Function(_SessionPreview) _then;

/// Create a copy of SessionPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? lastActive = freezed,Object? messageCount = null,}) {
  return _then(_SessionPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CanonicalSession {

@LooseString() String get id;/// The live tip of a compacted chat.
@JsonKey(name: 'resolved_id')@LooseStringOrNull() String? get resolvedId;@LooseString() String get title;@LooseString() String get preview;@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? get lastActive;@JsonKey(name: 'message_count')@LooseInt() int get messageCount;
/// Create a copy of CanonicalSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanonicalSessionCopyWith<CanonicalSession> get copyWith => _$CanonicalSessionCopyWithImpl<CanonicalSession>(this as CanonicalSession, _$identity);

  /// Serializes this CanonicalSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CanonicalSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanonicalSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.resolvedId, _this.resolvedId) || other.resolvedId == _this.resolvedId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.preview, _this.preview) || other.preview == _this.preview)&&(identical(other.lastActive, _this.lastActive) || other.lastActive == _this.lastActive)&&(identical(other.messageCount, _this.messageCount) || other.messageCount == _this.messageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CanonicalSession;
  return Object.hash(runtimeType,_this.id,_this.resolvedId,_this.title,_this.preview,_this.lastActive,_this.messageCount);
}

@override
String toString() {
  final _this = this as CanonicalSession;
  return 'CanonicalSession(id: ${_this.id}, resolvedId: ${_this.resolvedId}, title: ${_this.title}, preview: ${_this.preview}, lastActive: ${_this.lastActive}, messageCount: ${_this.messageCount})';
}


}

/// @nodoc
abstract mixin class $CanonicalSessionCopyWith<$Res>  {
  factory $CanonicalSessionCopyWith(CanonicalSession value, $Res Function(CanonicalSession) _then) = _$CanonicalSessionCopyWithImpl;
@useResult
$Res call({
@LooseString() String id,@JsonKey(name: 'resolved_id')@LooseStringOrNull() String? resolvedId,@LooseString() String title,@LooseString() String preview,@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? lastActive,@JsonKey(name: 'message_count')@LooseInt() int messageCount
});




}
/// @nodoc
class _$CanonicalSessionCopyWithImpl<$Res>
    implements $CanonicalSessionCopyWith<$Res> {
  _$CanonicalSessionCopyWithImpl(this._self, this._then);

  final CanonicalSession _self;
  final $Res Function(CanonicalSession) _then;

/// Create a copy of CanonicalSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? resolvedId = freezed,Object? title = null,Object? preview = null,Object? lastActive = freezed,Object? messageCount = null,}) {
  return _then(CanonicalSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resolvedId: freezed == resolvedId ? _self.resolvedId : resolvedId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CanonicalSession].
extension CanonicalSessionPatterns on CanonicalSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CanonicalSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CanonicalSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CanonicalSession value)  $default,){
final _that = this;
switch (_that) {
case _CanonicalSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CanonicalSession value)?  $default,){
final _that = this;
switch (_that) {
case _CanonicalSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String id, @JsonKey(name: 'resolved_id')@LooseStringOrNull()  String? resolvedId, @LooseString()  String title, @LooseString()  String preview, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'message_count')@LooseInt()  int messageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CanonicalSession() when $default != null:
return $default(_that.id,_that.resolvedId,_that.title,_that.preview,_that.lastActive,_that.messageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String id, @JsonKey(name: 'resolved_id')@LooseStringOrNull()  String? resolvedId, @LooseString()  String title, @LooseString()  String preview, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'message_count')@LooseInt()  int messageCount)  $default,) {final _that = this;
switch (_that) {
case _CanonicalSession():
return $default(_that.id,_that.resolvedId,_that.title,_that.preview,_that.lastActive,_that.messageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String id, @JsonKey(name: 'resolved_id')@LooseStringOrNull()  String? resolvedId, @LooseString()  String title, @LooseString()  String preview, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive, @JsonKey(name: 'message_count')@LooseInt()  int messageCount)?  $default,) {final _that = this;
switch (_that) {
case _CanonicalSession() when $default != null:
return $default(_that.id,_that.resolvedId,_that.title,_that.preview,_that.lastActive,_that.messageCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CanonicalSession extends CanonicalSession {
  const _CanonicalSession({@LooseString() this.id = '', @JsonKey(name: 'resolved_id')@LooseStringOrNull() this.resolvedId, @LooseString() this.title = '', @LooseString() this.preview = '', @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) this.lastActive, @JsonKey(name: 'message_count')@LooseInt() this.messageCount = 0}): super._();
  factory _CanonicalSession.fromJson(Map<String, dynamic> json) => _$CanonicalSessionFromJson(json);

@override@JsonKey()@LooseString() final  String id;
/// The live tip of a compacted chat.
@override@JsonKey(name: 'resolved_id')@LooseStringOrNull() final  String? resolvedId;
@override@JsonKey()@LooseString() final  String title;
@override@JsonKey()@LooseString() final  String preview;
@override@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) final  DateTime? lastActive;
@override@JsonKey(name: 'message_count')@LooseInt() final  int messageCount;

/// Create a copy of CanonicalSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CanonicalSessionCopyWith<_CanonicalSession> get copyWith => __$CanonicalSessionCopyWithImpl<_CanonicalSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CanonicalSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CanonicalSession&&(identical(other.id, id) || other.id == id)&&(identical(other.resolvedId, resolvedId) || other.resolvedId == resolvedId)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.lastActive, lastActive) || other.lastActive == lastActive)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,resolvedId,title,preview,lastActive,messageCount);
}

@override
String toString() {
    return 'CanonicalSession(id: $id, resolvedId: $resolvedId, title: $title, preview: $preview, lastActive: $lastActive, messageCount: $messageCount)';
}


}

/// @nodoc
abstract mixin class _$CanonicalSessionCopyWith<$Res> implements $CanonicalSessionCopyWith<$Res> {
  factory _$CanonicalSessionCopyWith(_CanonicalSession value, $Res Function(_CanonicalSession) _then) = __$CanonicalSessionCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String id,@JsonKey(name: 'resolved_id')@LooseStringOrNull() String? resolvedId,@LooseString() String title,@LooseString() String preview,@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? lastActive,@JsonKey(name: 'message_count')@LooseInt() int messageCount
});




}
/// @nodoc
class __$CanonicalSessionCopyWithImpl<$Res>
    implements _$CanonicalSessionCopyWith<$Res> {
  __$CanonicalSessionCopyWithImpl(this._self, this._then);

  final _CanonicalSession _self;
  final $Res Function(_CanonicalSession) _then;

/// Create a copy of CanonicalSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? resolvedId = freezed,Object? title = null,Object? preview = null,Object? lastActive = freezed,Object? messageCount = null,}) {
  return _then(_CanonicalSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resolvedId: freezed == resolvedId ? _self.resolvedId : resolvedId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WorkerSession {

@LooseString() String get id;@LooseString() String get title;@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? get lastActive;
/// Create a copy of WorkerSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerSessionCopyWith<WorkerSession> get copyWith => _$WorkerSessionCopyWithImpl<WorkerSession>(this as WorkerSession, _$identity);

  /// Serializes this WorkerSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkerSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkerSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.lastActive, _this.lastActive) || other.lastActive == _this.lastActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkerSession;
  return Object.hash(runtimeType,_this.id,_this.title,_this.lastActive);
}

@override
String toString() {
  final _this = this as WorkerSession;
  return 'WorkerSession(id: ${_this.id}, title: ${_this.title}, lastActive: ${_this.lastActive})';
}


}

/// @nodoc
abstract mixin class $WorkerSessionCopyWith<$Res>  {
  factory $WorkerSessionCopyWith(WorkerSession value, $Res Function(WorkerSession) _then) = _$WorkerSessionCopyWithImpl;
@useResult
$Res call({
@LooseString() String id,@LooseString() String title,@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? lastActive
});




}
/// @nodoc
class _$WorkerSessionCopyWithImpl<$Res>
    implements $WorkerSessionCopyWith<$Res> {
  _$WorkerSessionCopyWithImpl(this._self, this._then);

  final WorkerSession _self;
  final $Res Function(WorkerSession) _then;

/// Create a copy of WorkerSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? lastActive = freezed,}) {
  return _then(WorkerSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkerSession].
extension WorkerSessionPatterns on WorkerSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkerSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkerSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkerSession value)  $default,){
final _that = this;
switch (_that) {
case _WorkerSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkerSession value)?  $default,){
final _that = this;
switch (_that) {
case _WorkerSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String title, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkerSession() when $default != null:
return $default(_that.id,_that.title,_that.lastActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String title, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive)  $default,) {final _that = this;
switch (_that) {
case _WorkerSession():
return $default(_that.id,_that.title,_that.lastActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String id, @LooseString()  String title, @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds)  DateTime? lastActive)?  $default,) {final _that = this;
switch (_that) {
case _WorkerSession() when $default != null:
return $default(_that.id,_that.title,_that.lastActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkerSession implements WorkerSession {
  const _WorkerSession({@LooseString() this.id = '', @LooseString() this.title = '', @JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) this.lastActive});
  factory _WorkerSession.fromJson(Map<String, dynamic> json) => _$WorkerSessionFromJson(json);

@override@JsonKey()@LooseString() final  String id;
@override@JsonKey()@LooseString() final  String title;
@override@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) final  DateTime? lastActive;

/// Create a copy of WorkerSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerSessionCopyWith<_WorkerSession> get copyWith => __$WorkerSessionCopyWithImpl<_WorkerSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkerSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkerSession&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.lastActive, lastActive) || other.lastActive == lastActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,lastActive);
}

@override
String toString() {
    return 'WorkerSession(id: $id, title: $title, lastActive: $lastActive)';
}


}

/// @nodoc
abstract mixin class _$WorkerSessionCopyWith<$Res> implements $WorkerSessionCopyWith<$Res> {
  factory _$WorkerSessionCopyWith(_WorkerSession value, $Res Function(_WorkerSession) _then) = __$WorkerSessionCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String id,@LooseString() String title,@JsonKey(name: 'last_active', fromJson: dateTimeFromEpochSeconds) DateTime? lastActive
});




}
/// @nodoc
class __$WorkerSessionCopyWithImpl<$Res>
    implements _$WorkerSessionCopyWith<$Res> {
  __$WorkerSessionCopyWithImpl(this._self, this._then);

  final _WorkerSession _self;
  final $Res Function(_WorkerSession) _then;

/// Create a copy of WorkerSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? lastActive = freezed,}) {
  return _then(_WorkerSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BotMeta {

@LooseStringOrNull() String? get color;@LooseStringOrNull() String? get title;@LooseStringOrNull() String? get description;@LooseStringOrNull() String? get image;@LooseStringOrNull() String? get shape;@LooseStringOrNull() String? get group;@LooseBool() bool get hidden;
/// Create a copy of BotMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotMetaCopyWith<BotMeta> get copyWith => _$BotMetaCopyWithImpl<BotMeta>(this as BotMeta, _$identity);

  /// Serializes this BotMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BotMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotMeta&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.image, _this.image) || other.image == _this.image)&&(identical(other.shape, _this.shape) || other.shape == _this.shape)&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BotMeta;
  return Object.hash(runtimeType,_this.color,_this.title,_this.description,_this.image,_this.shape,_this.group,_this.hidden);
}

@override
String toString() {
  final _this = this as BotMeta;
  return 'BotMeta(color: ${_this.color}, title: ${_this.title}, description: ${_this.description}, image: ${_this.image}, shape: ${_this.shape}, group: ${_this.group}, hidden: ${_this.hidden})';
}


}

/// @nodoc
abstract mixin class $BotMetaCopyWith<$Res>  {
  factory $BotMetaCopyWith(BotMeta value, $Res Function(BotMeta) _then) = _$BotMetaCopyWithImpl;
@useResult
$Res call({
@LooseStringOrNull() String? color,@LooseStringOrNull() String? title,@LooseStringOrNull() String? description,@LooseStringOrNull() String? image,@LooseStringOrNull() String? shape,@LooseStringOrNull() String? group,@LooseBool() bool hidden
});




}
/// @nodoc
class _$BotMetaCopyWithImpl<$Res>
    implements $BotMetaCopyWith<$Res> {
  _$BotMetaCopyWithImpl(this._self, this._then);

  final BotMeta _self;
  final $Res Function(BotMeta) _then;

/// Create a copy of BotMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = freezed,Object? title = freezed,Object? description = freezed,Object? image = freezed,Object? shape = freezed,Object? group = freezed,Object? hidden = null,}) {
  return _then(BotMeta(
color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,shape: freezed == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BotMeta].
extension BotMetaPatterns on BotMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotMeta value)  $default,){
final _that = this;
switch (_that) {
case _BotMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotMeta value)?  $default,){
final _that = this;
switch (_that) {
case _BotMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseStringOrNull()  String? color, @LooseStringOrNull()  String? title, @LooseStringOrNull()  String? description, @LooseStringOrNull()  String? image, @LooseStringOrNull()  String? shape, @LooseStringOrNull()  String? group, @LooseBool()  bool hidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotMeta() when $default != null:
return $default(_that.color,_that.title,_that.description,_that.image,_that.shape,_that.group,_that.hidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseStringOrNull()  String? color, @LooseStringOrNull()  String? title, @LooseStringOrNull()  String? description, @LooseStringOrNull()  String? image, @LooseStringOrNull()  String? shape, @LooseStringOrNull()  String? group, @LooseBool()  bool hidden)  $default,) {final _that = this;
switch (_that) {
case _BotMeta():
return $default(_that.color,_that.title,_that.description,_that.image,_that.shape,_that.group,_that.hidden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseStringOrNull()  String? color, @LooseStringOrNull()  String? title, @LooseStringOrNull()  String? description, @LooseStringOrNull()  String? image, @LooseStringOrNull()  String? shape, @LooseStringOrNull()  String? group, @LooseBool()  bool hidden)?  $default,) {final _that = this;
switch (_that) {
case _BotMeta() when $default != null:
return $default(_that.color,_that.title,_that.description,_that.image,_that.shape,_that.group,_that.hidden);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotMeta implements BotMeta {
  const _BotMeta({@LooseStringOrNull() this.color, @LooseStringOrNull() this.title, @LooseStringOrNull() this.description, @LooseStringOrNull() this.image, @LooseStringOrNull() this.shape, @LooseStringOrNull() this.group, @LooseBool() this.hidden = false});
  factory _BotMeta.fromJson(Map<String, dynamic> json) => _$BotMetaFromJson(json);

@override@LooseStringOrNull() final  String? color;
@override@LooseStringOrNull() final  String? title;
@override@LooseStringOrNull() final  String? description;
@override@LooseStringOrNull() final  String? image;
@override@LooseStringOrNull() final  String? shape;
@override@LooseStringOrNull() final  String? group;
@override@JsonKey()@LooseBool() final  bool hidden;

/// Create a copy of BotMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotMetaCopyWith<_BotMeta> get copyWith => __$BotMetaCopyWithImpl<_BotMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotMetaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotMeta&&(identical(other.color, color) || other.color == color)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.group, group) || other.group == group)&&(identical(other.hidden, hidden) || other.hidden == hidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,color,title,description,image,shape,group,hidden);
}

@override
String toString() {
    return 'BotMeta(color: $color, title: $title, description: $description, image: $image, shape: $shape, group: $group, hidden: $hidden)';
}


}

/// @nodoc
abstract mixin class _$BotMetaCopyWith<$Res> implements $BotMetaCopyWith<$Res> {
  factory _$BotMetaCopyWith(_BotMeta value, $Res Function(_BotMeta) _then) = __$BotMetaCopyWithImpl;
@override @useResult
$Res call({
@LooseStringOrNull() String? color,@LooseStringOrNull() String? title,@LooseStringOrNull() String? description,@LooseStringOrNull() String? image,@LooseStringOrNull() String? shape,@LooseStringOrNull() String? group,@LooseBool() bool hidden
});




}
/// @nodoc
class __$BotMetaCopyWithImpl<$Res>
    implements _$BotMetaCopyWith<$Res> {
  __$BotMetaCopyWithImpl(this._self, this._then);

  final _BotMeta _self;
  final $Res Function(_BotMeta) _then;

/// Create a copy of BotMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = freezed,Object? title = freezed,Object? description = freezed,Object? image = freezed,Object? shape = freezed,Object? group = freezed,Object? hidden = null,}) {
  return _then(_BotMeta(
color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,shape: freezed == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
