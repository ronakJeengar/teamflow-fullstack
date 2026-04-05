// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => _TeamMember(
  id: json['id'] as String,
  teamId: json['teamId'] as String,
  userId: json['userId'] as String,
  role: $enumDecode(_$TeamMemberRoleEnumMap, json['role']),
  joinedAt: json['joinedAt'] as String,
  team: json['team'] == null
      ? null
      : Team.fromJson(json['team'] as Map<String, dynamic>),
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TeamMemberToJson(_TeamMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'userId': instance.userId,
      'role': _$TeamMemberRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt,
      'team': instance.team,
      'user': instance.user,
    };

const _$TeamMemberRoleEnumMap = {
  TeamMemberRole.OWNER: 'OWNER',
  TeamMemberRole.ADMIN: 'ADMIN',
  TeamMemberRole.MEMBER: 'MEMBER',
  TeamMemberRole.VIEWER: 'VIEWER',
};
