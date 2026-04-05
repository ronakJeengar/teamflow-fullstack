import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../invitation/data/models/team_invitation_model.dart';
import '../../../projects/data/models/project_model.dart';
import 'team_member_model.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';

@freezed
abstract class Team with _$Team {
  const factory Team({
    required String id,
    required String name,

    String? description,
    String? avatar,

    required String ownerId,

    @Default([])
    List<TeamMember> members,

    @Default([])
    List<Project> projects,

    @Default([])
    List<TeamInvitation> invitations,

    required String createdAt,
    required String updatedAt,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) =>
      _$TeamFromJson(json);
}