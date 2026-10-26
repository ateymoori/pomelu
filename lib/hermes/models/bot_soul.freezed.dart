// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_soul.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BotSoul {

@LooseString() String get content;/// False when the bot has no `SOUL.md`; Hermes then uses its own default
/// identity.
@LooseBool() bool get exists;
/// Create a copy of BotSoul
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotSoulCopyWith<BotSoul> get copyWith => _$BotSoulCopyWithImpl<BotSoul>(this as BotSoul, _$identity);

  /// Serializes this BotSoul to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BotSoul;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotSoul&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.exists, _this.exists) || other.exists == _this.exists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BotSoul;
  return Object.hash(runtimeType,_this.content,_this.exists);
}

@override
String toString() {
  final _this = this as BotSoul;
  return 'BotSoul(content: ${_this.content}, exists: ${_this.exists})';
}


}

/// @nodoc
abstract mixin class $BotSoulCopyWith<$Res>  {
  factory $BotSoulCopyWith(BotSoul value, $Res Function(BotSoul) _then) = _$BotSoulCopyWithImpl;
@useResult
$Res call({
@LooseString() String content,@LooseBool() bool exists
});




}
/// @nodoc
class _$BotSoulCopyWithImpl<$Res>
    implements $BotSoulCopyWith<$Res> {
  _$BotSoulCopyWithImpl(this._self, this._then);

  final BotSoul _self;
  final $Res Function(BotSoul) _then;

/// Create a copy of BotSoul
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? exists = null,}) {
  return _then(BotSoul(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,exists: null == exists ? _self.exists : exists // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BotSoul].
extension BotSoulPatterns on BotSoul {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotSoul value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotSoul() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotSoul value)  $default,){
final _that = this;
switch (_that) {
case _BotSoul():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotSoul value)?  $default,){
final _that = this;
switch (_that) {
case _BotSoul() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String content, @LooseBool()  bool exists)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotSoul() when $default != null:
return $default(_that.content,_that.exists);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String content, @LooseBool()  bool exists)  $default,) {final _that = this;
switch (_that) {
case _BotSoul():
return $default(_that.content,_that.exists);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String content, @LooseBool()  bool exists)?  $default,) {final _that = this;
switch (_that) {
case _BotSoul() when $default != null:
return $default(_that.content,_that.exists);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotSoul extends BotSoul {
  const _BotSoul({@LooseString() this.content = '', @LooseBool() this.exists = false}): super._();
  factory _BotSoul.fromJson(Map<String, dynamic> json) => _$BotSoulFromJson(json);

@override@JsonKey()@LooseString() final  String content;
/// False when the bot has no `SOUL.md`; Hermes then uses its own default
/// identity.
@override@JsonKey()@LooseBool() final  bool exists;

/// Create a copy of BotSoul
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotSoulCopyWith<_BotSoul> get copyWith => __$BotSoulCopyWithImpl<_BotSoul>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotSoulToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotSoul&&(identical(other.content, content) || other.content == content)&&(identical(other.exists, exists) || other.exists == exists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,content,exists);
}

@override
String toString() {
    return 'BotSoul(content: $content, exists: $exists)';
}


}

/// @nodoc
abstract mixin class _$BotSoulCopyWith<$Res> implements $BotSoulCopyWith<$Res> {
  factory _$BotSoulCopyWith(_BotSoul value, $Res Function(_BotSoul) _then) = __$BotSoulCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String content,@LooseBool() bool exists
});




}
/// @nodoc
class __$BotSoulCopyWithImpl<$Res>
    implements _$BotSoulCopyWith<$Res> {
  __$BotSoulCopyWithImpl(this._self, this._then);

  final _BotSoul _self;
  final $Res Function(_BotSoul) _then;

/// Create a copy of BotSoul
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? exists = null,}) {
  return _then(_BotSoul(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,exists: null == exists ? _self.exists : exists // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
