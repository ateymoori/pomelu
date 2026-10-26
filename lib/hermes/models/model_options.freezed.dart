// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModelProvider {

@LooseString() String get slug;@LooseString() String get name;@JsonKey(name: 'is_current')@LooseBool() bool get isCurrent;@LooseBool() bool get authenticated;@JsonKey(fromJson: _stringsFromJson) List<String> get models;@LooseMap() Map<String, dynamic>? get capabilities;
/// Create a copy of ModelProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelProviderCopyWith<ModelProvider> get copyWith => _$ModelProviderCopyWithImpl<ModelProvider>(this as ModelProvider, _$identity);

  /// Serializes this ModelProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ModelProvider;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelProvider&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isCurrent, _this.isCurrent) || other.isCurrent == _this.isCurrent)&&(identical(other.authenticated, _this.authenticated) || other.authenticated == _this.authenticated)&&const DeepCollectionEquality().equals(other.models, _this.models)&&const DeepCollectionEquality().equals(other.capabilities, _this.capabilities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ModelProvider;
  return Object.hash(runtimeType,_this.slug,_this.name,_this.isCurrent,_this.authenticated,const DeepCollectionEquality().hash(_this.models),const DeepCollectionEquality().hash(_this.capabilities));
}

@override
String toString() {
  final _this = this as ModelProvider;
  return 'ModelProvider(slug: ${_this.slug}, name: ${_this.name}, isCurrent: ${_this.isCurrent}, authenticated: ${_this.authenticated}, models: ${_this.models}, capabilities: ${_this.capabilities})';
}


}

/// @nodoc
abstract mixin class $ModelProviderCopyWith<$Res>  {
  factory $ModelProviderCopyWith(ModelProvider value, $Res Function(ModelProvider) _then) = _$ModelProviderCopyWithImpl;
@useResult
$Res call({
@LooseString() String slug,@LooseString() String name,@JsonKey(name: 'is_current')@LooseBool() bool isCurrent,@LooseBool() bool authenticated,@JsonKey(fromJson: _stringsFromJson) List<String> models,@LooseMap() Map<String, dynamic>? capabilities
});




}
/// @nodoc
class _$ModelProviderCopyWithImpl<$Res>
    implements $ModelProviderCopyWith<$Res> {
  _$ModelProviderCopyWithImpl(this._self, this._then);

  final ModelProvider _self;
  final $Res Function(ModelProvider) _then;

/// Create a copy of ModelProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,Object? isCurrent = null,Object? authenticated = null,Object? models = null,Object? capabilities = freezed,}) {
  return _then(ModelProvider(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,authenticated: null == authenticated ? _self.authenticated : authenticated // ignore: cast_nullable_to_non_nullable
as bool,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<String>,capabilities: freezed == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelProvider].
extension ModelProviderPatterns on ModelProvider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelProvider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelProvider value)  $default,){
final _that = this;
switch (_that) {
case _ModelProvider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelProvider value)?  $default,){
final _that = this;
switch (_that) {
case _ModelProvider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String slug, @LooseString()  String name, @JsonKey(name: 'is_current')@LooseBool()  bool isCurrent, @LooseBool()  bool authenticated, @JsonKey(fromJson: _stringsFromJson)  List<String> models, @LooseMap()  Map<String, dynamic>? capabilities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelProvider() when $default != null:
return $default(_that.slug,_that.name,_that.isCurrent,_that.authenticated,_that.models,_that.capabilities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String slug, @LooseString()  String name, @JsonKey(name: 'is_current')@LooseBool()  bool isCurrent, @LooseBool()  bool authenticated, @JsonKey(fromJson: _stringsFromJson)  List<String> models, @LooseMap()  Map<String, dynamic>? capabilities)  $default,) {final _that = this;
switch (_that) {
case _ModelProvider():
return $default(_that.slug,_that.name,_that.isCurrent,_that.authenticated,_that.models,_that.capabilities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String slug, @LooseString()  String name, @JsonKey(name: 'is_current')@LooseBool()  bool isCurrent, @LooseBool()  bool authenticated, @JsonKey(fromJson: _stringsFromJson)  List<String> models, @LooseMap()  Map<String, dynamic>? capabilities)?  $default,) {final _that = this;
switch (_that) {
case _ModelProvider() when $default != null:
return $default(_that.slug,_that.name,_that.isCurrent,_that.authenticated,_that.models,_that.capabilities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelProvider extends ModelProvider {
  const _ModelProvider({@LooseString() this.slug = '', @LooseString() this.name = '', @JsonKey(name: 'is_current')@LooseBool() this.isCurrent = false, @LooseBool() this.authenticated = true, @JsonKey(fromJson: _stringsFromJson)  List<String> models = const <String>[], @LooseMap()  Map<String, dynamic>? capabilities}): _models = models,_capabilities = capabilities,super._();
  factory _ModelProvider.fromJson(Map<String, dynamic> json) => _$ModelProviderFromJson(json);

@override@JsonKey()@LooseString() final  String slug;
@override@JsonKey()@LooseString() final  String name;
@override@JsonKey(name: 'is_current')@LooseBool() final  bool isCurrent;
@override@JsonKey()@LooseBool() final  bool authenticated;
 final  List<String> _models;
@override@JsonKey(fromJson: _stringsFromJson) List<String> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}

 final  Map<String, dynamic>? _capabilities;
@override@LooseMap() Map<String, dynamic>? get capabilities {
  final value = _capabilities;
  if (value == null) return null;
  if (_capabilities is EqualUnmodifiableMapView) return _capabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ModelProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelProviderCopyWith<_ModelProvider> get copyWith => __$ModelProviderCopyWithImpl<_ModelProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelProviderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelProvider&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.authenticated, authenticated) || other.authenticated == authenticated)&&const DeepCollectionEquality().equals(other.models, _models)&&const DeepCollectionEquality().equals(other.capabilities, _capabilities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,slug,name,isCurrent,authenticated,const DeepCollectionEquality().hash(_models),const DeepCollectionEquality().hash(_capabilities));
}

@override
String toString() {
    return 'ModelProvider(slug: $slug, name: $name, isCurrent: $isCurrent, authenticated: $authenticated, models: $models, capabilities: $capabilities)';
}


}

/// @nodoc
abstract mixin class _$ModelProviderCopyWith<$Res> implements $ModelProviderCopyWith<$Res> {
  factory _$ModelProviderCopyWith(_ModelProvider value, $Res Function(_ModelProvider) _then) = __$ModelProviderCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String slug,@LooseString() String name,@JsonKey(name: 'is_current')@LooseBool() bool isCurrent,@LooseBool() bool authenticated,@JsonKey(fromJson: _stringsFromJson) List<String> models,@LooseMap() Map<String, dynamic>? capabilities
});




}
/// @nodoc
class __$ModelProviderCopyWithImpl<$Res>
    implements _$ModelProviderCopyWith<$Res> {
  __$ModelProviderCopyWithImpl(this._self, this._then);

  final _ModelProvider _self;
  final $Res Function(_ModelProvider) _then;

/// Create a copy of ModelProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,Object? isCurrent = null,Object? authenticated = null,Object? models = null,Object? capabilities = freezed,}) {
  return _then(_ModelProvider(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,authenticated: null == authenticated ? _self.authenticated : authenticated // ignore: cast_nullable_to_non_nullable
as bool,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<String>,capabilities: freezed == capabilities ? _self._capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$ModelOptions {

@JsonKey(fromJson: _providersFromJson) List<ModelProvider> get providers;@LooseString() String get model;@LooseString() String get provider;
/// Create a copy of ModelOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelOptionsCopyWith<ModelOptions> get copyWith => _$ModelOptionsCopyWithImpl<ModelOptions>(this as ModelOptions, _$identity);

  /// Serializes this ModelOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ModelOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelOptions&&const DeepCollectionEquality().equals(other.providers, _this.providers)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.provider, _this.provider) || other.provider == _this.provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ModelOptions;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.providers),_this.model,_this.provider);
}

@override
String toString() {
  final _this = this as ModelOptions;
  return 'ModelOptions(providers: ${_this.providers}, model: ${_this.model}, provider: ${_this.provider})';
}


}

/// @nodoc
abstract mixin class $ModelOptionsCopyWith<$Res>  {
  factory $ModelOptionsCopyWith(ModelOptions value, $Res Function(ModelOptions) _then) = _$ModelOptionsCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _providersFromJson) List<ModelProvider> providers,@LooseString() String model,@LooseString() String provider
});




}
/// @nodoc
class _$ModelOptionsCopyWithImpl<$Res>
    implements $ModelOptionsCopyWith<$Res> {
  _$ModelOptionsCopyWithImpl(this._self, this._then);

  final ModelOptions _self;
  final $Res Function(ModelOptions) _then;

/// Create a copy of ModelOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providers = null,Object? model = null,Object? provider = null,}) {
  return _then(ModelOptions(
providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<ModelProvider>,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelOptions].
extension ModelOptionsPatterns on ModelOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelOptions value)  $default,){
final _that = this;
switch (_that) {
case _ModelOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ModelOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _providersFromJson)  List<ModelProvider> providers, @LooseString()  String model, @LooseString()  String provider)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelOptions() when $default != null:
return $default(_that.providers,_that.model,_that.provider);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _providersFromJson)  List<ModelProvider> providers, @LooseString()  String model, @LooseString()  String provider)  $default,) {final _that = this;
switch (_that) {
case _ModelOptions():
return $default(_that.providers,_that.model,_that.provider);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _providersFromJson)  List<ModelProvider> providers, @LooseString()  String model, @LooseString()  String provider)?  $default,) {final _that = this;
switch (_that) {
case _ModelOptions() when $default != null:
return $default(_that.providers,_that.model,_that.provider);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelOptions extends ModelOptions {
  const _ModelOptions({@JsonKey(fromJson: _providersFromJson)  List<ModelProvider> providers = const <ModelProvider>[], @LooseString() this.model = '', @LooseString() this.provider = ''}): _providers = providers,super._();
  factory _ModelOptions.fromJson(Map<String, dynamic> json) => _$ModelOptionsFromJson(json);

 final  List<ModelProvider> _providers;
@override@JsonKey(fromJson: _providersFromJson) List<ModelProvider> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}

@override@JsonKey()@LooseString() final  String model;
@override@JsonKey()@LooseString() final  String provider;

/// Create a copy of ModelOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelOptionsCopyWith<_ModelOptions> get copyWith => __$ModelOptionsCopyWithImpl<_ModelOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelOptions&&const DeepCollectionEquality().equals(other.providers, _providers)&&(identical(other.model, model) || other.model == model)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_providers),model,provider);
}

@override
String toString() {
    return 'ModelOptions(providers: $providers, model: $model, provider: $provider)';
}


}

/// @nodoc
abstract mixin class _$ModelOptionsCopyWith<$Res> implements $ModelOptionsCopyWith<$Res> {
  factory _$ModelOptionsCopyWith(_ModelOptions value, $Res Function(_ModelOptions) _then) = __$ModelOptionsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _providersFromJson) List<ModelProvider> providers,@LooseString() String model,@LooseString() String provider
});




}
/// @nodoc
class __$ModelOptionsCopyWithImpl<$Res>
    implements _$ModelOptionsCopyWith<$Res> {
  __$ModelOptionsCopyWithImpl(this._self, this._then);

  final _ModelOptions _self;
  final $Res Function(_ModelOptions) _then;

/// Create a copy of ModelOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providers = null,Object? model = null,Object? provider = null,}) {
  return _then(_ModelOptions(
providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<ModelProvider>,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
