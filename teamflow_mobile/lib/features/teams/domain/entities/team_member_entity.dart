import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import 'team_entity.dart';

part 'team_member_entity.freezed.dart';

enum TeamMemberRoleEntity {
  OWNER,
  ADMIN,
  MEMBER,
  VIEWER,
}

@freezed
abstract class TeamMemberEntity with _$TeamMemberEntity {
  const factory TeamMemberEntity({
    required String id,
    required String teamId,
    required String userId,

    required TeamMemberRoleEntity role,

    required String joinedAt,

    TeamEntity? team,
    UserEntity? user,
  }) = _TeamMemberEntity;
}