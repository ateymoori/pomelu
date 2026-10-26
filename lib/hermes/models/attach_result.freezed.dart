// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attach_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageAttachResult {

@LooseBool() bool get attached;@LooseString() String get path;@LooseString() String get name;@LooseString() String get text;@LooseInt() int get count;@LooseInt() int get bytes; int? get width; int? get height;
/// Create a copy of ImageAttachResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageAttachResultCopyWith<ImageAttachResult> get copyWith => _$ImageAttachResultCopyWithImpl<ImageAttachResult>(this as ImageAttachResult, _$identity);

  /// Serializes this ImageAttachResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ImageAttachResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageAttachResult&&(identical(other.attached, _this.attached) || other.attached == _this.attached)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.bytes, _this.bytes) || other.bytes == _this.bytes)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ImageAttachResult;
  return Object.hash(runtimeType,_this.attached,_this.path,_this.name,_this.text,_this.count,_this.bytes,_this.width,_this.height);
}

@override
String toString() {
  final _this = this as ImageAttachResult;
  return 'ImageAttachResult(attached: ${_this.attached}, path: ${_this.path}, name: ${_this.name}, text: ${_this.text}, count: ${_this.count}, bytes: ${_this.bytes}, width: ${_this.width}, height: ${_this.height})';
}


}

/// @nodoc
abstract mixin class $ImageAttachResultCopyWith<$Res>  {
  factory $ImageAttachResultCopyWith(ImageAttachResult value, $Res Function(ImageAttachResult) _then) = _$ImageAttachResultCopyWithImpl;
@useResult
$Res call({
@LooseBool() bool attached,@LooseString() String path,@LooseString() String name,@LooseString() String text,@LooseInt() int count,@LooseInt() int bytes, int? width, int? height
});




}
/// @nodoc
class _$ImageAttachResultCopyWithImpl<$Res>
    implements $ImageAttachResultCopyWith<$Res> {
  _$ImageAttachResultCopyWithImpl(this._self, this._then);

  final ImageAttachResult _self;
  final $Res Function(ImageAttachResult) _then;

/// Create a copy of ImageAttachResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attached = null,Object? path = null,Object? name = null,Object? text = null,Object? count = null,Object? bytes = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(ImageAttachResult(
attached: null == attached ? _self.attached : attached // ignore: cast_nullable_to_non_nullable
as bool,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageAttachResult].
extension ImageAttachResultPatterns on ImageAttachResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageAttachResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageAttachResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageAttachResult value)  $default,){
final _that = this;
switch (_that) {
case _ImageAttachResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageAttachResult value)?  $default,){
final _that = this;
switch (_that) {
case _ImageAttachResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseBool()  bool attached, @LooseString()  String path, @LooseString()  String name, @LooseString()  String text, @LooseInt()  int count, @LooseInt()  int bytes,  int? width,  int? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageAttachResult() when $default != null:
return $default(_that.attached,_that.path,_that.name,_that.text,_that.count,_that.bytes,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseBool()  bool attached, @LooseString()  String path, @LooseString()  String name, @LooseString()  String text, @LooseInt()  int count, @LooseInt()  int bytes,  int? width,  int? height)  $default,) {final _that = this;
switch (_that) {
case _ImageAttachResult():
return $default(_that.attached,_that.path,_that.name,_that.text,_that.count,_that.bytes,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseBool()  bool attached, @LooseString()  String path, @LooseString()  String name, @LooseString()  String text, @LooseInt()  int count, @LooseInt()  int bytes,  int? width,  int? height)?  $default,) {final _that = this;
switch (_that) {
case _ImageAttachResult() when $default != null:
return $default(_that.attached,_that.path,_that.name,_that.text,_that.count,_that.bytes,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageAttachResult implements ImageAttachResult {
  const _ImageAttachResult({@LooseBool() this.attached = false, @LooseString() this.path = '', @LooseString() this.name = '', @LooseString() this.text = '', @LooseInt() this.count = 0, @LooseInt() this.bytes = 0, this.width, this.height});
  factory _ImageAttachResult.fromJson(Map<String, dynamic> json) => _$ImageAttachResultFromJson(json);

@override@JsonKey()@LooseBool() final  bool attached;
@override@JsonKey()@LooseString() final  String path;
@override@JsonKey()@LooseString() final  String name;
@override@JsonKey()@LooseString() final  String text;
@override@JsonKey()@LooseInt() final  int count;
@override@JsonKey()@LooseInt() final  int bytes;
@override final  int? width;
@override final  int? height;

/// Create a copy of ImageAttachResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageAttachResultCopyWith<_ImageAttachResult> get copyWith => __$ImageAttachResultCopyWithImpl<_ImageAttachResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageAttachResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageAttachResult&&(identical(other.attached, attached) || other.attached == attached)&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.text, text) || other.text == text)&&(identical(other.count, count) || other.count == count)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,attached,path,name,text,count,bytes,width,height);
}

@override
String toString() {
    return 'ImageAttachResult(attached: $attached, path: $path, name: $name, text: $text, count: $count, bytes: $bytes, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$ImageAttachResultCopyWith<$Res> implements $ImageAttachResultCopyWith<$Res> {
  factory _$ImageAttachResultCopyWith(_ImageAttachResult value, $Res Function(_ImageAttachResult) _then) = __$ImageAttachResultCopyWithImpl;
@override @useResult
$Res call({
@LooseBool() bool attached,@LooseString() String path,@LooseString() String name,@LooseString() String text,@LooseInt() int count,@LooseInt() int bytes, int? width, int? height
});




}
/// @nodoc
class __$ImageAttachResultCopyWithImpl<$Res>
    implements _$ImageAttachResultCopyWith<$Res> {
  __$ImageAttachResultCopyWithImpl(this._self, this._then);

  final _ImageAttachResult _self;
  final $Res Function(_ImageAttachResult) _then;

/// Create a copy of ImageAttachResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attached = null,Object? path = null,Object? name = null,Object? text = null,Object? count = null,Object? bytes = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(_ImageAttachResult(
attached: null == attached ? _self.attached : attached // ignore: cast_nullable_to_non_nullable
as bool,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$FileAttachResult {

@LooseString() String get name;@LooseString() String get path;@JsonKey(name: 'ref_text')@LooseString() String get refText;
/// Create a copy of FileAttachResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileAttachResultCopyWith<FileAttachResult> get copyWith => _$FileAttachResultCopyWithImpl<FileAttachResult>(this as FileAttachResult, _$identity);

  /// Serializes this FileAttachResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FileAttachResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileAttachResult&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.refText, _this.refText) || other.refText == _this.refText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FileAttachResult;
  return Object.hash(runtimeType,_this.name,_this.path,_this.refText);
}

@override
String toString() {
  final _this = this as FileAttachResult;
  return 'FileAttachResult(name: ${_this.name}, path: ${_this.path}, refText: ${_this.refText})';
}


}

/// @nodoc
abstract mixin class $FileAttachResultCopyWith<$Res>  {
  factory $FileAttachResultCopyWith(FileAttachResult value, $Res Function(FileAttachResult) _then) = _$FileAttachResultCopyWithImpl;
@useResult
$Res call({
@LooseString() String name,@LooseString() String path,@JsonKey(name: 'ref_text')@LooseString() String refText
});




}
/// @nodoc
class _$FileAttachResultCopyWithImpl<$Res>
    implements $FileAttachResultCopyWith<$Res> {
  _$FileAttachResultCopyWithImpl(this._self, this._then);

  final FileAttachResult _self;
  final $Res Function(FileAttachResult) _then;

/// Create a copy of FileAttachResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? refText = null,}) {
  return _then(FileAttachResult(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,refText: null == refText ? _self.refText : refText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FileAttachResult].
extension FileAttachResultPatterns on FileAttachResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileAttachResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileAttachResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileAttachResult value)  $default,){
final _that = this;
switch (_that) {
case _FileAttachResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileAttachResult value)?  $default,){
final _that = this;
switch (_that) {
case _FileAttachResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String name, @LooseString()  String path, @JsonKey(name: 'ref_text')@LooseString()  String refText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileAttachResult() when $default != null:
return $default(_that.name,_that.path,_that.refText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String name, @LooseString()  String path, @JsonKey(name: 'ref_text')@LooseString()  String refText)  $default,) {final _that = this;
switch (_that) {
case _FileAttachResult():
return $default(_that.name,_that.path,_that.refText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String name, @LooseString()  String path, @JsonKey(name: 'ref_text')@LooseString()  String refText)?  $default,) {final _that = this;
switch (_that) {
case _FileAttachResult() when $default != null:
return $default(_that.name,_that.path,_that.refText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FileAttachResult implements FileAttachResult {
  const _FileAttachResult({@LooseString() this.name = '', @LooseString() this.path = '', @JsonKey(name: 'ref_text')@LooseString() this.refText = ''});
  factory _FileAttachResult.fromJson(Map<String, dynamic> json) => _$FileAttachResultFromJson(json);

@override@JsonKey()@LooseString() final  String name;
@override@JsonKey()@LooseString() final  String path;
@override@JsonKey(name: 'ref_text')@LooseString() final  String refText;

/// Create a copy of FileAttachResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileAttachResultCopyWith<_FileAttachResult> get copyWith => __$FileAttachResultCopyWithImpl<_FileAttachResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FileAttachResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileAttachResult&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.refText, refText) || other.refText == refText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,path,refText);
}

@override
String toString() {
    return 'FileAttachResult(name: $name, path: $path, refText: $refText)';
}


}

/// @nodoc
abstract mixin class _$FileAttachResultCopyWith<$Res> implements $FileAttachResultCopyWith<$Res> {
  factory _$FileAttachResultCopyWith(_FileAttachResult value, $Res Function(_FileAttachResult) _then) = __$FileAttachResultCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String name,@LooseString() String path,@JsonKey(name: 'ref_text')@LooseString() String refText
});




}
/// @nodoc
class __$FileAttachResultCopyWithImpl<$Res>
    implements _$FileAttachResultCopyWith<$Res> {
  __$FileAttachResultCopyWithImpl(this._self, this._then);

  final _FileAttachResult _self;
  final $Res Function(_FileAttachResult) _then;

/// Create a copy of FileAttachResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? refText = null,}) {
  return _then(_FileAttachResult(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,refText: null == refText ? _self.refText : refText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
