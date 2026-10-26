// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outbox.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutboxEntry {

 String get id; DateTime get createdAt; String get text; List<LocalAttachment> get attachments; OutboxStatus get status;/// An unknown reason (an older app's text) reads as [OutboxFailure.local].
@JsonKey(unknownEnumValue: OutboxFailure.local) OutboxFailure? get error; int get attempts;/// The prompt that went out with `prompt.submit`, so a turn of files alone
/// can be found in the history again.
 String? get sentText;
/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxEntryCopyWith<OutboxEntry> get copyWith => _$OutboxEntryCopyWithImpl<OutboxEntry>(this as OutboxEntry, _$identity);

  /// Serializes this OutboxEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OutboxEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.sentText, _this.sentText) || other.sentText == _this.sentText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OutboxEntry;
  return Object.hash(runtimeType,_this.id,_this.createdAt,_this.text,const DeepCollectionEquality().hash(_this.attachments),_this.status,_this.error,_this.attempts,_this.sentText);
}

@override
String toString() {
  final _this = this as OutboxEntry;
  return 'OutboxEntry(id: ${_this.id}, createdAt: ${_this.createdAt}, text: ${_this.text}, attachments: ${_this.attachments}, status: ${_this.status}, error: ${_this.error}, attempts: ${_this.attempts}, sentText: ${_this.sentText})';
}


}

/// @nodoc
abstract mixin class $OutboxEntryCopyWith<$Res>  {
  factory $OutboxEntryCopyWith(OutboxEntry value, $Res Function(OutboxEntry) _then) = _$OutboxEntryCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, String text, List<LocalAttachment> attachments, OutboxStatus status,@JsonKey(unknownEnumValue: OutboxFailure.local) OutboxFailure? error, int attempts, String? sentText
});




}
/// @nodoc
class _$OutboxEntryCopyWithImpl<$Res>
    implements $OutboxEntryCopyWith<$Res> {
  _$OutboxEntryCopyWithImpl(this._self, this._then);

  final OutboxEntry _self;
  final $Res Function(OutboxEntry) _then;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? text = null,Object? attachments = null,Object? status = null,Object? error = freezed,Object? attempts = null,Object? sentText = freezed,}) {
  return _then(OutboxEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<LocalAttachment>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OutboxStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as OutboxFailure?,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,sentText: freezed == sentText ? _self.sentText : sentText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboxEntry].
extension OutboxEntryPatterns on OutboxEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxEntry value)  $default,){
final _that = this;
switch (_that) {
case _OutboxEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxEntry value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String text,  List<LocalAttachment> attachments,  OutboxStatus status, @JsonKey(unknownEnumValue: OutboxFailure.local)  OutboxFailure? error,  int attempts,  String? sentText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
return $default(_that.id,_that.createdAt,_that.text,_that.attachments,_that.status,_that.error,_that.attempts,_that.sentText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String text,  List<LocalAttachment> attachments,  OutboxStatus status, @JsonKey(unknownEnumValue: OutboxFailure.local)  OutboxFailure? error,  int attempts,  String? sentText)  $default,) {final _that = this;
switch (_that) {
case _OutboxEntry():
return $default(_that.id,_that.createdAt,_that.text,_that.attachments,_that.status,_that.error,_that.attempts,_that.sentText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  String text,  List<LocalAttachment> attachments,  OutboxStatus status, @JsonKey(unknownEnumValue: OutboxFailure.local)  OutboxFailure? error,  int attempts,  String? sentText)?  $default,) {final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
return $default(_that.id,_that.createdAt,_that.text,_that.attachments,_that.status,_that.error,_that.attempts,_that.sentText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboxEntry extends OutboxEntry {
  const _OutboxEntry({required this.id, required this.createdAt, this.text = '',  List<LocalAttachment> attachments = const <LocalAttachment>[], this.status = OutboxStatus.queued, @JsonKey(unknownEnumValue: OutboxFailure.local) this.error, this.attempts = 0, this.sentText}): _attachments = attachments,super._();
  factory _OutboxEntry.fromJson(Map<String, dynamic> json) => _$OutboxEntryFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override@JsonKey() final  String text;
 final  List<LocalAttachment> _attachments;
@override@JsonKey() List<LocalAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override@JsonKey() final  OutboxStatus status;
/// An unknown reason (an older app's text) reads as [OutboxFailure.local].
@override@JsonKey(unknownEnumValue: OutboxFailure.local) final  OutboxFailure? error;
@override@JsonKey() final  int attempts;
/// The prompt that went out with `prompt.submit`, so a turn of files alone
/// can be found in the history again.
@override final  String? sentText;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxEntryCopyWith<_OutboxEntry> get copyWith => __$OutboxEntryCopyWithImpl<_OutboxEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboxEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.attachments, _attachments)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.sentText, sentText) || other.sentText == sentText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,createdAt,text,const DeepCollectionEquality().hash(_attachments),status,error,attempts,sentText);
}

@override
String toString() {
    return 'OutboxEntry(id: $id, createdAt: $createdAt, text: $text, attachments: $attachments, status: $status, error: $error, attempts: $attempts, sentText: $sentText)';
}


}

/// @nodoc
abstract mixin class _$OutboxEntryCopyWith<$Res> implements $OutboxEntryCopyWith<$Res> {
  factory _$OutboxEntryCopyWith(_OutboxEntry value, $Res Function(_OutboxEntry) _then) = __$OutboxEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, String text, List<LocalAttachment> attachments, OutboxStatus status,@JsonKey(unknownEnumValue: OutboxFailure.local) OutboxFailure? error, int attempts, String? sentText
});




}
/// @nodoc
class __$OutboxEntryCopyWithImpl<$Res>
    implements _$OutboxEntryCopyWith<$Res> {
  __$OutboxEntryCopyWithImpl(this._self, this._then);

  final _OutboxEntry _self;
  final $Res Function(_OutboxEntry) _then;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? text = null,Object? attachments = null,Object? status = null,Object? error = freezed,Object? attempts = null,Object? sentText = freezed,}) {
  return _then(_OutboxEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<LocalAttachment>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OutboxStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as OutboxFailure?,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,sentText: freezed == sentText ? _self.sentText : sentText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
