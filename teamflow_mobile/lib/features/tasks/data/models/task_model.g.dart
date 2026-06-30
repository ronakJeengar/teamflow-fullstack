// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => _TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  projectId: json['projectId'] as String,
  createdById: json['createdById'] as String,
  assignedToId: json['assignedToId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  priority: json['priority'] as String?,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  sprintId: json['sprintId'] as String?,
  storyPoints: (json['storyPoints'] as num?)?.toInt(),
  backlogStatus: json['backlogStatus'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurrence: json['recurrence'] as String?,
  parentId: json['parentId'] as String?,
  assignedTo: json['assignedTo'] == null
      ? null
      : TaskAssigneeModel.fromJson(json['assignedTo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'projectId': instance.projectId,
      'createdById': instance.createdById,
      'assignedToId': instance.assignedToId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'priority': instance.priority,
      'dueDate': instance.dueDate?.toIso8601String(),
      'tags': instance.tags,
      'sprintId': instance.sprintId,
      'storyPoints': instance.storyPoints,
      'backlogStatus': instance.backlogStatus,
      'isRecurring': instance.isRecurring,
      'recurrence': instance.recurrence,
      'parentId': instance.parentId,
      'assignedTo': instance.assignedTo,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.TODO: 'TODO',
  TaskStatus.IN_PROGRESS: 'IN_PROGRESS',
  TaskStatus.REVIEW: 'REVIEW',
  TaskStatus.BLOCKED: 'BLOCKED',
  TaskStatus.DONE: 'DONE',
};

_TaskAssigneeModel _$TaskAssigneeModelFromJson(Map<String, dynamic> json) =>
    _TaskAssigneeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$TaskAssigneeModelToJson(_TaskAssigneeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
    };
