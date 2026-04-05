import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../teams/domain/entities/team_entity.dart';
import '../../../teams/domain/entities/team_member_entity.dart';

part 'team_invitation_entity.freezed.dart';

enum InvitationStatusEntity {
  PENDING,
  ACCEPTED,
  EXPIRED,
  CANCELLED,
}

@freezed
abstract class TeamInvitationEntity with _$TeamInvitationEntity {
  const factory TeamInvitationEntity({
    required String id,
    required String teamId,

    required String email,

    required TeamMemberRoleEntity role,

    required String token,

    required InvitationStatusEntity status,

    required String invitedBy,

    required String expiresAt,

    required String createdAt,

    TeamEntity? team,
  }) = _TeamInvitationEntity;
}