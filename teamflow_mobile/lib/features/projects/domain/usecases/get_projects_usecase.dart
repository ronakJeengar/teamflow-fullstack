import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entitties/project_entity.dart';
import '../repository/projects_repository.dart';

/// ================= GET PROJECTS =================

class GetProjectsByTeamParams {
  final String teamId;

  const GetProjectsByTeamParams({required this.teamId});
}

class GetProjectsByTeamUseCase
    extends UseCase<List<ProjectEntity>, GetProjectsByTeamParams> {
  final ProjectsRepository repository;

  GetProjectsByTeamUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProjectEntity>>> call(
    GetProjectsByTeamParams params,
  ) {
    return repository.getProjectsByTeamId(params.teamId);
  }
}
