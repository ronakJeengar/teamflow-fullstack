import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/workspaces_repository.dart';
import '../datasources/workspaces_remote_datasource.dart';
import '../models/workspace_model.dart';
import '../models/workspace_member_model.dart';

class WorkspacesRepositoryImpl implements WorkspacesRepository {
  final WorkspacesRemoteDataSource remoteDataSource;

  WorkspacesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<WorkspaceModel>>> getWorkspaces() async {
    try {
      final workspaces = await remoteDataSource.getWorkspaces();
      return Right(workspaces);
    } catch (e, st) {
      debugPrint('[API Error] getWorkspaces failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> switchWorkspace(String workspaceId) async {
    try {
      await remoteDataSource.switchWorkspace(workspaceId);
      return const Right(null);
    } catch (e, st) {
      debugPrint('[API Error] switchWorkspace failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkspaceModel>> createWorkspace({required String name, required String color}) async {
    try {
      final workspace = await remoteDataSource.createWorkspace(name: name, color: color);
      return Right(workspace);
    } catch (e, st) {
      debugPrint('[API Error] createWorkspace failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkspaceModel>> updateWorkspace({required String id, required String name, required String color}) async {
    try {
      final workspace = await remoteDataSource.updateWorkspace(id: id, name: name, color: color);
      return Right(workspace);
    } catch (e, st) {
      debugPrint('[API Error] updateWorkspace failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkspace(String id) async {
    try {
      await remoteDataSource.deleteWorkspace(id);
      return const Right(null);
    } catch (e, st) {
      debugPrint('[API Error] deleteWorkspace failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceMemberModel>>> getWorkspaceMembers(String workspaceId) async {
    try {
      final members = await remoteDataSource.getWorkspaceMembers(workspaceId);
      return Right(members);
    } catch (e, st) {
      debugPrint('[API Error] getWorkspaceMembers failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkspaceMemberModel>> addWorkspaceMember(String workspaceId, {required String email, required String role}) async {
    try {
      final member = await remoteDataSource.addWorkspaceMember(workspaceId, email: email, role: role);
      return Right(member);
    } catch (e, st) {
      debugPrint('[API Error] addWorkspaceMember failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkspaceMemberModel>> updateWorkspaceMemberRole(String workspaceId, {required String memberId, required String role}) async {
    try {
      final member = await remoteDataSource.updateWorkspaceMemberRole(workspaceId, memberId: memberId, role: role);
      return Right(member);
    } catch (e, st) {
      debugPrint('[API Error] updateWorkspaceMemberRole failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeWorkspaceMember(String workspaceId, String memberId) async {
    try {
      await remoteDataSource.removeWorkspaceMember(workspaceId, memberId);
      return const Right(null);
    } catch (e, st) {
      debugPrint('[API Error] removeWorkspaceMember failed: $e\n$st');
      return Left(ServerFailure(e.toString()));
    }
  }
}
