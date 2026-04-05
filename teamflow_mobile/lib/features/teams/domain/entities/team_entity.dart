import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../invitation/domain/entities/team_invitation_entity.dart';
import '../../../projects/domain/entitties/project_entity.dart';
import 'team_member_entity.dart';

part 'team_entity.freezed.dart';

@freezed
abstract class TeamEntity with _$TeamEntity {
  const factory TeamEntity({
    required String id,
    required String name,

    String? description,
    String? avatar,

    required String ownerId,

    @Default([])
    List<TeamMemberEntity> members,

    @Default([])
    List<ProjectEntity> projects,

    @Default([])
    List<TeamInvitationEntity> invitations,

    required String createdAt,
    required String updatedAt,
  }) = _TeamEntity;
}