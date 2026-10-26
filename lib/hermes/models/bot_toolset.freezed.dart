// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_toolset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BotToolset {

@LooseString() String get name;@LooseString() String get label;@LooseString() String get description;@LooseBool() bool get enabled;@LooseStringList() List<String>? get tools;
/// Create a copy of BotToolset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotToolsetCopyWith<BotToolset> get copyWith => _$BotToolsetCopyWithImpl<BotToolset>(this as BotToolset, _$identity);

  /// Serializes this BotToolset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BotToolset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotToolset&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&const DeepCollectionEquality().equals(other.tools, _this.tools));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BotToolset;
  return Object.hash(runtimeType,_this.name,_this.label,_this.description,_this.enabled,const DeepCollectionEquality().hash(_this.tools));
}

@override
String toString() {
  final _this = this as BotToolset;
  return 'BotToolset(name: ${_this.name}, label: ${_this.label}, description: ${_this.description}, enabled: ${_this.enabled}, tools: ${_this.tools})';
}


}

/// @nodoc
abstract mixin class $BotToolsetCopyWith<$Res>  {
  factory $BotToolsetCopyWith(BotToolset value, $Res Function(BotToolset) _then) = _$BotToolsetCopyWithImpl;
@useResult
$Res call({
@LooseString() String name,@LooseString() String label,@LooseString() String description,@LooseBool() bool enabled,@LooseStringList() List<String>? tools
});




}
/// @nodoc
class _$BotToolsetCopyWithImpl<$Res>
    implements $BotToolsetCopyWith<$Res> {
  _$BotToolsetCopyWithImpl(this._self, this._then);

  final BotToolset _self;
  final $Res Function(BotToolset) _then;

/// Create a copy of BotToolset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? label = null,Object? description = null,Object? enabled = null,Object? tools = freezed,}) {
  return _then(BotToolset(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,tools: freezed == tools ? _self.tools : tools // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [BotToolset].
extension BotToolsetPatterns on BotToolset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotToolset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotToolset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotToolset value)  $default,){
final _that = this;
switch (_that) {
case _BotToolset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotToolset value)?  $default,){
final _that = this;
switch (_that) {
case _BotToolset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String name, @LooseString()  String label, @LooseString()  String description, @LooseBool()  bool enabled, @LooseStringList()  List<String>? tools)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotToolset() when $default != null:
return $default(_that.name,_that.label,_that.description,_that.enabled,_that.tools);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String name, @LooseString()  String label, @LooseString()  String description, @LooseBool()  bool enabled, @LooseStringList()  List<String>? tools)  $default,) {final _that = this;
switch (_that) {
case _BotToolset():
return $default(_that.name,_that.label,_that.description,_that.enabled,_that.tools);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String name, @LooseString()  String label, @LooseString()  String description, @LooseBool()  bool enabled, @LooseStringList()  List<String>? tools)?  $default,) {final _that = this;
switch (_that) {
case _BotToolset() when $default != null:
return $default(_that.name,_that.label,_that.description,_that.enabled,_that.tools);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotToolset extends BotToolset {
  const _BotToolset({@LooseString() this.name = '', @LooseString() this.label = '', @LooseString() this.description = '', @LooseBool() this.enabled = false, @LooseStringList()  List<String>? tools}): _tools = tools,super._();
  factory _BotToolset.fromJson(Map<String, dynamic> json) => _$BotToolsetFromJson(json);

@override@JsonKey()@LooseString() final  String name;
@override@JsonKey()@LooseString() final  String label;
@override@JsonKey()@LooseString() final  String description;
@override@JsonKey()@LooseBool() final  bool enabled;
 final  List<String>? _tools;
@override@LooseStringList() List<String>? get tools {
  final value = _tools;
  if (value == null) return null;
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of BotToolset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotToolsetCopyWith<_BotToolset> get copyWith => __$BotToolsetCopyWithImpl<_BotToolset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotToolsetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotToolset&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other.tools, _tools));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,label,description,enabled,const DeepCollectionEquality().hash(_tools));
}

@override
String toString() {
    return 'BotToolset(name: $name, label: $label, description: $description, enabled: $enabled, tools: $tools)';
}


}

/// @nodoc
abstract mixin class _$BotToolsetCopyWith<$Res> implements $BotToolsetCopyWith<$Res> {
  factory _$BotToolsetCopyWith(_BotToolset value, $Res Function(_BotToolset) _then) = __$BotToolsetCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String name,@LooseString() String label,@LooseString() String description,@LooseBool() bool enabled,@LooseStringList() List<String>? tools
});




}
/// @nodoc
class __$BotToolsetCopyWithImpl<$Res>
    implements _$BotToolsetCopyWith<$Res> {
  __$BotToolsetCopyWithImpl(this._self, this._then);

  final _BotToolset _self;
  final $Res Function(_BotToolset) _then;

/// Create a copy of BotToolset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? label = null,Object? description = null,Object? enabled = null,Object? tools = freezed,}) {
  return _then(_BotToolset(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,tools: freezed == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
