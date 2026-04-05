import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../teams/data/models/team_member_model.dart';
import '../../../teams/data/models/team_model.dart';

part 'team_invitation_model.freezed.dart';
part 'team_invitation_model.g.dart';

enum InvitationStatus { PENDING, ACCEPTED, EXPIRED, CANCELLED }

@freezed
abstract class TeamInvitation with _$TeamInvitation {
  const factory TeamInvitation({
    required String id,
    required String teamId,

    required String email,

    required TeamMemberRole role,

    required String token,

    required InvitationStatus status,

    required String invitedBy,

    required String expiresAt,

    required String createdAt,

    Team? team,
  }) = _TeamInvitation;

  factory TeamInvitation.fromJson(Map<String, dynamic> json) =>
      _$TeamInvitationFromJson(json);
}
