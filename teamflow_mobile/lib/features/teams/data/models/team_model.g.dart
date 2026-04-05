// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Team _$TeamFromJson(Map<String, dynamic> json) => _Team(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  avatar: json['avatar'] as String?,
  ownerId: json['ownerId'] as String,
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  projects:
      (json['projects'] as List<dynamic>?)
          ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  invitations:
      (json['invitations'] as List<dynamic>?)
          ?.map((e) => TeamInvitation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$TeamToJson(_Team instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'avatar': instance.avatar,
  'ownerId': instance.ownerId,
  'members': instance.members,
  'projects': instance.projects,
  'invitations': instance.invitations,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
