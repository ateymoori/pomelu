// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => _TodoItem(
  id: json['id'] == null ? '' : const LooseString().fromJson(json['id']),
  content: json['content'] == null
      ? ''
      : const LooseString().fromJson(json['content']),
  status:
      $enumDecodeNullable(
        _$TodoStatusEnumMap,
        json['status'],
        unknownValue: TodoStatus.pending,
      ) ??
      TodoStatus.pending,
  parent: const LooseStringOrNull().fromJson(json['parent']),
);

Map<String, dynamic> _$TodoItemToJson(_TodoItem instance) => <String, dynamic>{
  'id': const LooseString().toJson(instance.id),
  'content': const LooseString().toJson(instance.content),
  'status': _$TodoStatusEnumMap[instance.status]!,
  'parent': const LooseStringOrNull().toJson(instance.parent),
};

const _$TodoStatusEnumMap = {
  TodoStatus.pending: 'pending',
  TodoStatus.inProgress: 'in_progress',
  TodoStatus.completed: 'completed',
  TodoStatus.cancelled: 'cancelled',
};

_TodoPlan _$TodoPlanFromJson(Map<String, dynamic> json) => _TodoPlan(
  items: json['todos'] == null ? const <TodoItem>[] : _todoRows(json['todos']),
  revision: json['revision'] == null
      ? 0
      : const LooseInt().fromJson(json['revision']),
);

Map<String, dynamic> _$TodoPlanToJson(_TodoPlan instance) => <String, dynamic>{
  'todos': instance.items,
  'revision': const LooseInt().toJson(instance.revision),
};
