// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_skill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BotSkill {

@LooseString() String get name;@LooseString() String get description;@LooseString() String get category;@LooseBool() bool get enabled;
/// Create a copy of BotSkill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotSkillCopyWith<BotSkill> get copyWith => _$BotSkillCopyWithImpl<BotSkill>(this as BotSkill, _$identity);

  /// Serializes this BotSkill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BotSkill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotSkill&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BotSkill;
  return Object.hash(runtimeType,_this.name,_this.description,_this.category,_this.enabled);
}

@override
String toString() {
  final _this = this as BotSkill;
  return 'BotSkill(name: ${_this.name}, description: ${_this.description}, category: ${_this.category}, enabled: ${_this.enabled})';
}


}

/// @nodoc
abstract mixin class $BotSkillCopyWith<$Res>  {
  factory $BotSkillCopyWith(BotSkill value, $Res Function(BotSkill) _then) = _$BotSkillCopyWithImpl;
@useResult
$Res call({
@LooseString() String name,@LooseString() String description,@LooseString() String category,@LooseBool() bool enabled
});




}
/// @nodoc
class _$BotSkillCopyWithImpl<$Res>
    implements $BotSkillCopyWith<$Res> {
  _$BotSkillCopyWithImpl(this._self, this._then);

  final BotSkill _self;
  final $Res Function(BotSkill) _then;

/// Create a copy of BotSkill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? category = null,Object? enabled = null,}) {
  return _then(BotSkill(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BotSkill].
extension BotSkillPatterns on BotSkill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotSkill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotSkill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotSkill value)  $default,){
final _that = this;
switch (_that) {
case _BotSkill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotSkill value)?  $default,){
final _that = this;
switch (_that) {
case _BotSkill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String name, @LooseString()  String description, @LooseString()  String category, @LooseBool()  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotSkill() when $default != null:
return $default(_that.name,_that.description,_that.category,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String name, @LooseString()  String description, @LooseString()  String category, @LooseBool()  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _BotSkill():
return $default(_that.name,_that.description,_that.category,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String name, @LooseString()  String description, @LooseString()  String category, @LooseBool()  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _BotSkill() when $default != null:
return $default(_that.name,_that.description,_that.category,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotSkill implements BotSkill {
  const _BotSkill({@LooseString() this.name = '', @LooseString() this.description = '', @LooseString() this.category = '', @LooseBool() this.enabled = true});
  factory _BotSkill.fromJson(Map<String, dynamic> json) => _$BotSkillFromJson(json);

@override@JsonKey()@LooseString() final  String name;
@override@JsonKey()@LooseString() final  String description;
@override@JsonKey()@LooseString() final  String category;
@override@JsonKey()@LooseBool() final  bool enabled;

/// Create a copy of BotSkill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotSkillCopyWith<_BotSkill> get copyWith => __$BotSkillCopyWithImpl<_BotSkill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotSkillToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotSkill&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,description,category,enabled);
}

@override
String toString() {
    return 'BotSkill(name: $name, description: $description, category: $category, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$BotSkillCopyWith<$Res> implements $BotSkillCopyWith<$Res> {
  factory _$BotSkillCopyWith(_BotSkill value, $Res Function(_BotSkill) _then) = __$BotSkillCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String name,@LooseString() String description,@LooseString() String category,@LooseBool() bool enabled
});




}
/// @nodoc
class __$BotSkillCopyWithImpl<$Res>
    implements _$BotSkillCopyWith<$Res> {
  __$BotSkillCopyWithImpl(this._self, this._then);

  final _BotSkill _self;
  final $Res Function(_BotSkill) _then;

/// Create a copy of BotSkill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? category = null,Object? enabled = null,}) {
  return _then(_BotSkill(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
