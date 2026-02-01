import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:teamflow_mobile/core/constants/api_endpoints.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Login user with email & password
  Future<UserModel> login(String email, String password);

  /// Logout user (optional, depends on API)
  Future<void> logout();

  /// Get current user from local storage or token
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
  Future<void> logout() async {
    try {
      // If your API has a logout endpoint, call it here
      final response = await apiService.post(
        ApiEndpoints.logout,
        body: {},
        fromJson: (_) => {},
      );

      if (!response.status) {
        throw ServerException(
          response.message.isNotEmpty ? response.message : 'Logout failed',
        );
      }
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw ServerException('Unexpected server error');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) return null;

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
}
