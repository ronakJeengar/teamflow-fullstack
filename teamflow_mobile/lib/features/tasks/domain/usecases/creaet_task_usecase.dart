import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entitties/task_entity.dart';
import '../repository/tasks_repository.dart';

/// ================= CREATE TASK =================

class CreateTaskParams {
  final String title;
  final String? description;
  final String projectId;
  final String? assigneeId;
  final String? status;
  final String? priority;
  final String? sprintId;
  final int? storyPoints;
  final String? backlogStatus;
  final bool? isRecurring;
  final String? recurrence;
  final String? parentId;

  const CreateTaskParams({
    required this.title,
    this.description,
    required this.projectId,
    this.assigneeId,
    this.status,
    this.priority,
    this.sprintId,
    this.storyPoints,
    this.backlogStatus,
    this.isRecurring,
    this.recurrence,
    this.parentId,
  });
}

class CreateTaskUseCase extends UseCase<TaskEntity, CreateTaskParams> {
  final TasksRepository repository;

  CreateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) {
    return repository.createTask(
      title: params.title,
      description: params.description,
      projectId: params.projectId,
      assigneeId: params.assigneeId,
      status: params.status,
      priority: params.priority,
      sprintId: params.sprintId,
      storyPoints: params.storyPoints,
      backlogStatus: params.backlogStatus,
      isRecurring: params.isRecurring,
      recurrence: params.recurrence,
      parentId: params.parentId,
    );
  }
}
