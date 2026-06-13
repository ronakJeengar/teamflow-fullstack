import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/membership_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Login user with email & password
  Future<UserModel> login(String email, String password);

  /// Signup user with email, name & password
  Future<UserModel> signup(String name, String email, String password);

  /// Logout user (optional, depends on API)
  Future<void> logout();

  Future<void> clearSession();

  /// Get current user from local storage or token
  Future<UserModel?> getCurrentUser();

  Future<List<MembershipModel>> getMyMemberships();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiService.post<UserModel>(
        ApiEndpoints.login,
        body: {'email': email, 'password': password},
        fromJson: (json) => UserModel.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        throw AuthException(
          response.message.isNotEmpty ? response.message : 'Login failed',
        );
      }
    } catch (e) {
      if (e is AuthException || e is ServerException) {
        rethrow;
      }
      throw ServerException('Unexpected server error');
    }
  }

  @override
  Future<UserModel> signup(String name, String email, String password) async {
    try {
      final response = await apiService.post<UserModel>(
        ApiEndpoints.signup,
        body: {'name': name, 'email': email, 'password': password},
        fromJson: (json) => UserModel.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        throw AuthException(
          response.message.isNotEmpty ? response.message : 'Signup failed',
        );
      }
    } catch (e) {
      if (e is AuthException || e is ServerException) {
        rethrow;
      }
      throw ServerException('Unexpected server error');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // If your API has a logout endpoint, call it here
      final response = await apiService.get(
        ApiEndpoints.logout,
        fromJson: (_) => {},
      );

      if (!response.status) {
        throw ServerException(
          response.message.isNotEmpty ? response.message : 'Logout failed',
        );
      }

      await apiService.clearCookie();
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw ServerException('Unexpected server error');
    }
  }

  @override
  Future<void> clearSession() {
    return apiService.clearCookie();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await apiService.get<UserModel>(
        ApiEndpoints.me,
        fromJson: (json) => UserModel.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MembershipModel>> getMyMemberships() async {
    try {
      final response = await apiService.getList<MembershipModel>(
        ApiEndpoints.myMemberships,
        fromJson: (json) => MembershipModel.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }

      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch memberships',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected server error');
    }
  }
}
