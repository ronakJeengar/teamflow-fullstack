import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entitties/task_entity.dart';
import '../repository/tasks_repository.dart';

/// ================= UPDATE TASK =================

class UpdateTaskParams {
  final String taskId;
  final String? title;
  final String? description;
  final String? status;
  final String? priority;
  final String? assigneeId;

  const UpdateTaskParams({
    required this.taskId,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.assigneeId,
  });
}

class UpdateTaskUseCase extends UseCase<TaskEntity, UpdateTaskParams> {
  final TasksRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) {
    return repository.updateTask(
      taskId: params.taskId,
      title: params.title,
      description: params.description,
      status: params.status,
      priority: params.priority,
      assigneeId: params.assigneeId,
    );
  }
}
