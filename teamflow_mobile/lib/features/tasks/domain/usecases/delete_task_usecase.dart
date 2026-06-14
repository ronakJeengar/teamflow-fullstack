import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/tasks_repository.dart';

/// ================= DELETE TASK =================

class DeleteTaskParams {
  final String taskId;

  const DeleteTaskParams({required this.taskId});
}

class DeleteTaskUseCase extends UseCase<void, DeleteTaskParams> {
  final TasksRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) {
    return repository.deleteTask(params.taskId);
  }
}
