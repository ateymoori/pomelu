// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'context_breakdown.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContextBreakdown {

@JsonKey(fromJson: _categoriesFromJson) List<ContextCategory> get categories;@JsonKey(name: 'context_max')@LooseInt() int get contextMax;@JsonKey(name: 'context_used')@LooseInt() int get contextUsed;@JsonKey(name: 'context_percent')@LooseDouble() double? get contextPercent;@JsonKey(name: 'context_source')@LooseString() String get contextSource;@LooseString() String get model;@JsonKey(name: 'context_files', fromJson: _filesFromJson) List<ContextFile> get contextFiles;
/// Create a copy of ContextBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContextBreakdownCopyWith<ContextBreakdown> get copyWith => _$ContextBreakdownCopyWithImpl<ContextBreakdown>(this as ContextBreakdown, _$identity);

  /// Serializes this ContextBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContextBreakdown;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContextBreakdown&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.contextMax, _this.contextMax) || other.contextMax == _this.contextMax)&&(identical(other.contextUsed, _this.contextUsed) || other.contextUsed == _this.contextUsed)&&(identical(other.contextPercent, _this.contextPercent) || other.contextPercent == _this.contextPercent)&&(identical(other.contextSource, _this.contextSource) || other.contextSource == _this.contextSource)&&(identical(other.model, _this.model) || other.model == _this.model)&&const DeepCollectionEquality().equals(other.contextFiles, _this.contextFiles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContextBreakdown;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.categories),_this.contextMax,_this.contextUsed,_this.contextPercent,_this.contextSource,_this.model,const DeepCollectionEquality().hash(_this.contextFiles));
}

@override
String toString() {
  final _this = this as ContextBreakdown;
  return 'ContextBreakdown(categories: ${_this.categories}, contextMax: ${_this.contextMax}, contextUsed: ${_this.contextUsed}, contextPercent: ${_this.contextPercent}, contextSource: ${_this.contextSource}, model: ${_this.model}, contextFiles: ${_this.contextFiles})';
}


}

/// @nodoc
abstract mixin class $ContextBreakdownCopyWith<$Res>  {
  factory $ContextBreakdownCopyWith(ContextBreakdown value, $Res Function(ContextBreakdown) _then) = _$ContextBreakdownCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _categoriesFromJson) List<ContextCategory> categories,@JsonKey(name: 'context_max')@LooseInt() int contextMax,@JsonKey(name: 'context_used')@LooseInt() int contextUsed,@JsonKey(name: 'context_percent')@LooseDouble() double? contextPercent,@JsonKey(name: 'context_source')@LooseString() String contextSource,@LooseString() String model,@JsonKey(name: 'context_files', fromJson: _filesFromJson) List<ContextFile> contextFiles
});




}
/// @nodoc
class _$ContextBreakdownCopyWithImpl<$Res>
    implements $ContextBreakdownCopyWith<$Res> {
  _$ContextBreakdownCopyWithImpl(this._self, this._then);

  final ContextBreakdown _self;
  final $Res Function(ContextBreakdown) _then;

/// Create a copy of ContextBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? contextMax = null,Object? contextUsed = null,Object? contextPercent = freezed,Object? contextSource = null,Object? model = null,Object? contextFiles = null,}) {
  return _then(ContextBreakdown(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<ContextCategory>,contextMax: null == contextMax ? _self.contextMax : contextMax // ignore: cast_nullable_to_non_nullable
as int,contextUsed: null == contextUsed ? _self.contextUsed : contextUsed // ignore: cast_nullable_to_non_nullable
as int,contextPercent: freezed == contextPercent ? _self.contextPercent : contextPercent // ignore: cast_nullable_to_non_nullable
as double?,contextSource: null == contextSource ? _self.contextSource : contextSource // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,contextFiles: null == contextFiles ? _self.contextFiles : contextFiles // ignore: cast_nullable_to_non_nullable
as List<ContextFile>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContextBreakdown].
extension ContextBreakdownPatterns on ContextBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContextBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContextBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContextBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _ContextBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContextBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _ContextBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _categoriesFromJson)  List<ContextCategory> categories, @JsonKey(name: 'context_max')@LooseInt()  int contextMax, @JsonKey(name: 'context_used')@LooseInt()  int contextUsed, @JsonKey(name: 'context_percent')@LooseDouble()  double? contextPercent, @JsonKey(name: 'context_source')@LooseString()  String contextSource, @LooseString()  String model, @JsonKey(name: 'context_files', fromJson: _filesFromJson)  List<ContextFile> contextFiles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContextBreakdown() when $default != null:
return $default(_that.categories,_that.contextMax,_that.contextUsed,_that.contextPercent,_that.contextSource,_that.model,_that.contextFiles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _categoriesFromJson)  List<ContextCategory> categories, @JsonKey(name: 'context_max')@LooseInt()  int contextMax, @JsonKey(name: 'context_used')@LooseInt()  int contextUsed, @JsonKey(name: 'context_percent')@LooseDouble()  double? contextPercent, @JsonKey(name: 'context_source')@LooseString()  String contextSource, @LooseString()  String model, @JsonKey(name: 'context_files', fromJson: _filesFromJson)  List<ContextFile> contextFiles)  $default,) {final _that = this;
switch (_that) {
case _ContextBreakdown():
return $default(_that.categories,_that.contextMax,_that.contextUsed,_that.contextPercent,_that.contextSource,_that.model,_that.contextFiles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _categoriesFromJson)  List<ContextCategory> categories, @JsonKey(name: 'context_max')@LooseInt()  int contextMax, @JsonKey(name: 'context_used')@LooseInt()  int contextUsed, @JsonKey(name: 'context_percent')@LooseDouble()  double? contextPercent, @JsonKey(name: 'context_source')@LooseString()  String contextSource, @LooseString()  String model, @JsonKey(name: 'context_files', fromJson: _filesFromJson)  List<ContextFile> contextFiles)?  $default,) {final _that = this;
switch (_that) {
case _ContextBreakdown() when $default != null:
return $default(_that.categories,_that.contextMax,_that.contextUsed,_that.contextPercent,_that.contextSource,_that.model,_that.contextFiles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContextBreakdown extends ContextBreakdown {
  const _ContextBreakdown({@JsonKey(fromJson: _categoriesFromJson)  List<ContextCategory> categories = const <ContextCategory>[], @JsonKey(name: 'context_max')@LooseInt() this.contextMax = 0, @JsonKey(name: 'context_used')@LooseInt() this.contextUsed = 0, @JsonKey(name: 'context_percent')@LooseDouble() this.contextPercent, @JsonKey(name: 'context_source')@LooseString() this.contextSource = '', @LooseString() this.model = '', @JsonKey(name: 'context_files', fromJson: _filesFromJson)  List<ContextFile> contextFiles = const <ContextFile>[]}): _categories = categories,_contextFiles = contextFiles,super._();
  factory _ContextBreakdown.fromJson(Map<String, dynamic> json) => _$ContextBreakdownFromJson(json);

 final  List<ContextCategory> _categories;
@override@JsonKey(fromJson: _categoriesFromJson) List<ContextCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey(name: 'context_max')@LooseInt() final  int contextMax;
@override@JsonKey(name: 'context_used')@LooseInt() final  int contextUsed;
@override@JsonKey(name: 'context_percent')@LooseDouble() final  double? contextPercent;
@override@JsonKey(name: 'context_source')@LooseString() final  String contextSource;
@override@JsonKey()@LooseString() final  String model;
 final  List<ContextFile> _contextFiles;
@override@JsonKey(name: 'context_files', fromJson: _filesFromJson) List<ContextFile> get contextFiles {
  if (_contextFiles is EqualUnmodifiableListView) return _contextFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contextFiles);
}


/// Create a copy of ContextBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContextBreakdownCopyWith<_ContextBreakdown> get copyWith => __$ContextBreakdownCopyWithImpl<_ContextBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContextBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContextBreakdown&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.contextMax, contextMax) || other.contextMax == contextMax)&&(identical(other.contextUsed, contextUsed) || other.contextUsed == contextUsed)&&(identical(other.contextPercent, contextPercent) || other.contextPercent == contextPercent)&&(identical(other.contextSource, contextSource) || other.contextSource == contextSource)&&(identical(other.model, model) || other.model == model)&&const DeepCollectionEquality().equals(other.contextFiles, _contextFiles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),contextMax,contextUsed,contextPercent,contextSource,model,const DeepCollectionEquality().hash(_contextFiles));
}

@override
String toString() {
    return 'ContextBreakdown(categories: $categories, contextMax: $contextMax, contextUsed: $contextUsed, contextPercent: $contextPercent, contextSource: $contextSource, model: $model, contextFiles: $contextFiles)';
}


}

/// @nodoc
abstract mixin class _$ContextBreakdownCopyWith<$Res> implements $ContextBreakdownCopyWith<$Res> {
  factory _$ContextBreakdownCopyWith(_ContextBreakdown value, $Res Function(_ContextBreakdown) _then) = __$ContextBreakdownCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _categoriesFromJson) List<ContextCategory> categories,@JsonKey(name: 'context_max')@LooseInt() int contextMax,@JsonKey(name: 'context_used')@LooseInt() int contextUsed,@JsonKey(name: 'context_percent')@LooseDouble() double? contextPercent,@JsonKey(name: 'context_source')@LooseString() String contextSource,@LooseString() String model,@JsonKey(name: 'context_files', fromJson: _filesFromJson) List<ContextFile> contextFiles
});




}
/// @nodoc
class __$ContextBreakdownCopyWithImpl<$Res>
    implements _$ContextBreakdownCopyWith<$Res> {
  __$ContextBreakdownCopyWithImpl(this._self, this._then);

  final _ContextBreakdown _self;
  final $Res Function(_ContextBreakdown) _then;

/// Create a copy of ContextBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? contextMax = null,Object? contextUsed = null,Object? contextPercent = freezed,Object? contextSource = null,Object? model = null,Object? contextFiles = null,}) {
  return _then(_ContextBreakdown(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<ContextCategory>,contextMax: null == contextMax ? _self.contextMax : contextMax // ignore: cast_nullable_to_non_nullable
as int,contextUsed: null == contextUsed ? _self.contextUsed : contextUsed // ignore: cast_nullable_to_non_nullable
as int,contextPercent: freezed == contextPercent ? _self.contextPercent : contextPercent // ignore: cast_nullable_to_non_nullable
as double?,contextSource: null == contextSource ? _self.contextSource : contextSource // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,contextFiles: null == contextFiles ? _self._contextFiles : contextFiles // ignore: cast_nullable_to_non_nullable
as List<ContextFile>,
  ));
}


}


/// @nodoc
mixin _$ContextCategory {

@LooseString() String get id;@LooseString() String get label;@LooseInt() int get tokens;
/// Create a copy of ContextCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContextCategoryCopyWith<ContextCategory> get copyWith => _$ContextCategoryCopyWithImpl<ContextCategory>(this as ContextCategory, _$identity);

  /// Serializes this ContextCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContextCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContextCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.tokens, _this.tokens) || other.tokens == _this.tokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContextCategory;
  return Object.hash(runtimeType,_this.id,_this.label,_this.tokens);
}

@override
String toString() {
  final _this = this as ContextCategory;
  return 'ContextCategory(id: ${_this.id}, label: ${_this.label}, tokens: ${_this.tokens})';
}


}

/// @nodoc
abstract mixin class $ContextCategoryCopyWith<$Res>  {
  factory $ContextCategoryCopyWith(ContextCategory value, $Res Function(ContextCategory) _then) = _$ContextCategoryCopyWithImpl;
@useResult
$Res call({
@LooseString() String id,@LooseString() String label,@LooseInt() int tokens
});




}
/// @nodoc
class _$ContextCategoryCopyWithImpl<$Res>
    implements $ContextCategoryCopyWith<$Res> {
  _$ContextCategoryCopyWithImpl(this._self, this._then);

  final ContextCategory _self;
  final $Res Function(ContextCategory) _then;

/// Create a copy of ContextCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? tokens = null,}) {
  return _then(ContextCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContextCategory].
extension ContextCategoryPatterns on ContextCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContextCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContextCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContextCategory value)  $default,){
final _that = this;
switch (_that) {
case _ContextCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContextCategory value)?  $default,){
final _that = this;
switch (_that) {
case _ContextCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String label, @LooseInt()  int tokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContextCategory() when $default != null:
return $default(_that.id,_that.label,_that.tokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String label, @LooseInt()  int tokens)  $default,) {final _that = this;
switch (_that) {
case _ContextCategory():
return $default(_that.id,_that.label,_that.tokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String id, @LooseString()  String label, @LooseInt()  int tokens)?  $default,) {final _that = this;
switch (_that) {
case _ContextCategory() when $default != null:
return $default(_that.id,_that.label,_that.tokens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContextCategory implements ContextCategory {
  const _ContextCategory({@LooseString() this.id = '', @LooseString() this.label = '', @LooseInt() this.tokens = 0});
  factory _ContextCategory.fromJson(Map<String, dynamic> json) => _$ContextCategoryFromJson(json);

@override@JsonKey()@LooseString() final  String id;
@override@JsonKey()@LooseString() final  String label;
@override@JsonKey()@LooseInt() final  int tokens;

/// Create a copy of ContextCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContextCategoryCopyWith<_ContextCategory> get copyWith => __$ContextCategoryCopyWithImpl<_ContextCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContextCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContextCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.tokens, tokens) || other.tokens == tokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,tokens);
}

@override
String toString() {
    return 'ContextCategory(id: $id, label: $label, tokens: $tokens)';
}


}

/// @nodoc
abstract mixin class _$ContextCategoryCopyWith<$Res> implements $ContextCategoryCopyWith<$Res> {
  factory _$ContextCategoryCopyWith(_ContextCategory value, $Res Function(_ContextCategory) _then) = __$ContextCategoryCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String id,@LooseString() String label,@LooseInt() int tokens
});




}
/// @nodoc
class __$ContextCategoryCopyWithImpl<$Res>
    implements _$ContextCategoryCopyWith<$Res> {
  __$ContextCategoryCopyWithImpl(this._self, this._then);

  final _ContextCategory _self;
  final $Res Function(_ContextCategory) _then;

/// Create a copy of ContextCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? tokens = null,}) {
  return _then(_ContextCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ContextFile {

@LooseString() String get label;@LooseString() String get path;@JsonKey(name: 'est_tokens')@LooseInt() int get tokens;@LooseBool() bool get loaded;/// `loaded`, `truncated`, `flagged`, `shadowed`, `blocked`, `empty`,
/// `unreadable` or `suppressed`.
@LooseString() String get status;
/// Create a copy of ContextFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContextFileCopyWith<ContextFile> get copyWith => _$ContextFileCopyWithImpl<ContextFile>(this as ContextFile, _$identity);

  /// Serializes this ContextFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContextFile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContextFile&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.tokens, _this.tokens) || other.tokens == _this.tokens)&&(identical(other.loaded, _this.loaded) || other.loaded == _this.loaded)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContextFile;
  return Object.hash(runtimeType,_this.label,_this.path,_this.tokens,_this.loaded,_this.status);
}

@override
String toString() {
  final _this = this as ContextFile;
  return 'ContextFile(label: ${_this.label}, path: ${_this.path}, tokens: ${_this.tokens}, loaded: ${_this.loaded}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $ContextFileCopyWith<$Res>  {
  factory $ContextFileCopyWith(ContextFile value, $Res Function(ContextFile) _then) = _$ContextFileCopyWithImpl;
@useResult
$Res call({
@LooseString() String label,@LooseString() String path,@JsonKey(name: 'est_tokens')@LooseInt() int tokens,@LooseBool() bool loaded,@LooseString() String status
});




}
/// @nodoc
class _$ContextFileCopyWithImpl<$Res>
    implements $ContextFileCopyWith<$Res> {
  _$ContextFileCopyWithImpl(this._self, this._then);

  final ContextFile _self;
  final $Res Function(ContextFile) _then;

/// Create a copy of ContextFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? path = null,Object? tokens = null,Object? loaded = null,Object? status = null,}) {
  return _then(ContextFile(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as int,loaded: null == loaded ? _self.loaded : loaded // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContextFile].
extension ContextFilePatterns on ContextFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContextFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContextFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContextFile value)  $default,){
final _that = this;
switch (_that) {
case _ContextFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContextFile value)?  $default,){
final _that = this;
switch (_that) {
case _ContextFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String label, @LooseString()  String path, @JsonKey(name: 'est_tokens')@LooseInt()  int tokens, @LooseBool()  bool loaded, @LooseString()  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContextFile() when $default != null:
return $default(_that.label,_that.path,_that.tokens,_that.loaded,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String label, @LooseString()  String path, @JsonKey(name: 'est_tokens')@LooseInt()  int tokens, @LooseBool()  bool loaded, @LooseString()  String status)  $default,) {final _that = this;
switch (_that) {
case _ContextFile():
return $default(_that.label,_that.path,_that.tokens,_that.loaded,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String label, @LooseString()  String path, @JsonKey(name: 'est_tokens')@LooseInt()  int tokens, @LooseBool()  bool loaded, @LooseString()  String status)?  $default,) {final _that = this;
switch (_that) {
case _ContextFile() when $default != null:
return $default(_that.label,_that.path,_that.tokens,_that.loaded,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContextFile extends ContextFile {
  const _ContextFile({@LooseString() this.label = '', @LooseString() this.path = '', @JsonKey(name: 'est_tokens')@LooseInt() this.tokens = 0, @LooseBool() this.loaded = false, @LooseString() this.status = ''}): super._();
  factory _ContextFile.fromJson(Map<String, dynamic> json) => _$ContextFileFromJson(json);

@override@JsonKey()@LooseString() final  String label;
@override@JsonKey()@LooseString() final  String path;
@override@JsonKey(name: 'est_tokens')@LooseInt() final  int tokens;
@override@JsonKey()@LooseBool() final  bool loaded;
/// `loaded`, `truncated`, `flagged`, `shadowed`, `blocked`, `empty`,
/// `unreadable` or `suppressed`.
@override@JsonKey()@LooseString() final  String status;

/// Create a copy of ContextFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContextFileCopyWith<_ContextFile> get copyWith => __$ContextFileCopyWithImpl<_ContextFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContextFileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContextFile&&(identical(other.label, label) || other.label == label)&&(identical(other.path, path) || other.path == path)&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.loaded, loaded) || other.loaded == loaded)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,path,tokens,loaded,status);
}

@override
String toString() {
    return 'ContextFile(label: $label, path: $path, tokens: $tokens, loaded: $loaded, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ContextFileCopyWith<$Res> implements $ContextFileCopyWith<$Res> {
  factory _$ContextFileCopyWith(_ContextFile value, $Res Function(_ContextFile) _then) = __$ContextFileCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String label,@LooseString() String path,@JsonKey(name: 'est_tokens')@LooseInt() int tokens,@LooseBool() bool loaded,@LooseString() String status
});




}
/// @nodoc
class __$ContextFileCopyWithImpl<$Res>
    implements _$ContextFileCopyWith<$Res> {
  __$ContextFileCopyWithImpl(this._self, this._then);

  final _ContextFile _self;
  final $Res Function(_ContextFile) _then;

/// Create a copy of ContextFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? path = null,Object? tokens = null,Object? loaded = null,Object? status = null,}) {
  return _then(_ContextFile(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as int,loaded: null == loaded ? _self.loaded : loaded // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
