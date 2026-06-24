import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repository/activities_repository.dart';
import '../datasources/activities_remote_datasource.dart';
import '../models/activity_model.dart';

class ActivitiesRepositoryImpl implements ActivitiesRepository {
  final ActivitiesRemoteDataSource remoteDataSource;

  ActivitiesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ActivityModel>>> getTaskActivities(String taskId) async {
    try {
      final activities = await remoteDataSource.getTaskActivities(taskId);
      return Right(activities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ActivityModel>>> getProjectActivities(String projectId) async {
    try {
      final activities = await remoteDataSource.getProjectActivities(projectId);
      return Right(activities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
