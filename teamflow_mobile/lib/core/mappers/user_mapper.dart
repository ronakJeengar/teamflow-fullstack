import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/user_entity.dart';

/// MODEL → ENTITY
extension UserModelMapper on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      bio: bio,
      activeWorkspaceId: activeWorkspaceId,
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
      avatar: avatar,
      bio: bio,
      activeWorkspaceId: activeWorkspaceId,
    );
  }
}