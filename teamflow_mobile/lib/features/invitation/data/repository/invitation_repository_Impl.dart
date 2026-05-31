import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../tasks/domain/entitties/task_entity.dart';
import '../../../tasks/domain/repository/tasks_repository.dart';

/// ================= CREATE TASK =================

class CreateTaskParams {
  final String title;
  final String? description;
  final String projectId;
  final String? assigneeId;
  final String? status;
  final String? priority;

  const CreateTaskParams({
    required this.title,
    this.description,
    required this.projectId,
    this.assigneeId,
    this.status,
    this.priority,
  });
}

class CreateTaskUseCase
    extends UseCase<TaskEntity, CreateTaskParams> {
  final TasksRepository repository;

  CreateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(
      CreateTaskParams params,
      ) {
    return repository.createTask(
      title: params.title,
      description: params.description,
      projectId: params.projectId,
      assigneeId: params.assigneeId,
      status: params.status,
      priority: params.priority,
    );
  }
}