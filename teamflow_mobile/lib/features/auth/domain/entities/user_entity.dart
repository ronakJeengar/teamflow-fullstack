import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

enum UserRole { admin, member }

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  }) = _UserEntity;
}
