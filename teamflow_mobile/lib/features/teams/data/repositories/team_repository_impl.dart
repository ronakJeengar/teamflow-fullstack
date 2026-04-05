import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/core/mappers/team_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/teams_remote_datasource.dart';
import '../models/team_model.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource remoteDataSource;

  TeamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TeamEntity>> createTeam({
    required String name,
    String? description,
  }) async {
    try {
      final Team team = await remoteDataSource.createTeam(
        name: name,
        description: description,
      );
      return right(team.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getTeams() async {
    try {
      final List<Team> teams = await remoteDataSource.getTeams();
      return right(teams.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> getTeamById(String teamId) async {
    try {
      final Team team = await remoteDataSource.getTeamById(teamId);
      return right(team.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> updateTeam({
    required String teamId,
    required String name,
    String? description,
  }) async {
    try {
      final Team team = await remoteDataSource.updateTeam(
        teamId: teamId,
        name: name,
        description: description,
      );
      return right(team.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeam(String teamId) async {
    try {
      await remoteDataSource.deleteTeam(teamId);
      return right(null);
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error'));
    }
  }
}
