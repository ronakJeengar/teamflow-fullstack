import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/workspace_model.dart';
import '../../data/models/workspace_member_model.dart';

abstract class WorkspacesRepository {
  Future<Either<Failure, List<WorkspaceModel>>> getWorkspaces();
  Future<Either<Failure, void>> switchWorkspace(String workspaceId);
  Future<Either<Failure, WorkspaceModel>> createWorkspace({required String name, required String color});
  Future<Either<Failure, WorkspaceModel>> updateWorkspace({required String id, required String name, required String color});
  Future<Either<Failure, void>> deleteWorkspace(String id);
  Future<Either<Failure, List<WorkspaceMemberModel>>> getWorkspaceMembers(String workspaceId);
  Future<Either<Failure, WorkspaceMemberModel>> addWorkspaceMember(String workspaceId, {required String email, required String role});
  Future<Either<Failure, WorkspaceMemberModel>> updateWorkspaceMemberRole(String workspaceId, {required String memberId, required String role});
  Future<Either<Failure, void>> removeWorkspaceMember(String workspaceId, String memberId);
}
