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
  });

  /// Get Tasks
  Future<Either<Failure, List<TaskEntity>>> getTasks(String projectId);

  /// Update Task
  Future<Either<Failure, TaskEntity>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assigneeId,
  });

  /// Delete Task
  Future<Either<Failure, void>> deleteTask(String taskId);
}
