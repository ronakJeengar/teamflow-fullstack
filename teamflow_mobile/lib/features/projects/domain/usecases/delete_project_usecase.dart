import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/projects_repository.dart';

/// ================= DELETE PROJECT =================

class DeleteProjectParams {
  final String teamId;
  final String projectId;

  const DeleteProjectParams({required this.teamId, required this.projectId});
}

class DeleteProjectUseCase extends UseCase<void, DeleteProjectParams> {
  final ProjectsRepository repository;

  DeleteProjectUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) {
    return repository.deleteProject(
      teamId: params.teamId,
      projectId: params.projectId,
    );
  }
}
