import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/sprints_repository.dart';
import '../datasources/sprints_remote_datasource.dart';
import '../models/sprint_model.dart';

class SprintsRepositoryImpl implements SprintsRepository {
  final SprintsRemoteDataSource remoteDataSource;

  SprintsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SprintModel>>> getSprints(String projectId) async {
    try {
      final list = await remoteDataSource.getSprints(projectId);
      return Right(list);
    } catch (e) {
      return Left(ServerFailure('Failed to load sprints'));
    }
  }

  @override
  Future<Either<Failure, SprintModel>> createSprint(
    String projectId, {
    required String name,
    String? goal,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final sprint = await remoteDataSource.createSprint(
        projectId,
        name: name,
        goal: goal,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(sprint);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SprintModel>> getSprintById(String id) async {
    try {
      final sprint = await remoteDataSource.getSprintById(id);
      return Right(sprint);
    } catch (e) {
      return Left(ServerFailure('Failed to load sprint'));
    }
  }

  @override
  Future<Either<Failure, SprintModel>> updateSprint(
    String id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
    SprintStatus? status,
  }) async {
    try {
      final sprint = await remoteDataSource.updateSprint(
        id,
        name: name,
        goal: goal,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      return Right(sprint);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSprint(String id) async {
    try {
      await remoteDataSource.deleteSprint(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignTasks(String id, List<String> taskIds) async {
    try {
      await remoteDataSource.assignTasks(id, taskIds);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeTask(String id, String taskId) async {
    try {
      await remoteDataSource.removeTask(id, taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SprintModel>> startSprint(String id) async {
    try {
      final sprint = await remoteDataSource.startSprint(id);
      return Right(sprint);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SprintModel>> completeSprint(String id, {bool force = false}) async {
    try {
      final sprint = await remoteDataSource.completeSprint(id, force: force);
      return Right(sprint);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SprintModel>> cancelSprint(String id) async {
    try {
      final sprint = await remoteDataSource.cancelSprint(id);
      return Right(sprint);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SprintStatsModel>> getStats(String id) async {
    try {
      final stats = await remoteDataSource.getStats(id);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to load sprint stats'));
    }
  }

  @override
  Future<Either<Failure, List<BurndownEntryModel>>> getBurndown(String id) async {
    try {
      final data = await remoteDataSource.getBurndown(id);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Failed to load burndown metrics'));
    }
  }

  @override
  Future<Either<Failure, VelocityModel>> getVelocity(String id) async {
    try {
      final velocity = await remoteDataSource.getVelocity(id);
      return Right(velocity);
    } catch (e) {
      return Left(ServerFailure('Failed to load velocity metrics'));
    }
  }
}
