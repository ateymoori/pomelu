import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';
import 'json_parse.dart';

part 'todo_plan.freezed.dart';
part 'todo_plan.g.dart';

/// Where one step of the agent's plan stands.
enum TodoStatus {
  pending,
  @JsonValue('in_progress')
  inProgress,
  completed,
  cancelled;

  bool get isOpen => this == pending || this == inProgress;
}

/// One step of the plan the agent's `todo` tool keeps.
@freezed
abstract class TodoItem with _$TodoItem {
  const factory TodoItem({
    @LooseString() @Default('') String id,
    @LooseString() @Default('') String content,
    @JsonKey(unknownEnumValue: TodoStatus.pending)
    @Default(TodoStatus.pending)
    TodoStatus status,

    /// The step this one is a part of; null at the top level.
    @LooseStringOrNull() String? parent,
  }) = _TodoItem;

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
}

/// The whole plan: `todo.updated` and the `todo_state` of a resume. Each
/// snapshot replaces the one before; [revision] only grows.
@freezed
abstract class TodoPlan with _$TodoPlan {
  const TodoPlan._();

  const factory TodoPlan({
    @JsonKey(name: 'todos', fromJson: _todoRows)
    @Default(<TodoItem>[])
    List<TodoItem> items,
    @LooseInt() @Default(0) int revision,
  }) = _TodoPlan;

  factory TodoPlan.fromJson(Map<String, dynamic> json) =>
      _$TodoPlanFromJson(json);

  /// Steps that count: a cancelled one is neither done nor to do.
  Iterable<TodoItem> get _counted =>
      items.where((t) => t.status != TodoStatus.cancelled);

  int get total => _counted.length;
  int get done =>
      _counted.where((t) => t.status == TodoStatus.completed).length;

  /// The step the agent works on, else the next one to do.
  TodoItem? get current =>
      items.where((t) => t.status == TodoStatus.inProgress).firstOrNull ??
      items.where((t) => t.status == TodoStatus.pending).firstOrNull;
}

List<TodoItem> _todoRows(Object? json) => parseRows(
  json,
  TodoItem.fromJson,
  what: 'todo',
  keep: (t) => t.content.trim().isNotEmpty,
);
