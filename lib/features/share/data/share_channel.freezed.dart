// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_channel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SharedItem {

/// `text`, `file`, `skipped`, or `target`: the bot picked in the share
/// sheet's top row (Android's Direct Share, iOS's share suggestions).
 String get type; String? get text;/// The copy's absolute path, for a `file`.
 String? get path; String? get mime;/// The name the sharing app gave the file.
 String? get name;/// Files left out, for `skipped`.
 int get count;/// The bot's profile, for `target`.
 String? get profile;
/// Create a copy of SharedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedItemCopyWith<SharedItem> get copyWith => _$SharedItemCopyWithImpl<SharedItem>(this as SharedItem, _$identity);

  /// Serializes this SharedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SharedItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedItem&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.mime, _this.mime) || other.mime == _this.mime)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.profile, _this.profile) || other.profile == _this.profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SharedItem;
  return Object.hash(runtimeType,_this.type,_this.text,_this.path,_this.mime,_this.name,_this.count,_this.profile);
}

@override
String toString() {
  final _this = this as SharedItem;
  return 'SharedItem(type: ${_this.type}, text: ${_this.text}, path: ${_this.path}, mime: ${_this.mime}, name: ${_this.name}, count: ${_this.count}, profile: ${_this.profile})';
}


}

/// @nodoc
abstract mixin class $SharedItemCopyWith<$Res>  {
  factory $SharedItemCopyWith(SharedItem value, $Res Function(SharedItem) _then) = _$SharedItemCopyWithImpl;
@useResult
$Res call({
 String type, String? text, String? path, String? mime, String? name, int count, String? profile
});




}
/// @nodoc
class _$SharedItemCopyWithImpl<$Res>
    implements $SharedItemCopyWith<$Res> {
  _$SharedItemCopyWithImpl(this._self, this._then);

  final SharedItem _self;
  final $Res Function(SharedItem) _then;

/// Create a copy of SharedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? text = freezed,Object? path = freezed,Object? mime = freezed,Object? name = freezed,Object? count = null,Object? profile = freezed,}) {
  return _then(SharedItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedItem].
extension SharedItemPatterns on SharedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedItem value)  $default,){
final _that = this;
switch (_that) {
case _SharedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedItem value)?  $default,){
final _that = this;
switch (_that) {
case _SharedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? text,  String? path,  String? mime,  String? name,  int count,  String? profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedItem() when $default != null:
return $default(_that.type,_that.text,_that.path,_that.mime,_that.name,_that.count,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? text,  String? path,  String? mime,  String? name,  int count,  String? profile)  $default,) {final _that = this;
switch (_that) {
case _SharedItem():
return $default(_that.type,_that.text,_that.path,_that.mime,_that.name,_that.count,_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? text,  String? path,  String? mime,  String? name,  int count,  String? profile)?  $default,) {final _that = this;
switch (_that) {
case _SharedItem() when $default != null:
return $default(_that.type,_that.text,_that.path,_that.mime,_that.name,_that.count,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SharedItem extends SharedItem {
  const _SharedItem({required this.type, this.text, this.path, this.mime, this.name, this.count = 0, this.profile}): super._();
  factory _SharedItem.fromJson(Map<String, dynamic> json) => _$SharedItemFromJson(json);

/// `text`, `file`, `skipped`, or `target`: the bot picked in the share
/// sheet's top row (Android's Direct Share, iOS's share suggestions).
@override final  String type;
@override final  String? text;
/// The copy's absolute path, for a `file`.
@override final  String? path;
@override final  String? mime;
/// The name the sharing app gave the file.
@override final  String? name;
/// Files left out, for `skipped`.
@override@JsonKey() final  int count;
/// The bot's profile, for `target`.
@override final  String? profile;

/// Create a copy of SharedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedItemCopyWith<_SharedItem> get copyWith => __$SharedItemCopyWithImpl<_SharedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharedItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedItem&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.path, path) || other.path == path)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,text,path,mime,name,count,profile);
}

@override
String toString() {
    return 'SharedItem(type: $type, text: $text, path: $path, mime: $mime, name: $name, count: $count, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$SharedItemCopyWith<$Res> implements $SharedItemCopyWith<$Res> {
  factory _$SharedItemCopyWith(_SharedItem value, $Res Function(_SharedItem) _then) = __$SharedItemCopyWithImpl;
@override @useResult
$Res call({
 String type, String? text, String? path, String? mime, String? name, int count, String? profile
});




}
/// @nodoc
class __$SharedItemCopyWithImpl<$Res>
    implements _$SharedItemCopyWith<$Res> {
  __$SharedItemCopyWithImpl(this._self, this._then);

  final _SharedItem _self;
  final $Res Function(_SharedItem) _then;

/// Create a copy of SharedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? text = freezed,Object? path = freezed,Object? mime = freezed,Object? name = freezed,Object? count = null,Object? profile = freezed,}) {
  return _then(_SharedItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
