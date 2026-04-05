import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/data/models/user_model.dart';
import 'team_model.dart';

part 'team_member_model.freezed.dart';
part 'team_member_model.g.dart';

enum TeamMemberRole {
  OWNER,
  ADMIN,
  MEMBER,
  VIEWER,
}

@freezed
abstract class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String id,
    required String teamId,
    required String userId,

    required TeamMemberRole role,

    required String joinedAt,

    Team? team,
    UserModel? user,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);
}