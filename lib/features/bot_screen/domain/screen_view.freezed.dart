// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'screen_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScreenView {

 ScreenStream get stream;/// This page's viewer, as a lease names its holder.
 String? get viewerHash; ScreenTask? get task; HermesFailure? get failure;/// The view is closer than the whole desktop.
 bool get zoomed;/// The whole desktop shows in a window it could fill (a tall one).
 bool get canFill; ScreenDrag get drag; ScreenNotice? get notice;
/// Create a copy of ScreenView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScreenViewCopyWith<ScreenView> get copyWith => _$ScreenViewCopyWithImpl<ScreenView>(this as ScreenView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ScreenView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScreenView&&(identical(other.stream, _this.stream) || other.stream == _this.stream)&&(identical(other.viewerHash, _this.viewerHash) || other.viewerHash == _this.viewerHash)&&(identical(other.task, _this.task) || other.task == _this.task)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.zoomed, _this.zoomed) || other.zoomed == _this.zoomed)&&(identical(other.canFill, _this.canFill) || other.canFill == _this.canFill)&&(identical(other.drag, _this.drag) || other.drag == _this.drag)&&(identical(other.notice, _this.notice) || other.notice == _this.notice));
}


@override
int get hashCode {
  final _this = this as ScreenView;
  return Object.hash(runtimeType,_this.stream,_this.viewerHash,_this.task,_this.failure,_this.zoomed,_this.canFill,_this.drag,_this.notice);
}

@override
String toString() {
  final _this = this as ScreenView;
  return 'ScreenView(stream: ${_this.stream}, viewerHash: ${_this.viewerHash}, task: ${_this.task}, failure: ${_this.failure}, zoomed: ${_this.zoomed}, canFill: ${_this.canFill}, drag: ${_this.drag}, notice: ${_this.notice})';
}


}

/// @nodoc
abstract mixin class $ScreenViewCopyWith<$Res>  {
  factory $ScreenViewCopyWith(ScreenView value, $Res Function(ScreenView) _then) = _$ScreenViewCopyWithImpl;
@useResult
$Res call({
 ScreenStream stream, String? viewerHash, ScreenTask? task, HermesFailure? failure, bool zoomed, bool canFill, ScreenDrag drag, ScreenNotice? notice
});




}
/// @nodoc
class _$ScreenViewCopyWithImpl<$Res>
    implements $ScreenViewCopyWith<$Res> {
  _$ScreenViewCopyWithImpl(this._self, this._then);

  final ScreenView _self;
  final $Res Function(ScreenView) _then;

/// Create a copy of ScreenView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stream = null,Object? viewerHash = freezed,Object? task = freezed,Object? failure = freezed,Object? zoomed = null,Object? canFill = null,Object? drag = null,Object? notice = freezed,}) {
  return _then(ScreenView(
stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as ScreenStream,viewerHash: freezed == viewerHash ? _self.viewerHash : viewerHash // ignore: cast_nullable_to_non_nullable
as String?,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as ScreenTask?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HermesFailure?,zoomed: null == zoomed ? _self.zoomed : zoomed // ignore: cast_nullable_to_non_nullable
as bool,canFill: null == canFill ? _self.canFill : canFill // ignore: cast_nullable_to_non_nullable
as bool,drag: null == drag ? _self.drag : drag // ignore: cast_nullable_to_non_nullable
as ScreenDrag,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as ScreenNotice?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScreenView].
extension ScreenViewPatterns on ScreenView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScreenView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScreenView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScreenView value)  $default,){
final _that = this;
switch (_that) {
case _ScreenView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScreenView value)?  $default,){
final _that = this;
switch (_that) {
case _ScreenView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScreenStream stream,  String? viewerHash,  ScreenTask? task,  HermesFailure? failure,  bool zoomed,  bool canFill,  ScreenDrag drag,  ScreenNotice? notice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScreenView() when $default != null:
return $default(_that.stream,_that.viewerHash,_that.task,_that.failure,_that.zoomed,_that.canFill,_that.drag,_that.notice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScreenStream stream,  String? viewerHash,  ScreenTask? task,  HermesFailure? failure,  bool zoomed,  bool canFill,  ScreenDrag drag,  ScreenNotice? notice)  $default,) {final _that = this;
switch (_that) {
case _ScreenView():
return $default(_that.stream,_that.viewerHash,_that.task,_that.failure,_that.zoomed,_that.canFill,_that.drag,_that.notice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScreenStream stream,  String? viewerHash,  ScreenTask? task,  HermesFailure? failure,  bool zoomed,  bool canFill,  ScreenDrag drag,  ScreenNotice? notice)?  $default,) {final _that = this;
switch (_that) {
case _ScreenView() when $default != null:
return $default(_that.stream,_that.viewerHash,_that.task,_that.failure,_that.zoomed,_that.canFill,_that.drag,_that.notice);case _:
  return null;

}
}

}

/// @nodoc


class _ScreenView extends ScreenView {
  const _ScreenView({this.stream = ScreenStream.idle, this.viewerHash, this.task, this.failure, this.zoomed = false, this.canFill = false, this.drag = ScreenDrag.off, this.notice}): super._();
  

@override@JsonKey() final  ScreenStream stream;
/// This page's viewer, as a lease names its holder.
@override final  String? viewerHash;
@override final  ScreenTask? task;
@override final  HermesFailure? failure;
/// The view is closer than the whole desktop.
@override@JsonKey() final  bool zoomed;
/// The whole desktop shows in a window it could fill (a tall one).
@override@JsonKey() final  bool canFill;
@override@JsonKey() final  ScreenDrag drag;
@override final  ScreenNotice? notice;

/// Create a copy of ScreenView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScreenViewCopyWith<_ScreenView> get copyWith => __$ScreenViewCopyWithImpl<_ScreenView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScreenView&&(identical(other.stream, stream) || other.stream == stream)&&(identical(other.viewerHash, viewerHash) || other.viewerHash == viewerHash)&&(identical(other.task, task) || other.task == task)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.zoomed, zoomed) || other.zoomed == zoomed)&&(identical(other.canFill, canFill) || other.canFill == canFill)&&(identical(other.drag, drag) || other.drag == drag)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stream,viewerHash,task,failure,zoomed,canFill,drag,notice);
}

@override
String toString() {
    return 'ScreenView(stream: $stream, viewerHash: $viewerHash, task: $task, failure: $failure, zoomed: $zoomed, canFill: $canFill, drag: $drag, notice: $notice)';
}


}

/// @nodoc
abstract mixin class _$ScreenViewCopyWith<$Res> implements $ScreenViewCopyWith<$Res> {
  factory _$ScreenViewCopyWith(_ScreenView value, $Res Function(_ScreenView) _then) = __$ScreenViewCopyWithImpl;
@override @useResult
$Res call({
 ScreenStream stream, String? viewerHash, ScreenTask? task, HermesFailure? failure, bool zoomed, bool canFill, ScreenDrag drag, ScreenNotice? notice
});




}
/// @nodoc
class __$ScreenViewCopyWithImpl<$Res>
    implements _$ScreenViewCopyWith<$Res> {
  __$ScreenViewCopyWithImpl(this._self, this._then);

  final _ScreenView _self;
  final $Res Function(_ScreenView) _then;

/// Create a copy of ScreenView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stream = null,Object? viewerHash = freezed,Object? task = freezed,Object? failure = freezed,Object? zoomed = null,Object? canFill = null,Object? drag = null,Object? notice = freezed,}) {
  return _then(_ScreenView(
stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as ScreenStream,viewerHash: freezed == viewerHash ? _self.viewerHash : viewerHash // ignore: cast_nullable_to_non_nullable
as String?,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as ScreenTask?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HermesFailure?,zoomed: null == zoomed ? _self.zoomed : zoomed // ignore: cast_nullable_to_non_nullable
as bool,canFill: null == canFill ? _self.canFill : canFill // ignore: cast_nullable_to_non_nullable
as bool,drag: null == drag ? _self.drag : drag // ignore: cast_nullable_to_non_nullable
as ScreenDrag,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as ScreenNotice?,
  ));
}


}

// dart format on
