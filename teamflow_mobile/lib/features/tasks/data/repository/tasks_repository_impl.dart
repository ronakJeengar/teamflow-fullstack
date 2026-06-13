import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entitties/task_entity.dart';
import '../../domain/repository/tasks_repository.dart';
import '../datasources/tasks_remote_datasource.dart';
import '../models/task_model.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;

  TasksRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    required String projectId,
    String? assigneeId,
    String? status,
    String? priority,
  }) async {
    try {
      final task = await remoteDataSource.createTask(
        title: title,
        description: description,
        projectId: projectId,
        assigneeId: assigneeId,
        status: status,
        priority: priority,
      );

      return Right(task. toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(
      String projectId,
      ) async {
    try {
      final tasks = await remoteDataSource.getTasks(projectId);

      return Right(
        tasks.map((task) => task.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assigneeId,
  }) async {
    try {
      final task = await remoteDataSource.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        assigneeId: assigneeId,
      );

      return Right(task.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(
      String taskId,
      ) async {
    try {
      await remoteDataSource.deleteTask(taskId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}