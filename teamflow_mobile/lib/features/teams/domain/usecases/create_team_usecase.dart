import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class CreateTeamParams {
  final String name;
  final String? description;

  const CreateTeamParams({required this.name, this.description});
}

class CreateTeamUseCase extends UseCase<TeamEntity, CreateTeamParams> {
  final TeamRepository repository;

  CreateTeamUseCase(this.repository);

  @override
  Future<Either<Failure, TeamEntity>> call(CreateTeamParams params) {
    return repository.createTeam(
      name: params.name,
      description: params.description,
    );
  }
}
