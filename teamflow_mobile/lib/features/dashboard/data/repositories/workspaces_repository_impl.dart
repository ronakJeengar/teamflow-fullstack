import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/workspaces_repository.dart';
import '../datasources/workspaces_remote_datasource.dart';
import '../models/workspace_model.dart';

class WorkspacesRepositoryImpl implements WorkspacesRepository {
  final WorkspacesRemoteDataSource remoteDataSource;

  WorkspacesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<WorkspaceModel>>> getWorkspaces() async {
    try {
      final workspaces = await remoteDataSource.getWorkspaces();
      return Right(workspaces);
    } catch (e) {
      return Left(ServerFailure('Failed to load workspaces'));
    }
  }

  @override
  Future<Either<Failure, void>> switchWorkspace(String workspaceId) async {
    try {
      await remoteDataSource.switchWorkspace(workspaceId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to switch workspace'));
    }
  }
}
