import '../../features/invitation/data/models/team_invitation_model.dart';
import '../../features/invitation/domain/entities/team_invitation_entity.dart';
import '../../features/teams/data/models/team_member_model.dart';
import '../../features/teams/domain/entities/team_member_entity.dart';

extension TeamInvitationModelMapper on TeamInvitation {
  TeamInvitationEntity toEntity() {
    return TeamInvitationEntity(
      id: id,
      teamId: teamId,
      email: email,
      role: _mapRole(role),
      token: token,
      status: _mapStatus(status),
      invitedBy: invitedBy,
      expiresAt: expiresAt,
      createdAt: createdAt,
      team: null,
    );
  }
}

extension TeamInvitationEntityMapper on TeamInvitationEntity {
  TeamInvitation toModel() {
    return TeamInvitation(
      id: id,
      teamId: teamId,
      email: email,
      role: _mapRoleBack(role),
      token: token,
      status: _mapStatusBack(status),
      invitedBy: invitedBy,
      expiresAt: expiresAt,
      createdAt: createdAt,
      team: null,
    );
  }
}

InvitationStatusEntity _mapStatus(InvitationStatus status) {
  return InvitationStatusEntity.values.firstWhere((e) => e.name == status.name);
}

InvitationStatus _mapStatusBack(InvitationStatusEntity status) {
  return InvitationStatus.values.firstWhere((e) => e.name == status.name);
}

TeamMemberRoleEntity _mapRole(TeamMemberRole role) {
  return TeamMemberRoleEntity.values.firstWhere((e) => e.name == role.name);
}

TeamMemberRole _mapRoleBack(TeamMemberRoleEntity role) {
  return TeamMemberRole.values.firstWhere((e) => e.name == role.name);
}
