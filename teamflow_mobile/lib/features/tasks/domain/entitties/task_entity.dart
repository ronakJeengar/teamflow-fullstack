import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/task_model.dart';

part 'task_entity.freezed.dart';

@freezed
abstract class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
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
  }) = _TaskEntity;
}