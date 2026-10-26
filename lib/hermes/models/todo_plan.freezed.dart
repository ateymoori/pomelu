// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TodoItem {

@LooseString() String get id;@LooseString() String get content;@JsonKey(unknownEnumValue: TodoStatus.pending) TodoStatus get status;/// The step this one is a part of; null at the top level.
@LooseStringOrNull() String? get parent;
/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoItemCopyWith<TodoItem> get copyWith => _$TodoItemCopyWithImpl<TodoItem>(this as TodoItem, _$identity);

  /// Serializes this TodoItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TodoItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.parent, _this.parent) || other.parent == _this.parent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TodoItem;
  return Object.hash(runtimeType,_this.id,_this.content,_this.status,_this.parent);
}

@override
String toString() {
  final _this = this as TodoItem;
  return 'TodoItem(id: ${_this.id}, content: ${_this.content}, status: ${_this.status}, parent: ${_this.parent})';
}


}

/// @nodoc
abstract mixin class $TodoItemCopyWith<$Res>  {
  factory $TodoItemCopyWith(TodoItem value, $Res Function(TodoItem) _then) = _$TodoItemCopyWithImpl;
@useResult
$Res call({
@LooseString() String id,@LooseString() String content,@JsonKey(unknownEnumValue: TodoStatus.pending) TodoStatus status,@LooseStringOrNull() String? parent
});




}
/// @nodoc
class _$TodoItemCopyWithImpl<$Res>
    implements $TodoItemCopyWith<$Res> {
  _$TodoItemCopyWithImpl(this._self, this._then);

  final TodoItem _self;
  final $Res Function(TodoItem) _then;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? status = null,Object? parent = freezed,}) {
  return _then(TodoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TodoStatus,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoItem].
extension TodoItemPatterns on TodoItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoItem value)  $default,){
final _that = this;
switch (_that) {
case _TodoItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoItem value)?  $default,){
final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String content, @JsonKey(unknownEnumValue: TodoStatus.pending)  TodoStatus status, @LooseStringOrNull()  String? parent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
return $default(_that.id,_that.content,_that.status,_that.parent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LooseString()  String id, @LooseString()  String content, @JsonKey(unknownEnumValue: TodoStatus.pending)  TodoStatus status, @LooseStringOrNull()  String? parent)  $default,) {final _that = this;
switch (_that) {
case _TodoItem():
return $default(_that.id,_that.content,_that.status,_that.parent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LooseString()  String id, @LooseString()  String content, @JsonKey(unknownEnumValue: TodoStatus.pending)  TodoStatus status, @LooseStringOrNull()  String? parent)?  $default,) {final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
return $default(_that.id,_that.content,_that.status,_that.parent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoItem implements TodoItem {
  const _TodoItem({@LooseString() this.id = '', @LooseString() this.content = '', @JsonKey(unknownEnumValue: TodoStatus.pending) this.status = TodoStatus.pending, @LooseStringOrNull() this.parent});
  factory _TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);

@override@JsonKey()@LooseString() final  String id;
@override@JsonKey()@LooseString() final  String content;
@override@JsonKey(unknownEnumValue: TodoStatus.pending) final  TodoStatus status;
/// The step this one is a part of; null at the top level.
@override@LooseStringOrNull() final  String? parent;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoItemCopyWith<_TodoItem> get copyWith => __$TodoItemCopyWithImpl<_TodoItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodoItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.status, status) || other.status == status)&&(identical(other.parent, parent) || other.parent == parent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,content,status,parent);
}

@override
String toString() {
    return 'TodoItem(id: $id, content: $content, status: $status, parent: $parent)';
}


}

/// @nodoc
abstract mixin class _$TodoItemCopyWith<$Res> implements $TodoItemCopyWith<$Res> {
  factory _$TodoItemCopyWith(_TodoItem value, $Res Function(_TodoItem) _then) = __$TodoItemCopyWithImpl;
@override @useResult
$Res call({
@LooseString() String id,@LooseString() String content,@JsonKey(unknownEnumValue: TodoStatus.pending) TodoStatus status,@LooseStringOrNull() String? parent
});




}
/// @nodoc
class __$TodoItemCopyWithImpl<$Res>
    implements _$TodoItemCopyWith<$Res> {
  __$TodoItemCopyWithImpl(this._self, this._then);

  final _TodoItem _self;
  final $Res Function(_TodoItem) _then;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? status = null,Object? parent = freezed,}) {
  return _then(_TodoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TodoStatus,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TodoPlan {

@JsonKey(name: 'todos', fromJson: _todoRows) List<TodoItem> get items;@LooseInt() int get revision;
/// Create a copy of TodoPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoPlanCopyWith<TodoPlan> get copyWith => _$TodoPlanCopyWithImpl<TodoPlan>(this as TodoPlan, _$identity);

  /// Serializes this TodoPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TodoPlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoPlan&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.revision, _this.revision) || other.revision == _this.revision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TodoPlan;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.revision);
}

@override
String toString() {
  final _this = this as TodoPlan;
  return 'TodoPlan(items: ${_this.items}, revision: ${_this.revision})';
}


}

/// @nodoc
abstract mixin class $TodoPlanCopyWith<$Res>  {
  factory $TodoPlanCopyWith(TodoPlan value, $Res Function(TodoPlan) _then) = _$TodoPlanCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'todos', fromJson: _todoRows) List<TodoItem> items,@LooseInt() int revision
});




}
/// @nodoc
class _$TodoPlanCopyWithImpl<$Res>
    implements $TodoPlanCopyWith<$Res> {
  _$TodoPlanCopyWithImpl(this._self, this._then);

  final TodoPlan _self;
  final $Res Function(TodoPlan) _then;

/// Create a copy of TodoPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? revision = null,}) {
  return _then(TodoPlan(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TodoItem>,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoPlan].
extension TodoPlanPatterns on TodoPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoPlan value)  $default,){
final _that = this;
switch (_that) {
case _TodoPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoPlan value)?  $default,){
final _that = this;
switch (_that) {
case _TodoPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'todos', fromJson: _todoRows)  List<TodoItem> items, @LooseInt()  int revision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoPlan() when $default != null:
return $default(_that.items,_that.revision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'todos', fromJson: _todoRows)  List<TodoItem> items, @LooseInt()  int revision)  $default,) {final _that = this;
switch (_that) {
case _TodoPlan():
return $default(_that.items,_that.revision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'todos', fromJson: _todoRows)  List<TodoItem> items, @LooseInt()  int revision)?  $default,) {final _that = this;
switch (_that) {
case _TodoPlan() when $default != null:
return $default(_that.items,_that.revision);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoPlan extends TodoPlan {
  const _TodoPlan({@JsonKey(name: 'todos', fromJson: _todoRows)  List<TodoItem> items = const <TodoItem>[], @LooseInt() this.revision = 0}): _items = items,super._();
  factory _TodoPlan.fromJson(Map<String, dynamic> json) => _$TodoPlanFromJson(json);

 final  List<TodoItem> _items;
@override@JsonKey(name: 'todos', fromJson: _todoRows) List<TodoItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey()@LooseInt() final  int revision;

/// Create a copy of TodoPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoPlanCopyWith<_TodoPlan> get copyWith => __$TodoPlanCopyWithImpl<_TodoPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodoPlanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoPlan&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.revision, revision) || other.revision == revision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),revision);
}

@override
String toString() {
    return 'TodoPlan(items: $items, revision: $revision)';
}


}

/// @nodoc
abstract mixin class _$TodoPlanCopyWith<$Res> implements $TodoPlanCopyWith<$Res> {
  factory _$TodoPlanCopyWith(_TodoPlan value, $Res Function(_TodoPlan) _then) = __$TodoPlanCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'todos', fromJson: _todoRows) List<TodoItem> items,@LooseInt() int revision
});




}
/// @nodoc
class __$TodoPlanCopyWithImpl<$Res>
    implements _$TodoPlanCopyWith<$Res> {
  __$TodoPlanCopyWithImpl(this._self, this._then);

  final _TodoPlan _self;
  final $Res Function(_TodoPlan) _then;

/// Create a copy of TodoPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? revision = null,}) {
  return _then(_TodoPlan(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TodoItem>,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
