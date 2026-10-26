// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gateway_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GatewayAction {

@LooseBool() bool get ok;@LooseString() String get name;@LooseString() String get error;@LooseString() String get message;@JsonKey(name: 'update_command')@LooseString() String get updateCommand;
/// Create a copy of GatewayAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GatewayActionCopyWith<GatewayAction> get copyWith => _$GatewayActionCopyWithImpl<GatewayAction>(this as GatewayAction, _$identity);

  /// Serializes this GatewayAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GatewayAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GatewayAction&&(identical(other.ok, _this.ok) || other.ok == _this.ok)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.updateCommand, _this.updateCommand) || other.updateCommand == _this.updateCommand));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GatewayAction;
  return Object.hash(runtimeType,_this.ok,_this.name,_this.error,_this.message,_this.updateCommand);
}

@override
String toString() {
  final _this = this as GatewayAction;
  return 'GatewayAction(ok: ${_this.ok}, name: ${_this.name}, error: ${_this.error}, message: ${_this.message}, updateCommand: ${_this.updateCommand})';
}


}

/// @nodoc
abstract mixin class $GatewayActionCopyWith<$Res>  {
  factory $GatewayActionCopyWith(GatewayAction value, $Res Function(GatewayAction) _then) = _$GatewayActionCopyWithImpl;
@useResult
$Res call({
@LooseBool() bool ok,@LooseString() String name,@LooseString() String error,@LooseString() String message,@JsonKey(name: 'update_command')@LooseString() String updateCommand
});




}
/// @nodoc
class _$GatewayActionCopyWithImpl<$Res>
    implements $GatewayActionCopyWith<$Res> {
  _$GatewayActionCopyWithImpl(this._self, this._then);

  final GatewayAction _self;
  final $Res Function(GatewayAction) _then;

/// Create a copy of GatewayAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? name = null,Object? error = null,Object? message = null,Object? updateCommand = null,}) {
  return _then(GatewayAction(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,updateCommand: null == updateCommand ? _self.updateCommand : updateCommand // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GatewayAction].
extension GatewayActionPatterns on GatewayAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GatewayAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GatewayAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GatewayAction value)  $default,){
final _that = this;
switch (_that) {
case _GatewayAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GatewayAction value)?  $default,){
final _that = this;
switch (_that) {
case _GatewayAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseBool()  bool ok, @LooseString()  String name, @LooseString()  String error, @LooseString()  String message, @JsonKey(name: 'update_command')@LooseString()  String updateCommand)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GatewayAction() when $default != null:
return $default(_that.ok,_that.name,_that.error,_that.message,_that.updateCommand);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseBool()  bool ok, @LooseString()  String name, @LooseString()  String error, @LooseString()  String message, @JsonKey(name: 'update_command')@LooseString()  String updateCommand)  $default,) {final _that = this;
switch (_that) {
case _GatewayAction():
return $default(_that.ok,_that.name,_that.error,_that.message,_that.updateCommand);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseBool()  bool ok, @LooseString()  String name, @LooseString()  String error, @LooseString()  String message, @JsonKey(name: 'update_command')@LooseString()  String updateCommand)?  $default,) {final _that = this;
switch (_that) {
case _GatewayAction() when $default != null:
return $default(_that.ok,_that.name,_that.error,_that.message,_that.updateCommand);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GatewayAction extends GatewayAction {
  const _GatewayAction({@LooseBool() this.ok = false, @LooseString() this.name = '', @LooseString() this.error = '', @LooseString() this.message = '', @JsonKey(name: 'update_command')@LooseString() this.updateCommand = ''}): super._();
  factory _GatewayAction.fromJson(Map<String, dynamic> json) => _$GatewayActionFromJson(json);

@override@JsonKey()@LooseBool() final  bool ok;
@override@JsonKey()@LooseString() final  String name;
@override@JsonKey()@LooseString() final  String error;
@override@JsonKey()@LooseString() final  String message;
@override@JsonKey(name: 'update_command')@LooseString() final  String updateCommand;

/// Create a copy of GatewayAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GatewayActionCopyWith<_GatewayAction> get copyWith => __$GatewayActionCopyWithImpl<_GatewayAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GatewayActionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GatewayAction&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.name, name) || other.name == name)&&(identical(other.error, error) || other.error == error)&&(identical(other.message, message) || other.message == message)&&(identical(other.updateCommand, updateCommand) || other.updateCommand == updateCommand));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ok,name,error,message,updateCommand);
}

@override
String toString() {
    return 'GatewayAction(ok: $ok, name: $name, error: $error, message: $message, updateCommand: $updateCommand)';
}


}

/// @nodoc
abstract mixin class _$GatewayActionCopyWith<$Res> implements $GatewayActionCopyWith<$Res> {
  factory _$GatewayActionCopyWith(_GatewayAction value, $Res Function(_GatewayAction) _then) = __$GatewayActionCopyWithImpl;
@override @useResult
$Res call({
@LooseBool() bool ok,@LooseString() String name,@LooseString() String error,@LooseString() String message,@JsonKey(name: 'update_command')@LooseString() String updateCommand
});




}
/// @nodoc
class __$GatewayActionCopyWithImpl<$Res>
    implements _$GatewayActionCopyWith<$Res> {
  __$GatewayActionCopyWithImpl(this._self, this._then);

  final _GatewayAction _self;
  final $Res Function(_GatewayAction) _then;

/// Create a copy of GatewayAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? name = null,Object? error = null,Object? message = null,Object? updateCommand = null,}) {
  return _then(_GatewayAction(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,updateCommand: null == updateCommand ? _self.updateCommand : updateCommand // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ActionStatus {

@LooseString() String get name;@LooseBool() bool get running;/// Null while running, and when nothing of that name ever ran. For an
/// update the gateway derives it from the durable update receipt when
/// its own process table was lost to the restart the update did.
@JsonKey(name: 'exit_code')@LooseIntOrNull() int? get exitCode;@LooseStringList() List<String>? get lines;
/// Create a copy of ActionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionStatusCopyWith<ActionStatus> get copyWith => _$ActionStatusCopyWithImpl<ActionStatus>(this as ActionStatus, _$identity);

  /// Serializes this ActionStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ActionStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionStatus&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.exitCode, _this.exitCode) || other.exitCode == _this.exitCode)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ActionStatus;
  return Object.hash(runtimeType,_this.name,_this.running,_this.exitCode,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as ActionStatus;
  return 'ActionStatus(name: ${_this.name}, running: ${_this.running}, exitCode: ${_this.exitCode}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $ActionStatusCopyWith<$Res>  {
  factory $ActionStatusCopyWith(ActionStatus value, $Res Function(ActionStatus) _then) = _$ActionStatusCopyWithImpl;
@useResult
$Res call({
@LooseString() String name,@LooseBool() bool running,@JsonKey(name: 'exit_code')@LooseIntOrNull() int? exitCode,@LooseStringList() List<String>? lines
});




}
/// @nodoc
class _$ActionStatusCopyWithImpl<$Res>
    implements $ActionStatusCopyWith<$Res> {
  _$ActionStatusCopyWithImpl(this._self, this._then);

  final ActionStatus _self;
  final $Res Function(ActionStatus) _then;

/// Create a copy of ActionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? running = null,Object? exitCode = freezed,Object? lines = freezed,}) {
  return _then(ActionStatus(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,exitCode: freezed == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int?,lines: freezed == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActionStatus].
extension ActionStatusPatterns on ActionStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActionStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActionStatus value)  $default,){
final _that = this;
switch (_that) {
case _ActionStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ActionStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String name, @LooseBool()  bool running, @JsonKey(name: 'exit_code')@LooseIntOrNull()  int? exitCode, @LooseStringList()  List<String>? lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActionStatus() when $default != null:
return $default(_that.name,_that.running,_that.exitCode,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String name, @LooseBool()  bool running, @JsonKey(name: 'exit_code')@LooseIntOrNull()  int? exitCode, @LooseStringList()  List<String>? lines)  $default,) {final _that = this;
switch (_that) {
case _ActionStatus():
return $default(_that.name,_that.running,_that.exitCode,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String name, @LooseBool()  bool running, @JsonKey(name: 'exit_code')@LooseIntOrNull()  int? exitCode, @LooseStringList()  List<String>? lines)?  $default,) {final _that = this;
switch (_that) {
case _ActionStatus() when $default != null:
return $default(_that.name,_that.running,_that.exitCode,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActionStatus extends ActionStatus {
  const _ActionStatus({@LooseString() this.name = '', @LooseBool() this.running = false, @JsonKey(name: 'exit_code')@LooseIntOrNull() this.exitCode, @LooseStringList()  List<String>? lines}): _lines = lines,super._();
  factory _ActionStatus.fromJson(Map<String, dynamic> json) => _$ActionStatusFromJson(json);

@override@JsonKey()@LooseString() final  String name;
@override@JsonKey()@LooseBool() final  bool running;
/// Null while running, and when nothing of that name ever ran. For an
/// update the gateway derives it from the durable update receipt when
/// its own process table was lost to the restart the update did.
@override@JsonKey(name: 'exit_code')@LooseIntOrNull() final  int? exitCode;
 final  List<String>? _lines;
@override@LooseStringList() List<String>? get lines {
  final value = _lines;
  if (value == null) return null;
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ActionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionStatusCopyWith<_ActionStatus> get copyWith => __$ActionStatusCopyWithImpl<_ActionStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActionStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionStatus&&(identical(other.name, name) || other.name == name)&&(identical(other.running, running) || other.running == running)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,running,exitCode,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'ActionStatus(name: $name, running: $running, exitCode: $exitCode, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$ActionStatusCopyWith<$Res> implements $ActionStatusCopyWith<$Res> {
  factory _$ActionStatusCopyWith(_ActionStatus value, $Res Function(_ActionStatus) _then) = __$ActionStatusCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String name,@LooseBool() bool running,@JsonKey(name: 'exit_code')@LooseIntOrNull() int? exitCode,@LooseStringList() List<String>? lines
});




}
/// @nodoc
class __$ActionStatusCopyWithImpl<$Res>
    implements _$ActionStatusCopyWith<$Res> {
  __$ActionStatusCopyWithImpl(this._self, this._then);

  final _ActionStatus _self;
  final $Res Function(_ActionStatus) _then;

/// Create a copy of ActionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? running = null,Object? exitCode = freezed,Object? lines = freezed,}) {
  return _then(_ActionStatus(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,exitCode: freezed == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int?,lines: freezed == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$UpdateCheck {

@JsonKey(name: 'current_version')@LooseString() String get currentVersion;@LooseIntOrNull() int? get behind;@JsonKey(name: 'update_available')@LooseBool() bool get updateAvailable;@JsonKey(name: 'can_apply')@LooseBool() bool get canApply;@JsonKey(name: 'update_command')@LooseString() String get updateCommand;@LooseString() String get message;
/// Create a copy of UpdateCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCheckCopyWith<UpdateCheck> get copyWith => _$UpdateCheckCopyWithImpl<UpdateCheck>(this as UpdateCheck, _$identity);

  /// Serializes this UpdateCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCheck&&(identical(other.currentVersion, _this.currentVersion) || other.currentVersion == _this.currentVersion)&&(identical(other.behind, _this.behind) || other.behind == _this.behind)&&(identical(other.updateAvailable, _this.updateAvailable) || other.updateAvailable == _this.updateAvailable)&&(identical(other.canApply, _this.canApply) || other.canApply == _this.canApply)&&(identical(other.updateCommand, _this.updateCommand) || other.updateCommand == _this.updateCommand)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateCheck;
  return Object.hash(runtimeType,_this.currentVersion,_this.behind,_this.updateAvailable,_this.canApply,_this.updateCommand,_this.message);
}

@override
String toString() {
  final _this = this as UpdateCheck;
  return 'UpdateCheck(currentVersion: ${_this.currentVersion}, behind: ${_this.behind}, updateAvailable: ${_this.updateAvailable}, canApply: ${_this.canApply}, updateCommand: ${_this.updateCommand}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $UpdateCheckCopyWith<$Res>  {
  factory $UpdateCheckCopyWith(UpdateCheck value, $Res Function(UpdateCheck) _then) = _$UpdateCheckCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_version')@LooseString() String currentVersion,@LooseIntOrNull() int? behind,@JsonKey(name: 'update_available')@LooseBool() bool updateAvailable,@JsonKey(name: 'can_apply')@LooseBool() bool canApply,@JsonKey(name: 'update_command')@LooseString() String updateCommand,@LooseString() String message
});




}
/// @nodoc
class _$UpdateCheckCopyWithImpl<$Res>
    implements $UpdateCheckCopyWith<$Res> {
  _$UpdateCheckCopyWithImpl(this._self, this._then);

  final UpdateCheck _self;
  final $Res Function(UpdateCheck) _then;

/// Create a copy of UpdateCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentVersion = null,Object? behind = freezed,Object? updateAvailable = null,Object? canApply = null,Object? updateCommand = null,Object? message = null,}) {
  return _then(UpdateCheck(
currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,behind: freezed == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int?,updateAvailable: null == updateAvailable ? _self.updateAvailable : updateAvailable // ignore: cast_nullable_to_non_nullable
as bool,canApply: null == canApply ? _self.canApply : canApply // ignore: cast_nullable_to_non_nullable
as bool,updateCommand: null == updateCommand ? _self.updateCommand : updateCommand // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateCheck].
extension UpdateCheckPatterns on UpdateCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateCheck value)  $default,){
final _that = this;
switch (_that) {
case _UpdateCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateCheck value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_version')@LooseString()  String currentVersion, @LooseIntOrNull()  int? behind, @JsonKey(name: 'update_available')@LooseBool()  bool updateAvailable, @JsonKey(name: 'can_apply')@LooseBool()  bool canApply, @JsonKey(name: 'update_command')@LooseString()  String updateCommand, @LooseString()  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateCheck() when $default != null:
return $default(_that.currentVersion,_that.behind,_that.updateAvailable,_that.canApply,_that.updateCommand,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_version')@LooseString()  String currentVersion, @LooseIntOrNull()  int? behind, @JsonKey(name: 'update_available')@LooseBool()  bool updateAvailable, @JsonKey(name: 'can_apply')@LooseBool()  bool canApply, @JsonKey(name: 'update_command')@LooseString()  String updateCommand, @LooseString()  String message)  $default,) {final _that = this;
switch (_that) {
case _UpdateCheck():
return $default(_that.currentVersion,_that.behind,_that.updateAvailable,_that.canApply,_that.updateCommand,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_version')@LooseString()  String currentVersion, @LooseIntOrNull()  int? behind, @JsonKey(name: 'update_available')@LooseBool()  bool updateAvailable, @JsonKey(name: 'can_apply')@LooseBool()  bool canApply, @JsonKey(name: 'update_command')@LooseString()  String updateCommand, @LooseString()  String message)?  $default,) {final _that = this;
switch (_that) {
case _UpdateCheck() when $default != null:
return $default(_that.currentVersion,_that.behind,_that.updateAvailable,_that.canApply,_that.updateCommand,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateCheck extends UpdateCheck {
  const _UpdateCheck({@JsonKey(name: 'current_version')@LooseString() this.currentVersion = '', @LooseIntOrNull() this.behind, @JsonKey(name: 'update_available')@LooseBool() this.updateAvailable = false, @JsonKey(name: 'can_apply')@LooseBool() this.canApply = false, @JsonKey(name: 'update_command')@LooseString() this.updateCommand = '', @LooseString() this.message = ''}): super._();
  factory _UpdateCheck.fromJson(Map<String, dynamic> json) => _$UpdateCheckFromJson(json);

@override@JsonKey(name: 'current_version')@LooseString() final  String currentVersion;
@override@LooseIntOrNull() final  int? behind;
@override@JsonKey(name: 'update_available')@LooseBool() final  bool updateAvailable;
@override@JsonKey(name: 'can_apply')@LooseBool() final  bool canApply;
@override@JsonKey(name: 'update_command')@LooseString() final  String updateCommand;
@override@JsonKey()@LooseString() final  String message;

/// Create a copy of UpdateCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCheckCopyWith<_UpdateCheck> get copyWith => __$UpdateCheckCopyWithImpl<_UpdateCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCheck&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.behind, behind) || other.behind == behind)&&(identical(other.updateAvailable, updateAvailable) || other.updateAvailable == updateAvailable)&&(identical(other.canApply, canApply) || other.canApply == canApply)&&(identical(other.updateCommand, updateCommand) || other.updateCommand == updateCommand)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentVersion,behind,updateAvailable,canApply,updateCommand,message);
}

@override
String toString() {
    return 'UpdateCheck(currentVersion: $currentVersion, behind: $behind, updateAvailable: $updateAvailable, canApply: $canApply, updateCommand: $updateCommand, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UpdateCheckCopyWith<$Res> implements $UpdateCheckCopyWith<$Res> {
  factory _$UpdateCheckCopyWith(_UpdateCheck value, $Res Function(_UpdateCheck) _then) = __$UpdateCheckCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_version')@LooseString() String currentVersion,@LooseIntOrNull() int? behind,@JsonKey(name: 'update_available')@LooseBool() bool updateAvailable,@JsonKey(name: 'can_apply')@LooseBool() bool canApply,@JsonKey(name: 'update_command')@LooseString() String updateCommand,@LooseString() String message
});




}
/// @nodoc
class __$UpdateCheckCopyWithImpl<$Res>
    implements _$UpdateCheckCopyWith<$Res> {
  __$UpdateCheckCopyWithImpl(this._self, this._then);

  final _UpdateCheck _self;
  final $Res Function(_UpdateCheck) _then;

/// Create a copy of UpdateCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentVersion = null,Object? behind = freezed,Object? updateAvailable = null,Object? canApply = null,Object? updateCommand = null,Object? message = null,}) {
  return _then(_UpdateCheck(
currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,behind: freezed == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int?,updateAvailable: null == updateAvailable ? _self.updateAvailable : updateAvailable // ignore: cast_nullable_to_non_nullable
as bool,canApply: null == canApply ? _self.canApply : canApply // ignore: cast_nullable_to_non_nullable
as bool,updateCommand: null == updateCommand ? _self.updateCommand : updateCommand // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
