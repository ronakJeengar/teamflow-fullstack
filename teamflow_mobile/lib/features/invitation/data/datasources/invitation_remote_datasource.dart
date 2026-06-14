import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/invitation_model.dart';

abstract class InvitationRemoteDataSource {
  Future<void> sendInvitation({
    required String teamId,
    required String email,
    required String role,
  });

  Future<void> acceptInvitation(String token);

  Future<void> cancelInvitation({
    required String teamId,
    required String token,
  });

  Future<List<InvitationModel>> getMyInvitations();

  Future<List<InvitationModel>> getTeamInvitations(String teamId);
}

class InvitationsRemoteDataSourceImpl implements InvitationRemoteDataSource {
  final ApiService apiService;

  InvitationsRemoteDataSourceImpl(this.apiService);

  @override
  Future<void> sendInvitation({
    required String teamId,
    required String email,
    required String role,
  }) async {
    // POST /:teamId/invitations
    final response = await apiService.post(
      ApiEndpoints.sendInvitation(teamId),
      body: {'email': email, 'role': role},
      fromJson: (_) => {},
    );

    if (!response.status) {
      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to send invitation',
      );
    }
  }

  @override
  Future<void> acceptInvitation(String token) async {
    // POST /accept/:token
    final response = await apiService.post(
      ApiEndpoints.acceptInvitation(token),
      body: {},
      fromJson: (_) => {},
    );

    if (!response.status) {
      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to accept invitation',
      );
    }
  }

  @override
  Future<void> cancelInvitation({
    required String teamId,
    required String token,
  }) async {
    // DELETE /:teamId/invitations/:token
    final response = await apiService.delete(
      ApiEndpoints.cancelInvitation(teamId, token),
      fromJson: (_) => {},
    );

    if (!response.status) {
      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to cancel invitation',
      );
    }
  }

  @override
  Future<List<InvitationModel>> getMyInvitations() async {
    // GET /my
    final response = await apiService.get(
      ApiEndpoints.getMyInvitations,
      fromJson: (json) => json,
    );

    if (!response.status) {
      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch invitations',
      );
    }

    final invitations = response.data['invitations'] as List;
    return invitations.map((e) => InvitationModel.fromJson(e)).toList();
  }

  @override
  Future<List<InvitationModel>> getTeamInvitations(String teamId) async {
    // GET /:teamId/invitations
    final response = await apiService.get(
      ApiEndpoints.getTeamInvitations(teamId),
      fromJson: (json) => json,
    );

    if (!response.status) {
      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch team invitations',
      );
    }

    final invitations = response.data['invitations'] as List;
    return invitations.map((e) => InvitationModel.fromJson(e)).toList();
  }
}