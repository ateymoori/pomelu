// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComposerDraft {

 String get text; List<LocalAttachment> get attachments;
/// Create a copy of ComposerDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposerDraftCopyWith<ComposerDraft> get copyWith => _$ComposerDraftCopyWithImpl<ComposerDraft>(this as ComposerDraft, _$identity);

  /// Serializes this ComposerDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ComposerDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposerDraft&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ComposerDraft;
  return Object.hash(runtimeType,_this.text,const DeepCollectionEquality().hash(_this.attachments));
}

@override
String toString() {
  final _this = this as ComposerDraft;
  return 'ComposerDraft(text: ${_this.text}, attachments: ${_this.attachments})';
}


}

/// @nodoc
abstract mixin class $ComposerDraftCopyWith<$Res>  {
  factory $ComposerDraftCopyWith(ComposerDraft value, $Res Function(ComposerDraft) _then) = _$ComposerDraftCopyWithImpl;
@useResult
$Res call({
 String text, List<LocalAttachment> attachments
});




}
/// @nodoc
class _$ComposerDraftCopyWithImpl<$Res>
    implements $ComposerDraftCopyWith<$Res> {
  _$ComposerDraftCopyWithImpl(this._self, this._then);

  final ComposerDraft _self;
  final $Res Function(ComposerDraft) _then;

/// Create a copy of ComposerDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? attachments = null,}) {
  return _then(ComposerDraft(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<LocalAttachment>,
  ));
}

}


/// Adds pattern-matching-related methods to [ComposerDraft].
extension ComposerDraftPatterns on ComposerDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComposerDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComposerDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComposerDraft value)  $default,){
final _that = this;
switch (_that) {
case _ComposerDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComposerDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ComposerDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<LocalAttachment> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposerDraft() when $default != null:
return $default(_that.text,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<LocalAttachment> attachments)  $default,) {final _that = this;
switch (_that) {
case _ComposerDraft():
return $default(_that.text,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<LocalAttachment> attachments)?  $default,) {final _that = this;
switch (_that) {
case _ComposerDraft() when $default != null:
return $default(_that.text,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComposerDraft extends ComposerDraft {
  const _ComposerDraft({this.text = '',  List<LocalAttachment> attachments = const <LocalAttachment>[]}): _attachments = attachments,super._();
  factory _ComposerDraft.fromJson(Map<String, dynamic> json) => _$ComposerDraftFromJson(json);

@override@JsonKey() final  String text;
 final  List<LocalAttachment> _attachments;
@override@JsonKey() List<LocalAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of ComposerDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposerDraftCopyWith<_ComposerDraft> get copyWith => __$ComposerDraftCopyWithImpl<_ComposerDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComposerDraftToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposerDraft&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.attachments, _attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_attachments));
}

@override
String toString() {
    return 'ComposerDraft(text: $text, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$ComposerDraftCopyWith<$Res> implements $ComposerDraftCopyWith<$Res> {
  factory _$ComposerDraftCopyWith(_ComposerDraft value, $Res Function(_ComposerDraft) _then) = __$ComposerDraftCopyWithImpl;
@override @useResult
$Res call({
 String text, List<LocalAttachment> attachments
});




}
/// @nodoc
class __$ComposerDraftCopyWithImpl<$Res>
    implements _$ComposerDraftCopyWith<$Res> {
  __$ComposerDraftCopyWithImpl(this._self, this._then);

  final _ComposerDraft _self;
  final $Res Function(_ComposerDraft) _then;

/// Create a copy of ComposerDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? attachments = null,}) {
  return _then(_ComposerDraft(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<LocalAttachment>,
  ));
}


}

// dart format on
