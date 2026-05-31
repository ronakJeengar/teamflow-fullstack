import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';

abstract class InvitationsRemoteDataSource {
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
}

class InvitationsRemoteDataSourceImpl
    implements InvitationsRemoteDataSource {
  final ApiService apiService;

  InvitationsRemoteDataSourceImpl(this.apiService);

  @override
  Future<void> sendInvitation({
    required String teamId,
    required String email,
    required String role,
  }) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.sendInvitation(teamId),
        body: {
          'email': email,
          'role': role,
        },
        fromJson: (_) => {},
      );

      if (!response.status) {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to send invitation',
        );
      }
    } catch (e) {
      throw ServerException('Send invitation failed');
    }
  }

  @override
  Future<void> acceptInvitation(String token) async {
    try {
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
    } catch (e) {
      throw ServerException('Accept invitation failed');
    }
  }

  @override
  Future<void> cancelInvitation({
    required String teamId,
    required String token,
  }) async {
    try {
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
    } catch (e) {
      throw ServerException('Cancel invitation failed');
    }
  }
}