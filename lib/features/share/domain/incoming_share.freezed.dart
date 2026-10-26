// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'incoming_share.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IncomingShare {

 String get id; List<LocalAttachment> get files; String get text; String? get profile;/// Files the phone left out of the share (over the size or count caps).
 int get skipped;
/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomingShareCopyWith<IncomingShare> get copyWith => _$IncomingShareCopyWithImpl<IncomingShare>(this as IncomingShare, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IncomingShare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingShare&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.files, _this.files)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.skipped, _this.skipped) || other.skipped == _this.skipped));
}


@override
int get hashCode {
  final _this = this as IncomingShare;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.files),_this.text,_this.profile,_this.skipped);
}

@override
String toString() {
  final _this = this as IncomingShare;
  return 'IncomingShare(id: ${_this.id}, files: ${_this.files}, text: ${_this.text}, profile: ${_this.profile}, skipped: ${_this.skipped})';
}


}

/// @nodoc
abstract mixin class $IncomingShareCopyWith<$Res>  {
  factory $IncomingShareCopyWith(IncomingShare value, $Res Function(IncomingShare) _then) = _$IncomingShareCopyWithImpl;
@useResult
$Res call({
 String id, List<LocalAttachment> files, String text, String? profile, int skipped
});




}
/// @nodoc
class _$IncomingShareCopyWithImpl<$Res>
    implements $IncomingShareCopyWith<$Res> {
  _$IncomingShareCopyWithImpl(this._self, this._then);

  final IncomingShare _self;
  final $Res Function(IncomingShare) _then;

/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? files = null,Object? text = null,Object? profile = freezed,Object? skipped = null,}) {
  return _then(IncomingShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<LocalAttachment>,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [IncomingShare].
extension IncomingSharePatterns on IncomingShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IncomingShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IncomingShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IncomingShare value)  $default,){
final _that = this;
switch (_that) {
case _IncomingShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IncomingShare value)?  $default,){
final _that = this;
switch (_that) {
case _IncomingShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<LocalAttachment> files,  String text,  String? profile,  int skipped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IncomingShare() when $default != null:
return $default(_that.id,_that.files,_that.text,_that.profile,_that.skipped);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<LocalAttachment> files,  String text,  String? profile,  int skipped)  $default,) {final _that = this;
switch (_that) {
case _IncomingShare():
return $default(_that.id,_that.files,_that.text,_that.profile,_that.skipped);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<LocalAttachment> files,  String text,  String? profile,  int skipped)?  $default,) {final _that = this;
switch (_that) {
case _IncomingShare() when $default != null:
return $default(_that.id,_that.files,_that.text,_that.profile,_that.skipped);case _:
  return null;

}
}

}

/// @nodoc


class _IncomingShare extends IncomingShare {
  const _IncomingShare({required this.id,  List<LocalAttachment> files = const <LocalAttachment>[], this.text = '', this.profile, this.skipped = 0}): _files = files,super._();
  

@override final  String id;
 final  List<LocalAttachment> _files;
@override@JsonKey() List<LocalAttachment> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override@JsonKey() final  String text;
@override final  String? profile;
/// Files the phone left out of the share (over the size or count caps).
@override@JsonKey() final  int skipped;

/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncomingShareCopyWith<_IncomingShare> get copyWith => __$IncomingShareCopyWithImpl<_IncomingShare>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncomingShare&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.files, _files)&&(identical(other.text, text) || other.text == text)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.skipped, skipped) || other.skipped == skipped));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_files),text,profile,skipped);
}

@override
String toString() {
    return 'IncomingShare(id: $id, files: $files, text: $text, profile: $profile, skipped: $skipped)';
}


}

/// @nodoc
abstract mixin class _$IncomingShareCopyWith<$Res> implements $IncomingShareCopyWith<$Res> {
  factory _$IncomingShareCopyWith(_IncomingShare value, $Res Function(_IncomingShare) _then) = __$IncomingShareCopyWithImpl;
@override @useResult
$Res call({
 String id, List<LocalAttachment> files, String text, String? profile, int skipped
});




}
/// @nodoc
class __$IncomingShareCopyWithImpl<$Res>
    implements _$IncomingShareCopyWith<$Res> {
  __$IncomingShareCopyWithImpl(this._self, this._then);

  final _IncomingShare _self;
  final $Res Function(_IncomingShare) _then;

/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? files = null,Object? text = null,Object? profile = freezed,Object? skipped = null,}) {
  return _then(_IncomingShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<LocalAttachment>,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
