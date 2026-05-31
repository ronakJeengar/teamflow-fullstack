import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entitties/project_entity.dart';
import '../repository/projects_repository.dart';

/// ================= CREATE PROJECT =================

class CreateProjectParams {
  final String teamId;
  final String name;
  final String? description;

  const CreateProjectParams({
    required this.teamId,
    required this.name,
    this.description,
  });
}

class CreateProjectUseCase extends UseCase<ProjectEntity, CreateProjectParams> {
  final ProjectsRepository repository;

  CreateProjectUseCase(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(CreateProjectParams params) {
    return repository.createProject(
      teamId: params.teamId,
      name: params.name,
      description: params.description,
    );
  }
}
