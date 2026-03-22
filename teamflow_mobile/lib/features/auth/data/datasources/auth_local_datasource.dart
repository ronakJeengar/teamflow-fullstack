import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  @override
  Future<void> saveAccessToken(String token) {
    return storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> getAccessToken() {
    return storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }
}
