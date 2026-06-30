import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entitties/task_entity.dart';

part 'task_model.freezed.dart';

part 'task_model.g.dart';

enum TaskStatus { TODO, IN_PROGRESS, REVIEW, BLOCKED, DONE }

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    String? description,
    required TaskStatus status,
    required String projectId,
    required String createdById,
    String? assignedToId,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? priority,
    DateTime? dueDate,
    List<String>? tags,
    String? sprintId,
    int? storyPoints,
    String? backlogStatus,
    @Default(false) bool isRecurring,
    String? recurrence,
    String? parentId,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}

extension TaskModelMapper on TaskModel {
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      status: status,
      projectId: projectId,
      createdById: createdById,
      assignedToId: assignedToId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      priority: priority,
      dueDate: dueDate,
      tags: tags,
      sprintId: sprintId,
      storyPoints: storyPoints,
      backlogStatus: backlogStatus,
      isRecurring: isRecurring,
      recurrence: recurrence,
      parentId: parentId,
    );
  }
}

extension TaskEntityMapper on TaskEntity {
  TaskModel toModel() {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      status: status,
      projectId: projectId,
      createdById: createdById,
      assignedToId: assignedToId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      priority: priority,
      dueDate: dueDate,
      tags: tags,
      sprintId: sprintId,
      storyPoints: storyPoints,
      backlogStatus: backlogStatus,
      isRecurring: isRecurring,
      recurrence: recurrence,
      parentId: parentId,
    );
  }
}
