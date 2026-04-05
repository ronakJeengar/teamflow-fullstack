import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/team_entity.dart';

abstract class TeamRepository {
  /// Create a new team
  Future<Either<Failure, TeamEntity>> createTeam({
    required String name,
    String? description,
  });

  /// Get all teams
  Future<Either<Failure, List<TeamEntity>>> getTeams();

  /// Get a team by ID
  Future<Either<Failure, TeamEntity>> getTeamById(String teamId);

  /// Update a team
  Future<Either<Failure, TeamEntity>> updateTeam({
    required String teamId,
    required String name,
    String? description,
  });

  /// Delete a team
  Future<Either<Failure, void>> deleteTeam(String teamId);
}
