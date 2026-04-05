import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class GetTeamByIdParams {
  final String teamId;

  const GetTeamByIdParams(this.teamId);
}

class GetTeamByIdUseCase extends UseCase<TeamEntity, GetTeamByIdParams> {
  final TeamRepository repository;

  GetTeamByIdUseCase(this.repository);

  @override
  Future<Either<Failure, TeamEntity>> call(GetTeamByIdParams params) {
    return repository.getTeamById(params.teamId);
  }
}
