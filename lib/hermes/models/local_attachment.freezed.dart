// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalAttachment {

@LooseString() String get id;@LooseString() String get path;@LooseString() String get name;@JsonKey(name: 'mime_type')@LooseString() String get mimeType;@JsonKey(name: 'size_bytes')@LooseInt() int get sizeBytes;@JsonKey(unknownEnumValue: AttachmentKind.file) AttachmentKind get kind;@JsonKey(name: 'duration_ms', includeIfNull: false)@DurationMillis() Duration? get duration;@JsonKey(name: 'thumbnail_path', includeIfNull: false) String? get thumbnailPath;
/// Create a copy of LocalAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalAttachmentCopyWith<LocalAttachment> get copyWith => _$LocalAttachmentCopyWithImpl<LocalAttachment>(this as LocalAttachment, _$identity);

  /// Serializes this LocalAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocalAttachment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalAttachment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.mimeType, _this.mimeType) || other.mimeType == _this.mimeType)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.thumbnailPath, _this.thumbnailPath) || other.thumbnailPath == _this.thumbnailPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocalAttachment;
  return Object.hash(runtimeType,_this.id,_this.path,_this.name,_this.mimeType,_this.sizeBytes,_this.kind,_this.duration,_this.thumbnailPath);
}

@override
String toString() {
  final _this = this as LocalAttachment;
  return 'LocalAttachment(id: ${_this.id}, path: ${_this.path}, name: ${_this.name}, mimeType: ${_this.mimeType}, sizeBytes: ${_this.sizeBytes}, kind: ${_this.kind}, duration: ${_this.duration}, thumbnailPath: ${_this.thumbnailPath})';
}


}

/// @nodoc
abstract mixin class $LocalAttachmentCopyWith<$Res>  {
  factory $LocalAttachmentCopyWith(LocalAttachment value, $Res Function(LocalAttachment) _then) = _$LocalAttachmentCopyWithImpl;
@useResult
$Res call({
@LooseString() String id,@LooseString() String path,@LooseString() String name,@JsonKey(name: 'mime_type')@LooseString() String mimeType,@JsonKey(name: 'size_bytes')@LooseInt() int sizeBytes,@JsonKey(unknownEnumValue: AttachmentKind.file) AttachmentKind kind,@JsonKey(name: 'duration_ms', includeIfNull: false)@DurationMillis() Duration? duration,@JsonKey(name: 'thumbnail_path', includeIfNull: false) String? thumbnailPath
});




}
/// @nodoc
class _$LocalAttachmentCopyWithImpl<$Res>
    implements $LocalAttachmentCopyWith<$Res> {
  _$LocalAttachmentCopyWithImpl(this._self, this._then);

  final LocalAttachment _self;
  final $Res Function(LocalAttachment) _then;

/// Create a copy of LocalAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = null,Object? name = null,Object? mimeType = null,Object? sizeBytes = null,Object? kind = null,Object? duration = freezed,Object? thumbnailPath = freezed,}) {
  return _then(LocalAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AttachmentKind,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalAttachment].
extension LocalAttachmentPatterns on LocalAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalAttachment value)  $default,){
final _that = this;
switch (_that) {
case _LocalAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _LocalAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String path, @LooseString()  String name, @JsonKey(name: 'mime_type')@LooseString()  String mimeType, @JsonKey(name: 'size_bytes')@LooseInt()  int sizeBytes, @JsonKey(unknownEnumValue: AttachmentKind.file)  AttachmentKind kind, @JsonKey(name: 'duration_ms', includeIfNull: false)@DurationMillis()  Duration? duration, @JsonKey(name: 'thumbnail_path', includeIfNull: false)  String? thumbnailPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalAttachment() when $default != null:
return $default(_that.id,_that.path,_that.name,_that.mimeType,_that.sizeBytes,_that.kind,_that.duration,_that.thumbnailPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String path, @LooseString()  String name, @JsonKey(name: 'mime_type')@LooseString()  String mimeType, @JsonKey(name: 'size_bytes')@LooseInt()  int sizeBytes, @JsonKey(unknownEnumValue: AttachmentKind.file)  AttachmentKind kind, @JsonKey(name: 'duration_ms', includeIfNull: false)@DurationMillis()  Duration? duration, @JsonKey(name: 'thumbnail_path', includeIfNull: false)  String? thumbnailPath)  $default,) {final _that = this;
switch (_that) {
case _LocalAttachment():
return $default(_that.id,_that.path,_that.name,_that.mimeType,_that.sizeBytes,_that.kind,_that.duration,_that.thumbnailPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String id, @LooseString()  String path, @LooseString()  String name, @JsonKey(name: 'mime_type')@LooseString()  String mimeType, @JsonKey(name: 'size_bytes')@LooseInt()  int sizeBytes, @JsonKey(unknownEnumValue: AttachmentKind.file)  AttachmentKind kind, @JsonKey(name: 'duration_ms', includeIfNull: false)@DurationMillis()  Duration? duration, @JsonKey(name: 'thumbnail_path', includeIfNull: false)  String? thumbnailPath)?  $default,) {final _that = this;
switch (_that) {
case _LocalAttachment() when $default != null:
return $default(_that.id,_that.path,_that.name,_that.mimeType,_that.sizeBytes,_that.kind,_that.duration,_that.thumbnailPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalAttachment extends LocalAttachment {
  const _LocalAttachment({@LooseString() required this.id, @LooseString() required this.path, @LooseString() required this.name, @JsonKey(name: 'mime_type')@LooseString() required this.mimeType, @JsonKey(name: 'size_bytes')@LooseInt() required this.sizeBytes, @JsonKey(unknownEnumValue: AttachmentKind.file) this.kind = AttachmentKind.file, @JsonKey(name: 'duration_ms', includeIfNull: false)@DurationMillis() this.duration, @JsonKey(name: 'thumbnail_path', includeIfNull: false) this.thumbnailPath}): super._();
  factory _LocalAttachment.fromJson(Map<String, dynamic> json) => _$LocalAttachmentFromJson(json);

@override@LooseString() final  String id;
@override@LooseString() final  String path;
@override@LooseString() final  String name;
@override@JsonKey(name: 'mime_type')@LooseString() final  String mimeType;
@override@JsonKey(name: 'size_bytes')@LooseInt() final  int sizeBytes;
@override@JsonKey(unknownEnumValue: AttachmentKind.file) final  AttachmentKind kind;
@override@JsonKey(name: 'duration_ms', includeIfNull: false)@DurationMillis() final  Duration? duration;
@override@JsonKey(name: 'thumbnail_path', includeIfNull: false) final  String? thumbnailPath;

/// Create a copy of LocalAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalAttachmentCopyWith<_LocalAttachment> get copyWith => __$LocalAttachmentCopyWithImpl<_LocalAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.thumbnailPath, thumbnailPath) || other.thumbnailPath == thumbnailPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,path,name,mimeType,sizeBytes,kind,duration,thumbnailPath);
}

@override
String toString() {
    return 'LocalAttachment(id: $id, path: $path, name: $name, mimeType: $mimeType, sizeBytes: $sizeBytes, kind: $kind, duration: $duration, thumbnailPath: $thumbnailPath)';
}


}

/// @nodoc
abstract mixin class _$LocalAttachmentCopyWith<$Res> implements $LocalAttachmentCopyWith<$Res> {
  factory _$LocalAttachmentCopyWith(_LocalAttachment value, $Res Function(_LocalAttachment) _then) = __$LocalAttachmentCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String id,@LooseString() String path,@LooseString() String name,@JsonKey(name: 'mime_type')@LooseString() String mimeType,@JsonKey(name: 'size_bytes')@LooseInt() int sizeBytes,@JsonKey(unknownEnumValue: AttachmentKind.file) AttachmentKind kind,@JsonKey(name: 'duration_ms', includeIfNull: false)@DurationMillis() Duration? duration,@JsonKey(name: 'thumbnail_path', includeIfNull: false) String? thumbnailPath
});




}
/// @nodoc
class __$LocalAttachmentCopyWithImpl<$Res>
    implements _$LocalAttachmentCopyWith<$Res> {
  __$LocalAttachmentCopyWithImpl(this._self, this._then);

  final _LocalAttachment _self;
  final $Res Function(_LocalAttachment) _then;

/// Create a copy of LocalAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? name = null,Object? mimeType = null,Object? sizeBytes = null,Object? kind = null,Object? duration = freezed,Object? thumbnailPath = freezed,}) {
  return _then(_LocalAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AttachmentKind,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
