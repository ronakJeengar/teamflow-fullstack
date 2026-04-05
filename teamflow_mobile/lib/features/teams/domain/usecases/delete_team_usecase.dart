import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/team_repository.dart';

class DeleteTeamParams {
  final String teamId;

  const DeleteTeamParams(this.teamId);
}

class DeleteTeamUseCase extends UseCase<void, DeleteTeamParams> {
  final TeamRepository repository;

  DeleteTeamUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTeamParams params) {
    return repository.deleteTeam(params.teamId);
  }
}
