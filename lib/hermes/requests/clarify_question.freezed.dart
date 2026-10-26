// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clarify_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClarifyQuestion {

@LooseString() String get qid;/// Question text. Plain text: the agent may write Markdown-ish prose, but
/// the options belong in [choices], never in here.
@LooseString() String get question;@LooseStringList() List<String>? get choices;@JsonKey(name: 'multi_select')@LooseBool() bool get multiSelect;
/// Create a copy of ClarifyQuestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClarifyQuestionCopyWith<ClarifyQuestion> get copyWith => _$ClarifyQuestionCopyWithImpl<ClarifyQuestion>(this as ClarifyQuestion, _$identity);

  /// Serializes this ClarifyQuestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClarifyQuestion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClarifyQuestion&&(identical(other.qid, _this.qid) || other.qid == _this.qid)&&(identical(other.question, _this.question) || other.question == _this.question)&&const DeepCollectionEquality().equals(other.choices, _this.choices)&&(identical(other.multiSelect, _this.multiSelect) || other.multiSelect == _this.multiSelect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClarifyQuestion;
  return Object.hash(runtimeType,_this.qid,_this.question,const DeepCollectionEquality().hash(_this.choices),_this.multiSelect);
}

@override
String toString() {
  final _this = this as ClarifyQuestion;
  return 'ClarifyQuestion(qid: ${_this.qid}, question: ${_this.question}, choices: ${_this.choices}, multiSelect: ${_this.multiSelect})';
}


}

/// @nodoc
abstract mixin class $ClarifyQuestionCopyWith<$Res>  {
  factory $ClarifyQuestionCopyWith(ClarifyQuestion value, $Res Function(ClarifyQuestion) _then) = _$ClarifyQuestionCopyWithImpl;
@useResult
$Res call({
@LooseString() String qid,@LooseString() String question,@LooseStringList() List<String>? choices,@JsonKey(name: 'multi_select')@LooseBool() bool multiSelect
});




}
/// @nodoc
class _$ClarifyQuestionCopyWithImpl<$Res>
    implements $ClarifyQuestionCopyWith<$Res> {
  _$ClarifyQuestionCopyWithImpl(this._self, this._then);

  final ClarifyQuestion _self;
  final $Res Function(ClarifyQuestion) _then;

/// Create a copy of ClarifyQuestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? qid = null,Object? question = null,Object? choices = freezed,Object? multiSelect = null,}) {
  return _then(ClarifyQuestion(
qid: null == qid ? _self.qid : qid // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,choices: freezed == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<String>?,multiSelect: null == multiSelect ? _self.multiSelect : multiSelect // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClarifyQuestion].
extension ClarifyQuestionPatterns on ClarifyQuestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClarifyQuestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClarifyQuestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClarifyQuestion value)  $default,){
final _that = this;
switch (_that) {
case _ClarifyQuestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClarifyQuestion value)?  $default,){
final _that = this;
switch (_that) {
case _ClarifyQuestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String qid, @LooseString()  String question, @LooseStringList()  List<String>? choices, @JsonKey(name: 'multi_select')@LooseBool()  bool multiSelect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClarifyQuestion() when $default != null:
return $default(_that.qid,_that.question,_that.choices,_that.multiSelect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String qid, @LooseString()  String question, @LooseStringList()  List<String>? choices, @JsonKey(name: 'multi_select')@LooseBool()  bool multiSelect)  $default,) {final _that = this;
switch (_that) {
case _ClarifyQuestion():
return $default(_that.qid,_that.question,_that.choices,_that.multiSelect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String qid, @LooseString()  String question, @LooseStringList()  List<String>? choices, @JsonKey(name: 'multi_select')@LooseBool()  bool multiSelect)?  $default,) {final _that = this;
switch (_that) {
case _ClarifyQuestion() when $default != null:
return $default(_that.qid,_that.question,_that.choices,_that.multiSelect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClarifyQuestion extends ClarifyQuestion {
  const _ClarifyQuestion({@LooseString() this.qid = '', @LooseString() this.question = '', @LooseStringList()  List<String>? choices, @JsonKey(name: 'multi_select')@LooseBool() this.multiSelect = false}): _choices = choices,super._();
  factory _ClarifyQuestion.fromJson(Map<String, dynamic> json) => _$ClarifyQuestionFromJson(json);

@override@JsonKey()@LooseString() final  String qid;
/// Question text. Plain text: the agent may write Markdown-ish prose, but
/// the options belong in [choices], never in here.
@override@JsonKey()@LooseString() final  String question;
 final  List<String>? _choices;
@override@LooseStringList() List<String>? get choices {
  final value = _choices;
  if (value == null) return null;
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'multi_select')@LooseBool() final  bool multiSelect;

/// Create a copy of ClarifyQuestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClarifyQuestionCopyWith<_ClarifyQuestion> get copyWith => __$ClarifyQuestionCopyWithImpl<_ClarifyQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClarifyQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClarifyQuestion&&(identical(other.qid, qid) || other.qid == qid)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other.choices, _choices)&&(identical(other.multiSelect, multiSelect) || other.multiSelect == multiSelect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,qid,question,const DeepCollectionEquality().hash(_choices),multiSelect);
}

@override
String toString() {
    return 'ClarifyQuestion(qid: $qid, question: $question, choices: $choices, multiSelect: $multiSelect)';
}


}

/// @nodoc
abstract mixin class _$ClarifyQuestionCopyWith<$Res> implements $ClarifyQuestionCopyWith<$Res> {
  factory _$ClarifyQuestionCopyWith(_ClarifyQuestion value, $Res Function(_ClarifyQuestion) _then) = __$ClarifyQuestionCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String qid,@LooseString() String question,@LooseStringList() List<String>? choices,@JsonKey(name: 'multi_select')@LooseBool() bool multiSelect
});




}
/// @nodoc
class __$ClarifyQuestionCopyWithImpl<$Res>
    implements _$ClarifyQuestionCopyWith<$Res> {
  __$ClarifyQuestionCopyWithImpl(this._self, this._then);

  final _ClarifyQuestion _self;
  final $Res Function(_ClarifyQuestion) _then;

/// Create a copy of ClarifyQuestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? qid = null,Object? question = null,Object? choices = freezed,Object? multiSelect = null,}) {
  return _then(_ClarifyQuestion(
qid: null == qid ? _self.qid : qid // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,choices: freezed == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<String>?,multiSelect: null == multiSelect ? _self.multiSelect : multiSelect // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
