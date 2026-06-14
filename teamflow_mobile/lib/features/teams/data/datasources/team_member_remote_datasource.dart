import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/team_member_model.dart';

abstract class TeamMembersRemoteDataSource {
  /// Get Members
  Future<List<TeamMember>> getMembers(String teamId);

  /// Add Member
  Future<TeamMember> addMember({
    required String teamId,
    required String userId,
    required String role,
  });

  /// Update Member
  Future<TeamMember> updateMember({
    required String teamId,
    required String memberId,
    required String role,
  });

  /// Remove Member
  Future<void> removeMember({required String teamId, required String memberId});
}

class TeamMembersRemoteDataSourceImpl implements TeamMembersRemoteDataSource {
  final ApiService apiService;

  TeamMembersRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<TeamMember>> getMembers(String teamId) async {
    try {
      final response = await apiService.get<List<TeamMember>>(
        ApiEndpoints.getMembers(teamId),
        fromJson: (json) =>
            (json as List).map((e) => TeamMember.fromJson(e)).toList(),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }

      return [];
    } catch (e) {
      throw ServerException('Failed to fetch members');
    }
  }

  @override
  Future<TeamMember> addMember({
    required String teamId,
    required String userId,
    required String role,
  }) async {
    try {
      final response = await apiService.post<TeamMember>(
        ApiEndpoints.addMember(teamId),
        body: {'userId': userId, 'role': role},
        fromJson: (json) => TeamMember.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }

      throw ServerException(
        response.message.isNotEmpty ? response.message : 'Failed to add member',
      );
    } catch (e) {
      if (e is ServerException) rethrow;

      throw ServerException('Unexpected server error');
    }
  }

  @override
  Future<TeamMember> updateMember({
    required String teamId,
    required String memberId,
    required String role,
  }) async {
    try {
      final response = await apiService.patch<TeamMember>(
        ApiEndpoints.updateMember(teamId, memberId),
        body: {'role': role},
        fromJson: (json) => TeamMember.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }

      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to update member',
      );
    } catch (e) {
      throw ServerException('Update member failed');
    }
  }

  @override
  Future<void> removeMember({
    required String teamId,
    required String memberId,
  }) async {
    try {
      final response = await apiService.delete(
        ApiEndpoints.removeMember(teamId, memberId),
        fromJson: (_) => {},
      );

      if (!response.status) {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to remove member',
        );
      }
    } catch (e) {
      throw ServerException('Remove member failed');
    }
  }
}
