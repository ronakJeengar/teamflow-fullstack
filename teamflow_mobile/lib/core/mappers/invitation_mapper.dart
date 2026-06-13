import '../../features/invitation/data/models/invitation_model.dart';
import '../../features/invitation/domain/entities/invitation_entity.dart';

extension InvitationModelMapper on InvitationModel {
  InvitationEntity toEntity() {
    return InvitationEntity(
      id: id,
      teamId: teamId,
      email: email,
      invitedById: invitedById,
      role: role,
      token: token,
      status: status,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      team: TeamEntity(
        id: team.id,
        name: team.name,
        avatar: team.avatar,
      ),
    );
  }
}

extension InvitationEntityMapper on InvitationEntity {
  InvitationModel toModel() {
    return InvitationModel(
      id: id,
      teamId: teamId,
      email: email,
      invitedById: invitedById,
      role: role,
      token: token,
      status: status,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      team: TeamInfo(
        id: team.id,
        name: team.name,
        avatar: team.avatar,
      ),
    );
  }
}