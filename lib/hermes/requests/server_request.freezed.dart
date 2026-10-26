// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerRequest {

 String get id; String get sessionId;
/// Create a copy of ServerRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerRequestCopyWith<ServerRequest> get copyWith => _$ServerRequestCopyWithImpl<ServerRequest>(this as ServerRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId));
}


@override
int get hashCode {
  final _this = this as ServerRequest;
  return Object.hash(runtimeType,_this.id,_this.sessionId);
}

@override
String toString() {
  final _this = this as ServerRequest;
  return 'ServerRequest(id: ${_this.id}, sessionId: ${_this.sessionId})';
}


}

/// @nodoc
abstract mixin class $ServerRequestCopyWith<$Res>  {
  factory $ServerRequestCopyWith(ServerRequest value, $Res Function(ServerRequest) _then) = _$ServerRequestCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId
});




}
/// @nodoc
class _$ServerRequestCopyWithImpl<$Res>
    implements $ServerRequestCopyWith<$Res> {
  _$ServerRequestCopyWithImpl(this._self, this._then);

  final ServerRequest _self;
  final $Res Function(ServerRequest) _then;

/// Create a copy of ServerRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerRequest].
extension ServerRequestPatterns on ServerRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ClarifyRequest value)?  clarify,TResult Function( ApprovalRequest value)?  approval,TResult Function( InputRequest value)?  input,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ClarifyRequest() when clarify != null:
return clarify(_that);case ApprovalRequest() when approval != null:
return approval(_that);case InputRequest() when input != null:
return input(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ClarifyRequest value)  clarify,required TResult Function( ApprovalRequest value)  approval,required TResult Function( InputRequest value)  input,}){
final _that = this;
switch (_that) {
case ClarifyRequest():
return clarify(_that);case ApprovalRequest():
return approval(_that);case InputRequest():
return input(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ClarifyRequest value)?  clarify,TResult? Function( ApprovalRequest value)?  approval,TResult? Function( InputRequest value)?  input,}){
final _that = this;
switch (_that) {
case ClarifyRequest() when clarify != null:
return clarify(_that);case ApprovalRequest() when approval != null:
return approval(_that);case InputRequest() when input != null:
return input(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String sessionId,  List<ClarifyQuestion> questions,  Map<String, String?> lockedAnswers)?  clarify,TResult Function( String id,  String sessionId,  String command,  String description,  List<String> choices,  bool smartDenied)?  approval,TResult Function( String id,  String sessionId,  InputKind kind,  String prompt,  String subject)?  input,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ClarifyRequest() when clarify != null:
return clarify(_that.id,_that.sessionId,_that.questions,_that.lockedAnswers);case ApprovalRequest() when approval != null:
return approval(_that.id,_that.sessionId,_that.command,_that.description,_that.choices,_that.smartDenied);case InputRequest() when input != null:
return input(_that.id,_that.sessionId,_that.kind,_that.prompt,_that.subject);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String sessionId,  List<ClarifyQuestion> questions,  Map<String, String?> lockedAnswers)  clarify,required TResult Function( String id,  String sessionId,  String command,  String description,  List<String> choices,  bool smartDenied)  approval,required TResult Function( String id,  String sessionId,  InputKind kind,  String prompt,  String subject)  input,}) {final _that = this;
switch (_that) {
case ClarifyRequest():
return clarify(_that.id,_that.sessionId,_that.questions,_that.lockedAnswers);case ApprovalRequest():
return approval(_that.id,_that.sessionId,_that.command,_that.description,_that.choices,_that.smartDenied);case InputRequest():
return input(_that.id,_that.sessionId,_that.kind,_that.prompt,_that.subject);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String sessionId,  List<ClarifyQuestion> questions,  Map<String, String?> lockedAnswers)?  clarify,TResult? Function( String id,  String sessionId,  String command,  String description,  List<String> choices,  bool smartDenied)?  approval,TResult? Function( String id,  String sessionId,  InputKind kind,  String prompt,  String subject)?  input,}) {final _that = this;
switch (_that) {
case ClarifyRequest() when clarify != null:
return clarify(_that.id,_that.sessionId,_that.questions,_that.lockedAnswers);case ApprovalRequest() when approval != null:
return approval(_that.id,_that.sessionId,_that.command,_that.description,_that.choices,_that.smartDenied);case InputRequest() when input != null:
return input(_that.id,_that.sessionId,_that.kind,_that.prompt,_that.subject);case _:
  return null;

}
}

}

/// @nodoc


class ClarifyRequest extends ServerRequest {
  const ClarifyRequest({required this.id, required this.sessionId, required  List<ClarifyQuestion> questions,  Map<String, String?> lockedAnswers = const <String, String?>{}}): _questions = questions,_lockedAnswers = lockedAnswers,super._();
  

@override final  String id;
@override final  String sessionId;
 final  List<ClarifyQuestion> _questions;
 List<ClarifyQuestion> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

/// Answers the gateway already holds (a reconnect replay): qid → answer,
/// null meaning skipped.
 final  Map<String, String?> _lockedAnswers;
/// Answers the gateway already holds (a reconnect replay): qid → answer,
/// null meaning skipped.
@JsonKey() Map<String, String?> get lockedAnswers {
  if (_lockedAnswers is EqualUnmodifiableMapView) return _lockedAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lockedAnswers);
}


/// Create a copy of ServerRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClarifyRequestCopyWith<ClarifyRequest> get copyWith => _$ClarifyRequestCopyWithImpl<ClarifyRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ClarifyRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other.questions, _questions)&&const DeepCollectionEquality().equals(other.lockedAnswers, _lockedAnswers));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,const DeepCollectionEquality().hash(_questions),const DeepCollectionEquality().hash(_lockedAnswers));
}

@override
String toString() {
    return 'ServerRequest.clarify(id: $id, sessionId: $sessionId, questions: $questions, lockedAnswers: $lockedAnswers)';
}


}

/// @nodoc
abstract mixin class $ClarifyRequestCopyWith<$Res> implements $ServerRequestCopyWith<$Res> {
  factory $ClarifyRequestCopyWith(ClarifyRequest value, $Res Function(ClarifyRequest) _then) = _$ClarifyRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, List<ClarifyQuestion> questions, Map<String, String?> lockedAnswers
});




}
/// @nodoc
class _$ClarifyRequestCopyWithImpl<$Res>
    implements $ClarifyRequestCopyWith<$Res> {
  _$ClarifyRequestCopyWithImpl(this._self, this._then);

  final ClarifyRequest _self;
  final $Res Function(ClarifyRequest) _then;

/// Create a copy of ServerRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? questions = null,Object? lockedAnswers = null,}) {
  return _then(ClarifyRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<ClarifyQuestion>,lockedAnswers: null == lockedAnswers ? _self._lockedAnswers : lockedAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, String?>,
  ));
}


}

/// @nodoc


class ApprovalRequest extends ServerRequest {
  const ApprovalRequest({required this.id, required this.sessionId, this.command = '', this.description = '',  List<String> choices = defaultApprovalChoices, this.smartDenied = false}): _choices = choices,super._();
  

@override final  String id;
@override final  String sessionId;
@JsonKey() final  String command;
@JsonKey() final  String description;
/// The decisions offered, in the gateway's order (`once`, `session`,
/// `always`, `deny`). Never empty.
 final  List<String> _choices;
/// The decisions offered, in the gateway's order (`once`, `session`,
/// `always`, `deny`). Never empty.
@JsonKey() List<String> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

@JsonKey() final  bool smartDenied;

/// Create a copy of ServerRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalRequestCopyWith<ApprovalRequest> get copyWith => _$ApprovalRequestCopyWithImpl<ApprovalRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.command, command) || other.command == command)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.choices, _choices)&&(identical(other.smartDenied, smartDenied) || other.smartDenied == smartDenied));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,command,description,const DeepCollectionEquality().hash(_choices),smartDenied);
}

@override
String toString() {
    return 'ServerRequest.approval(id: $id, sessionId: $sessionId, command: $command, description: $description, choices: $choices, smartDenied: $smartDenied)';
}


}

/// @nodoc
abstract mixin class $ApprovalRequestCopyWith<$Res> implements $ServerRequestCopyWith<$Res> {
  factory $ApprovalRequestCopyWith(ApprovalRequest value, $Res Function(ApprovalRequest) _then) = _$ApprovalRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String command, String description, List<String> choices, bool smartDenied
});




}
/// @nodoc
class _$ApprovalRequestCopyWithImpl<$Res>
    implements $ApprovalRequestCopyWith<$Res> {
  _$ApprovalRequestCopyWithImpl(this._self, this._then);

  final ApprovalRequest _self;
  final $Res Function(ApprovalRequest) _then;

/// Create a copy of ServerRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? command = null,Object? description = null,Object? choices = null,Object? smartDenied = null,}) {
  return _then(ApprovalRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<String>,smartDenied: null == smartDenied ? _self.smartDenied : smartDenied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class InputRequest extends ServerRequest {
  const InputRequest({required this.id, required this.sessionId, required this.kind, this.prompt = '', this.subject = ''}): super._();
  

@override final  String id;
@override final  String sessionId;
 final  InputKind kind;
@JsonKey() final  String prompt;
@JsonKey() final  String subject;

/// Create a copy of ServerRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InputRequestCopyWith<InputRequest> get copyWith => _$InputRequestCopyWithImpl<InputRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InputRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.subject, subject) || other.subject == subject));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,kind,prompt,subject);
}

@override
String toString() {
    return 'ServerRequest.input(id: $id, sessionId: $sessionId, kind: $kind, prompt: $prompt, subject: $subject)';
}


}

/// @nodoc
abstract mixin class $InputRequestCopyWith<$Res> implements $ServerRequestCopyWith<$Res> {
  factory $InputRequestCopyWith(InputRequest value, $Res Function(InputRequest) _then) = _$InputRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, InputKind kind, String prompt, String subject
});




}
/// @nodoc
class _$InputRequestCopyWithImpl<$Res>
    implements $InputRequestCopyWith<$Res> {
  _$InputRequestCopyWithImpl(this._self, this._then);

  final InputRequest _self;
  final $Res Function(InputRequest) _then;

/// Create a copy of ServerRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? kind = null,Object? prompt = null,Object? subject = null,}) {
  return _then(InputRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InputKind,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
