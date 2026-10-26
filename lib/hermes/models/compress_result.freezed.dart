// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compress_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompressResult {

@LooseString() String get status; CompressSummary? get summary;@JsonKey(name: 'lock_held')@LooseBool() bool get lockHeld;@LooseString() String get message;
/// Create a copy of CompressResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompressResultCopyWith<CompressResult> get copyWith => _$CompressResultCopyWithImpl<CompressResult>(this as CompressResult, _$identity);

  /// Serializes this CompressResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CompressResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompressResult&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.lockHeld, _this.lockHeld) || other.lockHeld == _this.lockHeld)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CompressResult;
  return Object.hash(runtimeType,_this.status,_this.summary,_this.lockHeld,_this.message);
}

@override
String toString() {
  final _this = this as CompressResult;
  return 'CompressResult(status: ${_this.status}, summary: ${_this.summary}, lockHeld: ${_this.lockHeld}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $CompressResultCopyWith<$Res>  {
  factory $CompressResultCopyWith(CompressResult value, $Res Function(CompressResult) _then) = _$CompressResultCopyWithImpl;
@useResult
$Res call({
@LooseString() String status, CompressSummary? summary,@JsonKey(name: 'lock_held')@LooseBool() bool lockHeld,@LooseString() String message
});


$CompressSummaryCopyWith<$Res>? get summary;

}
/// @nodoc
class _$CompressResultCopyWithImpl<$Res>
    implements $CompressResultCopyWith<$Res> {
  _$CompressResultCopyWithImpl(this._self, this._then);

  final CompressResult _self;
  final $Res Function(CompressResult) _then;

/// Create a copy of CompressResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? summary = freezed,Object? lockHeld = null,Object? message = null,}) {
  return _then(CompressResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as CompressSummary?,lockHeld: null == lockHeld ? _self.lockHeld : lockHeld // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CompressResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompressSummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $CompressSummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [CompressResult].
extension CompressResultPatterns on CompressResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompressResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompressResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompressResult value)  $default,){
final _that = this;
switch (_that) {
case _CompressResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompressResult value)?  $default,){
final _that = this;
switch (_that) {
case _CompressResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String status,  CompressSummary? summary, @JsonKey(name: 'lock_held')@LooseBool()  bool lockHeld, @LooseString()  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompressResult() when $default != null:
return $default(_that.status,_that.summary,_that.lockHeld,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String status,  CompressSummary? summary, @JsonKey(name: 'lock_held')@LooseBool()  bool lockHeld, @LooseString()  String message)  $default,) {final _that = this;
switch (_that) {
case _CompressResult():
return $default(_that.status,_that.summary,_that.lockHeld,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String status,  CompressSummary? summary, @JsonKey(name: 'lock_held')@LooseBool()  bool lockHeld, @LooseString()  String message)?  $default,) {final _that = this;
switch (_that) {
case _CompressResult() when $default != null:
return $default(_that.status,_that.summary,_that.lockHeld,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompressResult extends CompressResult {
  const _CompressResult({@LooseString() this.status = '', this.summary, @JsonKey(name: 'lock_held')@LooseBool() this.lockHeld = false, @LooseString() this.message = ''}): super._();
  factory _CompressResult.fromJson(Map<String, dynamic> json) => _$CompressResultFromJson(json);

@override@JsonKey()@LooseString() final  String status;
@override final  CompressSummary? summary;
@override@JsonKey(name: 'lock_held')@LooseBool() final  bool lockHeld;
@override@JsonKey()@LooseString() final  String message;

/// Create a copy of CompressResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompressResultCopyWith<_CompressResult> get copyWith => __$CompressResultCopyWithImpl<_CompressResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompressResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompressResult&&(identical(other.status, status) || other.status == status)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.lockHeld, lockHeld) || other.lockHeld == lockHeld)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,summary,lockHeld,message);
}

@override
String toString() {
    return 'CompressResult(status: $status, summary: $summary, lockHeld: $lockHeld, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CompressResultCopyWith<$Res> implements $CompressResultCopyWith<$Res> {
  factory _$CompressResultCopyWith(_CompressResult value, $Res Function(_CompressResult) _then) = __$CompressResultCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String status, CompressSummary? summary,@JsonKey(name: 'lock_held')@LooseBool() bool lockHeld,@LooseString() String message
});


@override $CompressSummaryCopyWith<$Res>? get summary;

}
/// @nodoc
class __$CompressResultCopyWithImpl<$Res>
    implements _$CompressResultCopyWith<$Res> {
  __$CompressResultCopyWithImpl(this._self, this._then);

  final _CompressResult _self;
  final $Res Function(_CompressResult) _then;

/// Create a copy of CompressResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? summary = freezed,Object? lockHeld = null,Object? message = null,}) {
  return _then(_CompressResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as CompressSummary?,lockHeld: null == lockHeld ? _self.lockHeld : lockHeld // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CompressResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompressSummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $CompressSummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// @nodoc
mixin _$CompressSummary {

@LooseString() String get headline;@JsonKey(name: 'token_line')@LooseString() String get tokenLine;@LooseString() String get note;
/// Create a copy of CompressSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompressSummaryCopyWith<CompressSummary> get copyWith => _$CompressSummaryCopyWithImpl<CompressSummary>(this as CompressSummary, _$identity);

  /// Serializes this CompressSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CompressSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompressSummary&&(identical(other.headline, _this.headline) || other.headline == _this.headline)&&(identical(other.tokenLine, _this.tokenLine) || other.tokenLine == _this.tokenLine)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CompressSummary;
  return Object.hash(runtimeType,_this.headline,_this.tokenLine,_this.note);
}

@override
String toString() {
  final _this = this as CompressSummary;
  return 'CompressSummary(headline: ${_this.headline}, tokenLine: ${_this.tokenLine}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CompressSummaryCopyWith<$Res>  {
  factory $CompressSummaryCopyWith(CompressSummary value, $Res Function(CompressSummary) _then) = _$CompressSummaryCopyWithImpl;
@useResult
$Res call({
@LooseString() String headline,@JsonKey(name: 'token_line')@LooseString() String tokenLine,@LooseString() String note
});




}
/// @nodoc
class _$CompressSummaryCopyWithImpl<$Res>
    implements $CompressSummaryCopyWith<$Res> {
  _$CompressSummaryCopyWithImpl(this._self, this._then);

  final CompressSummary _self;
  final $Res Function(CompressSummary) _then;

/// Create a copy of CompressSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headline = null,Object? tokenLine = null,Object? note = null,}) {
  return _then(CompressSummary(
headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,tokenLine: null == tokenLine ? _self.tokenLine : tokenLine // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompressSummary].
extension CompressSummaryPatterns on CompressSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompressSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompressSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompressSummary value)  $default,){
final _that = this;
switch (_that) {
case _CompressSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompressSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CompressSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String headline, @JsonKey(name: 'token_line')@LooseString()  String tokenLine, @LooseString()  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompressSummary() when $default != null:
return $default(_that.headline,_that.tokenLine,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String headline, @JsonKey(name: 'token_line')@LooseString()  String tokenLine, @LooseString()  String note)  $default,) {final _that = this;
switch (_that) {
case _CompressSummary():
return $default(_that.headline,_that.tokenLine,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String headline, @JsonKey(name: 'token_line')@LooseString()  String tokenLine, @LooseString()  String note)?  $default,) {final _that = this;
switch (_that) {
case _CompressSummary() when $default != null:
return $default(_that.headline,_that.tokenLine,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompressSummary implements CompressSummary {
  const _CompressSummary({@LooseString() this.headline = '', @JsonKey(name: 'token_line')@LooseString() this.tokenLine = '', @LooseString() this.note = ''});
  factory _CompressSummary.fromJson(Map<String, dynamic> json) => _$CompressSummaryFromJson(json);

@override@JsonKey()@LooseString() final  String headline;
@override@JsonKey(name: 'token_line')@LooseString() final  String tokenLine;
@override@JsonKey()@LooseString() final  String note;

/// Create a copy of CompressSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompressSummaryCopyWith<_CompressSummary> get copyWith => __$CompressSummaryCopyWithImpl<_CompressSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompressSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompressSummary&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.tokenLine, tokenLine) || other.tokenLine == tokenLine)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,headline,tokenLine,note);
}

@override
String toString() {
    return 'CompressSummary(headline: $headline, tokenLine: $tokenLine, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CompressSummaryCopyWith<$Res> implements $CompressSummaryCopyWith<$Res> {
  factory _$CompressSummaryCopyWith(_CompressSummary value, $Res Function(_CompressSummary) _then) = __$CompressSummaryCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String headline,@JsonKey(name: 'token_line')@LooseString() String tokenLine,@LooseString() String note
});




}
/// @nodoc
class __$CompressSummaryCopyWithImpl<$Res>
    implements _$CompressSummaryCopyWith<$Res> {
  __$CompressSummaryCopyWithImpl(this._self, this._then);

  final _CompressSummary _self;
  final $Res Function(_CompressSummary) _then;

/// Create a copy of CompressSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headline = null,Object? tokenLine = null,Object? note = null,}) {
  return _then(_CompressSummary(
headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,tokenLine: null == tokenLine ? _self.tokenLine : tokenLine // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
