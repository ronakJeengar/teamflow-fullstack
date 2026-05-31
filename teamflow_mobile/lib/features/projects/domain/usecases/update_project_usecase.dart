import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entitties/project_entity.dart';
import '../repository/projects_repository.dart';

/// ================= UPDATE PROJECT =================

class UpdateProjectParams {
  final String teamId;
  final String projectId;
  final String name;
  final String? description;

  const UpdateProjectParams({
    required this.teamId,
    required this.projectId,
    required this.name,
    this.description,
  });
}

class UpdateProjectUseCase extends UseCase<ProjectEntity, UpdateProjectParams> {
  final ProjectsRepository repository;

  UpdateProjectUseCase(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(UpdateProjectParams params) {
    return repository.updateProject(
      teamId: params.teamId,
      projectId: params.projectId,
      name: params.name,
      description: params.description,
    );
  }
}
