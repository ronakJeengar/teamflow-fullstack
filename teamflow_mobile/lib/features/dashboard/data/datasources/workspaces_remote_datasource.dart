import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/workspace_model.dart';
import '../models/workspace_member_model.dart';

abstract class WorkspacesRemoteDataSource {
  Future<List<WorkspaceModel>> getWorkspaces();
  Future<void> switchWorkspace(String workspaceId);
  Future<WorkspaceModel> createWorkspace({required String name, required String color});
  Future<WorkspaceModel> updateWorkspace({required String id, required String name, required String color});
  Future<void> deleteWorkspace(String id);
  Future<List<WorkspaceMemberModel>> getWorkspaceMembers(String workspaceId);
  Future<WorkspaceMemberModel> addWorkspaceMember(String workspaceId, {required String email, required String role});
  Future<WorkspaceMemberModel> updateWorkspaceMemberRole(String workspaceId, {required String memberId, required String role});
  Future<void> removeWorkspaceMember(String workspaceId, String memberId);
}

class WorkspacesRemoteDataSourceImpl implements WorkspacesRemoteDataSource {
  final ApiService apiService;

  WorkspacesRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<WorkspaceModel>> getWorkspaces() async {
    final response = await apiService.getList<WorkspaceModel>(
      ApiEndpoints.workspaces,
      fromJson: (json) => WorkspaceModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    return [];
  }

  @override
  Future<void> switchWorkspace(String workspaceId) async {
    final response = await apiService.post(
      ApiEndpoints.switchWorkspace(workspaceId),
      body: {},
      fromJson: (_) => {},
    );
    if (!response.status) {
      throw Exception(response.message);
    }
  }

  @override
  Future<WorkspaceModel> createWorkspace({required String name, required String color}) async {
    final response = await apiService.post<WorkspaceModel>(
      ApiEndpoints.workspaces,
      body: {'name': name, 'color': color},
      fromJson: (json) => WorkspaceModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<WorkspaceModel> updateWorkspace({required String id, required String name, required String color}) async {
    final response = await apiService.patch<WorkspaceModel>(
      '${ApiEndpoints.workspaces}/$id',
      body: {'name': name, 'color': color},
      fromJson: (json) => WorkspaceModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<void> deleteWorkspace(String id) async {
    final response = await apiService.delete(
      '${ApiEndpoints.workspaces}/$id',
      fromJson: (_) => {},
    );
    if (!response.status) {
      throw Exception(response.message);
    }
  }

  @override
  Future<List<WorkspaceMemberModel>> getWorkspaceMembers(String workspaceId) async {
    final response = await apiService.getList<WorkspaceMemberModel>(
      '${ApiEndpoints.workspaces}/$workspaceId/members',
      fromJson: (json) => WorkspaceMemberModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    return [];
  }

  @override
  Future<WorkspaceMemberModel> addWorkspaceMember(String workspaceId, {required String email, required String role}) async {
    final response = await apiService.post<WorkspaceMemberModel>(
      '${ApiEndpoints.workspaces}/$workspaceId/members',
      body: {'email': email, 'role': role},
      fromJson: (json) => WorkspaceMemberModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<WorkspaceMemberModel> updateWorkspaceMemberRole(String workspaceId, {required String memberId, required String role}) async {
    final response = await apiService.patch<WorkspaceMemberModel>(
      '${ApiEndpoints.workspaces}/$workspaceId/members/$memberId',
      body: {'role': role},
      fromJson: (json) => WorkspaceMemberModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<void> removeWorkspaceMember(String workspaceId, String memberId) async {
    final response = await apiService.delete(
      '${ApiEndpoints.workspaces}/$workspaceId/members/$memberId',
      fromJson: (_) => {},
    );
    if (!response.status) {
      throw Exception(response.message);
    }
  }
}
