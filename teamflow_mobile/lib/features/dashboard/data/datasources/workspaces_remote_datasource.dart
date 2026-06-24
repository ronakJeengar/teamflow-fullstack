import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/workspace_model.dart';

abstract class WorkspacesRemoteDataSource {
  Future<List<WorkspaceModel>> getWorkspaces();
  Future<void> switchWorkspace(String workspaceId);
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
}
