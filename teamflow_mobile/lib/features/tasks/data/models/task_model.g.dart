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
    };

const _$TaskStatusEnumMap = {
  TaskStatus.TODO: 'TODO',
  TaskStatus.IN_PROGRESS: 'IN_PROGRESS',
  TaskStatus.DONE: 'DONE',
};
