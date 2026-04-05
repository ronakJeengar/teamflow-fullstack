import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';

import '../models/team_model.dart';

abstract class TeamRemoteDataSource {
  /// Create Team
  Future<Team> createTeam({required String name, String? description});

  /// Get All Teams
  Future<List<Team>> getTeams();

  /// Get Team By ID
  Future<Team> getTeamById(String teamId);

  /// Update Team
  Future<Team> updateTeam({
    required String teamId,
    required String name,
    String? description,
  });

  /// Delete Team
  Future<void> deleteTeam(String teamId);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final ApiService apiService;

  TeamRemoteDataSourceImpl(this.apiService);

  /// CREATE TEAM
  @override
  Future<Team> createTeam({required String name, String? description}) async {
    try {
      final response = await apiService.post<Team>(
        ApiEndpoints.createTeam,
        body: {'name': name, 'description': description},
        fromJson: (json) => Team.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to create team',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected server error');
    }
  }

  /// GET TEAMS
  @override
  Future<List<Team>> getTeams() async {
    try {
      final response = await apiService.get<List<Team>>(
        ApiEndpoints.getTeams,
        fromJson: (json) =>
            (json as List).map((e) => Team.fromJson(e)).toList(),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        return [];
      }
    } catch (e) {
      throw ServerException('Failed to fetch teams');
    }
  }

  /// GET TEAM BY ID
  @override
  Future<Team> getTeamById(String teamId) async {
    try {
      final response = await apiService.get<Team>(
        '${ApiEndpoints.getTeamById}$teamId',
        fromJson: (json) => Team.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        throw ServerException(
          response.message.isNotEmpty ? response.message : 'Team not found',
        );
      }
    } catch (e) {
      throw ServerException('Failed to fetch team');
    }
  }

  /// UPDATE TEAM
  @override
  Future<Team> updateTeam({
    required String teamId,
    required String name,
    String? description,
  }) async {
    try {
      final response = await apiService.put<Team>(
        '${ApiEndpoints.updateTeam}$teamId',
        body: {'name': name, 'description': description},
        fromJson: (json) => Team.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update team',
        );
      }
    } catch (e) {
      throw ServerException('Update team failed');
    }
  }

  /// DELETE TEAM
  @override
  Future<void> deleteTeam(String teamId) async {
    try {
      final response = await apiService.delete(
        '${ApiEndpoints.deleteTeam}$teamId',
        fromJson: (_) => {},
      );

      if (!response.status) {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to delete team',
        );
      }
    } catch (e) {
      throw ServerException('Delete team failed');
    }
  }
}
