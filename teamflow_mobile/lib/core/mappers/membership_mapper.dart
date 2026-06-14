import '../../features/auth/data/models/membership_model.dart';
import '../../features/auth/domain/entities/membership_entity.dart';

extension MembershipModelMapper on MembershipModel {
  MembershipEntity toEntity() {
    return MembershipEntity(
      role: role,
      team: MembershipTeamEntity(
        id: team.id,
        name: team.name,
        avatar: team.avatar,
      ),
    );
  }
}

extension MembershipEntityMapper on MembershipEntity {
  MembershipModel toModel() {
    return MembershipModel(
      role: role,
      team: MembershipTeamModel(
        id: team.id,
        name: team.name,
        avatar: team.avatar,
      ),
    );
  }
}
