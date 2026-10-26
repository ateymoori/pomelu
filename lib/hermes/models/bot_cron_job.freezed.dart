// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_cron_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BotCronJob {

@LooseString() String get id;@LooseString() String get name;@LooseString() String get prompt;@JsonKey(fromJson: _scheduleFromJson) CronSchedule? get schedule;@JsonKey(name: 'schedule_display')@LooseString() String get scheduleDisplay;@LooseString() String get state;@JsonKey(name: 'next_run_at')@LooseDateTime() DateTime? get nextRunAt;@JsonKey(name: 'last_run_at')@LooseDateTime() DateTime? get lastRunAt;@JsonKey(name: 'last_status')@LooseString() String get lastStatus;@JsonKey(name: 'last_error')@LooseString() String get lastError;@JsonKey(name: 'last_delivery_error')@LooseString() String get lastDeliveryError;
/// Create a copy of BotCronJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotCronJobCopyWith<BotCronJob> get copyWith => _$BotCronJobCopyWithImpl<BotCronJob>(this as BotCronJob, _$identity);

  /// Serializes this BotCronJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BotCronJob;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotCronJob&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.prompt, _this.prompt) || other.prompt == _this.prompt)&&(identical(other.schedule, _this.schedule) || other.schedule == _this.schedule)&&(identical(other.scheduleDisplay, _this.scheduleDisplay) || other.scheduleDisplay == _this.scheduleDisplay)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.nextRunAt, _this.nextRunAt) || other.nextRunAt == _this.nextRunAt)&&(identical(other.lastRunAt, _this.lastRunAt) || other.lastRunAt == _this.lastRunAt)&&(identical(other.lastStatus, _this.lastStatus) || other.lastStatus == _this.lastStatus)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError)&&(identical(other.lastDeliveryError, _this.lastDeliveryError) || other.lastDeliveryError == _this.lastDeliveryError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BotCronJob;
  return Object.hash(runtimeType,_this.id,_this.name,_this.prompt,_this.schedule,_this.scheduleDisplay,_this.state,_this.nextRunAt,_this.lastRunAt,_this.lastStatus,_this.lastError,_this.lastDeliveryError);
}

@override
String toString() {
  final _this = this as BotCronJob;
  return 'BotCronJob(id: ${_this.id}, name: ${_this.name}, prompt: ${_this.prompt}, schedule: ${_this.schedule}, scheduleDisplay: ${_this.scheduleDisplay}, state: ${_this.state}, nextRunAt: ${_this.nextRunAt}, lastRunAt: ${_this.lastRunAt}, lastStatus: ${_this.lastStatus}, lastError: ${_this.lastError}, lastDeliveryError: ${_this.lastDeliveryError})';
}


}

/// @nodoc
abstract mixin class $BotCronJobCopyWith<$Res>  {
  factory $BotCronJobCopyWith(BotCronJob value, $Res Function(BotCronJob) _then) = _$BotCronJobCopyWithImpl;
@useResult
$Res call({
@LooseString() String id,@LooseString() String name,@LooseString() String prompt,@JsonKey(fromJson: _scheduleFromJson) CronSchedule? schedule,@JsonKey(name: 'schedule_display')@LooseString() String scheduleDisplay,@LooseString() String state,@JsonKey(name: 'next_run_at')@LooseDateTime() DateTime? nextRunAt,@JsonKey(name: 'last_run_at')@LooseDateTime() DateTime? lastRunAt,@JsonKey(name: 'last_status')@LooseString() String lastStatus,@JsonKey(name: 'last_error')@LooseString() String lastError,@JsonKey(name: 'last_delivery_error')@LooseString() String lastDeliveryError
});


$CronScheduleCopyWith<$Res>? get schedule;

}
/// @nodoc
class _$BotCronJobCopyWithImpl<$Res>
    implements $BotCronJobCopyWith<$Res> {
  _$BotCronJobCopyWithImpl(this._self, this._then);

  final BotCronJob _self;
  final $Res Function(BotCronJob) _then;

/// Create a copy of BotCronJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? prompt = null,Object? schedule = freezed,Object? scheduleDisplay = null,Object? state = null,Object? nextRunAt = freezed,Object? lastRunAt = freezed,Object? lastStatus = null,Object? lastError = null,Object? lastDeliveryError = null,}) {
  return _then(BotCronJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as CronSchedule?,scheduleDisplay: null == scheduleDisplay ? _self.scheduleDisplay : scheduleDisplay // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,nextRunAt: freezed == nextRunAt ? _self.nextRunAt : nextRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStatus: null == lastStatus ? _self.lastStatus : lastStatus // ignore: cast_nullable_to_non_nullable
as String,lastError: null == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String,lastDeliveryError: null == lastDeliveryError ? _self.lastDeliveryError : lastDeliveryError // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of BotCronJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CronScheduleCopyWith<$Res>? get schedule {
    if (_self.schedule == null) {
    return null;
  }

  return $CronScheduleCopyWith<$Res>(_self.schedule!, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// Adds pattern-matching-related methods to [BotCronJob].
extension BotCronJobPatterns on BotCronJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotCronJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotCronJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotCronJob value)  $default,){
final _that = this;
switch (_that) {
case _BotCronJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotCronJob value)?  $default,){
final _that = this;
switch (_that) {
case _BotCronJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String name, @LooseString()  String prompt, @JsonKey(fromJson: _scheduleFromJson)  CronSchedule? schedule, @JsonKey(name: 'schedule_display')@LooseString()  String scheduleDisplay, @LooseString()  String state, @JsonKey(name: 'next_run_at')@LooseDateTime()  DateTime? nextRunAt, @JsonKey(name: 'last_run_at')@LooseDateTime()  DateTime? lastRunAt, @JsonKey(name: 'last_status')@LooseString()  String lastStatus, @JsonKey(name: 'last_error')@LooseString()  String lastError, @JsonKey(name: 'last_delivery_error')@LooseString()  String lastDeliveryError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotCronJob() when $default != null:
return $default(_that.id,_that.name,_that.prompt,_that.schedule,_that.scheduleDisplay,_that.state,_that.nextRunAt,_that.lastRunAt,_that.lastStatus,_that.lastError,_that.lastDeliveryError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String name, @LooseString()  String prompt, @JsonKey(fromJson: _scheduleFromJson)  CronSchedule? schedule, @JsonKey(name: 'schedule_display')@LooseString()  String scheduleDisplay, @LooseString()  String state, @JsonKey(name: 'next_run_at')@LooseDateTime()  DateTime? nextRunAt, @JsonKey(name: 'last_run_at')@LooseDateTime()  DateTime? lastRunAt, @JsonKey(name: 'last_status')@LooseString()  String lastStatus, @JsonKey(name: 'last_error')@LooseString()  String lastError, @JsonKey(name: 'last_delivery_error')@LooseString()  String lastDeliveryError)  $default,) {final _that = this;
switch (_that) {
case _BotCronJob():
return $default(_that.id,_that.name,_that.prompt,_that.schedule,_that.scheduleDisplay,_that.state,_that.nextRunAt,_that.lastRunAt,_that.lastStatus,_that.lastError,_that.lastDeliveryError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String id, @LooseString()  String name, @LooseString()  String prompt, @JsonKey(fromJson: _scheduleFromJson)  CronSchedule? schedule, @JsonKey(name: 'schedule_display')@LooseString()  String scheduleDisplay, @LooseString()  String state, @JsonKey(name: 'next_run_at')@LooseDateTime()  DateTime? nextRunAt, @JsonKey(name: 'last_run_at')@LooseDateTime()  DateTime? lastRunAt, @JsonKey(name: 'last_status')@LooseString()  String lastStatus, @JsonKey(name: 'last_error')@LooseString()  String lastError, @JsonKey(name: 'last_delivery_error')@LooseString()  String lastDeliveryError)?  $default,) {final _that = this;
switch (_that) {
case _BotCronJob() when $default != null:
return $default(_that.id,_that.name,_that.prompt,_that.schedule,_that.scheduleDisplay,_that.state,_that.nextRunAt,_that.lastRunAt,_that.lastStatus,_that.lastError,_that.lastDeliveryError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotCronJob extends BotCronJob {
  const _BotCronJob({@LooseString() this.id = '', @LooseString() this.name = '', @LooseString() this.prompt = '', @JsonKey(fromJson: _scheduleFromJson) this.schedule, @JsonKey(name: 'schedule_display')@LooseString() this.scheduleDisplay = '', @LooseString() this.state = '', @JsonKey(name: 'next_run_at')@LooseDateTime() this.nextRunAt, @JsonKey(name: 'last_run_at')@LooseDateTime() this.lastRunAt, @JsonKey(name: 'last_status')@LooseString() this.lastStatus = '', @JsonKey(name: 'last_error')@LooseString() this.lastError = '', @JsonKey(name: 'last_delivery_error')@LooseString() this.lastDeliveryError = ''}): super._();
  factory _BotCronJob.fromJson(Map<String, dynamic> json) => _$BotCronJobFromJson(json);

@override@JsonKey()@LooseString() final  String id;
@override@JsonKey()@LooseString() final  String name;
@override@JsonKey()@LooseString() final  String prompt;
@override@JsonKey(fromJson: _scheduleFromJson) final  CronSchedule? schedule;
@override@JsonKey(name: 'schedule_display')@LooseString() final  String scheduleDisplay;
@override@JsonKey()@LooseString() final  String state;
@override@JsonKey(name: 'next_run_at')@LooseDateTime() final  DateTime? nextRunAt;
@override@JsonKey(name: 'last_run_at')@LooseDateTime() final  DateTime? lastRunAt;
@override@JsonKey(name: 'last_status')@LooseString() final  String lastStatus;
@override@JsonKey(name: 'last_error')@LooseString() final  String lastError;
@override@JsonKey(name: 'last_delivery_error')@LooseString() final  String lastDeliveryError;

/// Create a copy of BotCronJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotCronJobCopyWith<_BotCronJob> get copyWith => __$BotCronJobCopyWithImpl<_BotCronJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotCronJobToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotCronJob&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.scheduleDisplay, scheduleDisplay) || other.scheduleDisplay == scheduleDisplay)&&(identical(other.state, state) || other.state == state)&&(identical(other.nextRunAt, nextRunAt) || other.nextRunAt == nextRunAt)&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.lastStatus, lastStatus) || other.lastStatus == lastStatus)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.lastDeliveryError, lastDeliveryError) || other.lastDeliveryError == lastDeliveryError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,prompt,schedule,scheduleDisplay,state,nextRunAt,lastRunAt,lastStatus,lastError,lastDeliveryError);
}

@override
String toString() {
    return 'BotCronJob(id: $id, name: $name, prompt: $prompt, schedule: $schedule, scheduleDisplay: $scheduleDisplay, state: $state, nextRunAt: $nextRunAt, lastRunAt: $lastRunAt, lastStatus: $lastStatus, lastError: $lastError, lastDeliveryError: $lastDeliveryError)';
}


}

/// @nodoc
abstract mixin class _$BotCronJobCopyWith<$Res> implements $BotCronJobCopyWith<$Res> {
  factory _$BotCronJobCopyWith(_BotCronJob value, $Res Function(_BotCronJob) _then) = __$BotCronJobCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String id,@LooseString() String name,@LooseString() String prompt,@JsonKey(fromJson: _scheduleFromJson) CronSchedule? schedule,@JsonKey(name: 'schedule_display')@LooseString() String scheduleDisplay,@LooseString() String state,@JsonKey(name: 'next_run_at')@LooseDateTime() DateTime? nextRunAt,@JsonKey(name: 'last_run_at')@LooseDateTime() DateTime? lastRunAt,@JsonKey(name: 'last_status')@LooseString() String lastStatus,@JsonKey(name: 'last_error')@LooseString() String lastError,@JsonKey(name: 'last_delivery_error')@LooseString() String lastDeliveryError
});


@override $CronScheduleCopyWith<$Res>? get schedule;

}
/// @nodoc
class __$BotCronJobCopyWithImpl<$Res>
    implements _$BotCronJobCopyWith<$Res> {
  __$BotCronJobCopyWithImpl(this._self, this._then);

  final _BotCronJob _self;
  final $Res Function(_BotCronJob) _then;

/// Create a copy of BotCronJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? prompt = null,Object? schedule = freezed,Object? scheduleDisplay = null,Object? state = null,Object? nextRunAt = freezed,Object? lastRunAt = freezed,Object? lastStatus = null,Object? lastError = null,Object? lastDeliveryError = null,}) {
  return _then(_BotCronJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as CronSchedule?,scheduleDisplay: null == scheduleDisplay ? _self.scheduleDisplay : scheduleDisplay // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,nextRunAt: freezed == nextRunAt ? _self.nextRunAt : nextRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStatus: null == lastStatus ? _self.lastStatus : lastStatus // ignore: cast_nullable_to_non_nullable
as String,lastError: null == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String,lastDeliveryError: null == lastDeliveryError ? _self.lastDeliveryError : lastDeliveryError // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BotCronJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CronScheduleCopyWith<$Res>? get schedule {
    if (_self.schedule == null) {
    return null;
  }

  return $CronScheduleCopyWith<$Res>(_self.schedule!, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}

// dart format on
