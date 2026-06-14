import 'package:teamflow_mobile/features/projects/data/models/project_model.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';

abstract class ProjectsRemoteDataSource {
  /// Create Project
  Future<Project> createProject({
    required String teamId,
    required String name,
    String? description,
  });

  /// Get All Projects By Team
  Future<List<Project>> getProjectsByTeamId(String teamId);

  /// Update Project
  Future<Project> updateProject({
    required String teamId,
    required String projectId,
    required String name,
    String? description,
  });

  /// Delete Project
  Future<void> deleteProject({
    required String teamId,
    required String projectId,
  });
}

class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  final ApiService apiService;

  ProjectsRemoteDataSourceImpl(this.apiService);

  /// CREATE PROJECT
  @override
  Future<Project> createProject({
    required String teamId,
    required String name,
    String? description,
  }) async {
    try {
      final response = await apiService.post<Project>(
        ApiEndpoints.createProject(teamId),
        body: {
          'name': name,
          'description': description,
        },
        fromJson: (json) => Project.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to create project',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected server error');
    }
  }

  /// GET PROJECTS
  @override
  Future<List<Project>> getProjectsByTeamId(String teamId) async {
    try {
      final response = await apiService.get<List<Project>>(
        ApiEndpoints.getProjects(teamId),
        fromJson: (json) =>
            (json as List)
                .map((e) => Project.fromJson(e))
                .toList(),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        return [];
      }
    } catch (e) {
      throw ServerException('Failed to fetch projects');
    }
  }

  /// UPDATE PROJECT
  @override
  Future<Project> updateProject({
    required String teamId,
    required String projectId,
    required String name,
    String? description,
  }) async {
    try {
      final response = await apiService.patch<Project>(
        ApiEndpoints.updateProject(teamId, projectId),
        body: {
          'name': name,
          'description': description,
        },
        fromJson: (json) => Project.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update project',
        );
      }
    } catch (e) {
      throw ServerException('Update project failed');
    }
  }

  /// DELETE PROJECT
  @override
  Future<void> deleteProject({
    required String teamId,
    required String projectId,
  }) async {
    try {
      final response = await apiService.delete(
        ApiEndpoints.deleteProject(teamId, projectId),
        fromJson: (_) => {},
      );

      if (!response.status) {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to delete project',
        );
      }
    } catch (e) {
      throw ServerException('Delete project failed');
    }
  }
}