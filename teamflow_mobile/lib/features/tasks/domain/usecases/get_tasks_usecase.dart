import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entitties/task_entity.dart';
import '../repository/tasks_repository.dart';

/// ================= GET TASKS =================

class GetTasksParams {
  final String projectId;

  const GetTasksParams({required this.projectId});
}

class GetTasksUseCase extends UseCase<List<TaskEntity>, GetTasksParams> {
  final TasksRepository repository;

  GetTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(GetTasksParams params) {
    return repository.getTasks(params.projectId);
  }
}
