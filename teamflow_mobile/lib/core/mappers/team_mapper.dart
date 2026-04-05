import 'package:teamflow_mobile/core/mappers/team_invitation_mapper.dart';
import '../../features/teams/data/models/team_model.dart';
import '../../features/teams/domain/entities/team_entity.dart';
import 'team_member_mapper.dart';
import 'project_mapper.dart';

extension TeamModelMapper on Team {
  TeamEntity toEntity() {
    return TeamEntity(
      id: id,
      name: name,
      description: description,
      avatar: avatar,
      ownerId: ownerId,
      members: members.map((e) => e.toEntity()).toList(),
      projects: projects.map((e) => e.toEntity()).toList(),
      invitations: invitations.map((e) => e.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension TeamEntityMapper on TeamEntity {
  Team toModel() {
    return Team(
      id: id,
      name: name,
      description: description,
      avatar: avatar,
      ownerId: ownerId,
      members: members.map((e) => e.toModel()).toList(),
      projects: projects.map((e) => e.toModel()).toList(),
      invitations: invitations.map((e) => e.toModel()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
