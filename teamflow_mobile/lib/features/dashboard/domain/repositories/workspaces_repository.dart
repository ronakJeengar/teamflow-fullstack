import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/workspace_model.dart';

abstract class WorkspacesRepository {
  Future<Either<Failure, List<WorkspaceModel>>> getWorkspaces();
  Future<Either<Failure, void>> switchWorkspace(String workspaceId);
}
