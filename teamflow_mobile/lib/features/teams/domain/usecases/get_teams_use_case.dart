import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';
import '../../../../core/usecase/usecase.dart';

class GetTeamsUseCase extends NoParams<List<TeamEntity>> {
  final TeamRepository repository;

  GetTeamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TeamEntity>>> call() {
    return repository.getTeams();
  }
}