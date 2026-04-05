// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamInvitation _$TeamInvitationFromJson(Map<String, dynamic> json) =>
    _TeamInvitation(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$TeamMemberRoleEnumMap, json['role']),
      token: json['token'] as String,
      status: $enumDecode(_$InvitationStatusEnumMap, json['status']),
      invitedBy: json['invitedBy'] as String,
      expiresAt: json['expiresAt'] as String,
      createdAt: json['createdAt'] as String,
      team: json['team'] == null
          ? null
          : Team.fromJson(json['team'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeamInvitationToJson(_TeamInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'email': instance.email,
      'role': _$TeamMemberRoleEnumMap[instance.role]!,
      'token': instance.token,
      'status': _$InvitationStatusEnumMap[instance.status]!,
      'invitedBy': instance.invitedBy,
      'expiresAt': instance.expiresAt,
      'createdAt': instance.createdAt,
      'team': instance.team,
    };

const _$TeamMemberRoleEnumMap = {
  TeamMemberRole.OWNER: 'OWNER',
  TeamMemberRole.ADMIN: 'ADMIN',
  TeamMemberRole.MEMBER: 'MEMBER',
  TeamMemberRole.VIEWER: 'VIEWER',
};

const _$InvitationStatusEnumMap = {
  InvitationStatus.PENDING: 'PENDING',
  InvitationStatus.ACCEPTED: 'ACCEPTED',
  InvitationStatus.EXPIRED: 'EXPIRED',
  InvitationStatus.CANCELLED: 'CANCELLED',
};
