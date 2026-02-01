import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/user.dart';

extension UserModelMapper on UserModel {
  User toEntity() => User(
    id: id,
    name: name,
    email: email,
    role: _stringToUserRole(role),
  );

  // helper
  UserRole _stringToUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
        return UserRole.member;
      default:
        throw Exception('Unknown role: $role');
    }
  }
}

extension UserEntityMapper on User {
  UserModel toModel() => UserModel(
    id: id,
    name: name,
    email: email,
    role: _userRoleToString(role),
  );

  // helper
  String _userRoleToString(UserRole role) {
    return role.name; // enum.name returns the string like 'admin', 'user', etc.
  }
}
