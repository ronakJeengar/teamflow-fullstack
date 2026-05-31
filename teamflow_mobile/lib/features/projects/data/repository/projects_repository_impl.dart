import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/core/mappers/project_mapper.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entitties/project_entity.dart';
import '../../domain/repository/projects_repository.dart';
import '../datasources/projects_remote_datasource.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource remoteDataSource;

  ProjectsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProjectEntity>> createProject({
    required String teamId,
    required String name,
    String? description,
  }) async {
    try {
      final project = await remoteDataSource.createProject(
        teamId: teamId,
        name: name,
        description: description,
      );

      return Right(project.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjectsByTeamId(
    String teamId,
  ) async {
    try {
      final projects = await remoteDataSource.getProjectsByTeamId(teamId);

      return Right(projects.map((project) => project.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> updateProject({
    required String teamId,
    required String projectId,
    required String name,
    String? description,
  }) async {
    try {
      final project = await remoteDataSource.updateProject(
        teamId: teamId,
        projectId: projectId,
        name: name,
        description: description,
      );

      return Right(project.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject({
    required String teamId,
    required String projectId,
  }) async {
    try {
      await remoteDataSource.deleteProject(
        teamId: teamId,
        projectId: projectId,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
