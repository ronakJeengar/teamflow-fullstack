import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class UpdateTeamParams {
  final String teamId;
  final String name;
  final String? description;

  const UpdateTeamParams({
    required this.teamId,
    required this.name,
    this.description,
  });
}

class UpdateTeamUseCase extends UseCase<TeamEntity, UpdateTeamParams> {
  final TeamRepository repository;

  UpdateTeamUseCase(this.repository);

  @override
  Future<Either<Failure, TeamEntity>> call(UpdateTeamParams params) {
    return repository.updateTeam(
      teamId: params.teamId,
      name: params.name,
      description: params.description,
    );
  }
}