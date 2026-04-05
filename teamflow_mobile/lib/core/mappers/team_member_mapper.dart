import '../../features/teams/data/models/team_member_model.dart';
import '../../features/teams/domain/entities/team_member_entity.dart';
import 'user_mapper.dart';

extension TeamMemberModelMapper on TeamMember {
  TeamMemberEntity toEntity() {
    return TeamMemberEntity(
      id: id,
      teamId: teamId,
      userId: userId,
      role: _mapRole(role),
      joinedAt: joinedAt,
      team: null,
      user: user?.toEntity(),
    );
  }
}

extension TeamMemberEntityMapper on TeamMemberEntity {
  TeamMember toModel() {
    return TeamMember(
      id: id,
      teamId: teamId,
      userId: userId,
      role: _mapRoleBack(role),
      joinedAt: joinedAt,
      team: null,
      user: user?.toModel(),
    );
  }
}

TeamMemberRoleEntity _mapRole(TeamMemberRole role) {
  return TeamMemberRoleEntity.values.firstWhere(
        (e) => e.name == role.name,
  );
}

TeamMemberRole _mapRoleBack(
    TeamMemberRoleEntity role,
    ) {
  return TeamMemberRole.values.firstWhere(
        (e) => e.name == role.name,
  );
}