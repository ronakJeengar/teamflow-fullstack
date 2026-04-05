import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/user_entity.dart';

/// MODEL → ENTITY
extension UserModelMapper on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: _stringToUserRole(role),
    );
  }
}

/// ENTITY → MODEL
extension UserEntityMapper on UserEntity {
  UserModel toModel() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      role: _userRoleToString(role),
    );
  }
}

/// String → Enum
UserRole _stringToUserRole(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return UserRole.admin;

    case 'member':
    case 'user':
      return UserRole.member;

    default:
      throw Exception('Unknown role: $role');
  }
}

/// Enum → String
String _userRoleToString(UserRole role) {
  return role.name;
}