import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entitties/task_entity.dart';

abstract class TasksRepository {
  /// Create Task
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    required String projectId,
    String? assigneeId,
    String? status,
    String? priority,
    String? sprintId,
    int? storyPoints,
    String? backlogStatus,
    bool? isRecurring,
    String? recurrence,
    String? parentId,
  });

  /// Get Tasks
  Future<Either<Failure, List<TaskEntity>>> getTasks(String projectId);

  /// Get Current User Tasks
  Future<Either<Failure, List<TaskEntity>>> getMyTasks();

  /// Update Task
  Future<Either<Failure, TaskEntity>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assigneeId,
    String? sprintId,
    int? storyPoints,
    String? backlogStatus,
    bool? isRecurring,
    String? recurrence,
    String? parentId,
  });

  /// Delete Task
  Future<Either<Failure, void>> deleteTask(String taskId);
}
