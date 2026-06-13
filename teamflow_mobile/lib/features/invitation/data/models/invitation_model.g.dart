// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvitationModel _$InvitationModelFromJson(Map<String, dynamic> json) =>
    _InvitationModel(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      email: json['email'] as String,
      invitedById: json['invitedById'] as String,
      role: json['role'] as String,
      token: json['token'] as String,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      team: TeamInfo.fromJson(json['team'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InvitationModelToJson(_InvitationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'email': instance.email,
      'invitedById': instance.invitedById,
      'role': instance.role,
      'token': instance.token,
      'status': instance.status,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'team': instance.team,
    };

_TeamInfo _$TeamInfoFromJson(Map<String, dynamic> json) => _TeamInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$TeamInfoToJson(_TeamInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar': instance.avatar,
};
