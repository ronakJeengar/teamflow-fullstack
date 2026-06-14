// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MembershipModel _$MembershipModelFromJson(Map<String, dynamic> json) =>
    _MembershipModel(
      role: json['role'] as String,
      team: MembershipTeamModel.fromJson(json['team'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MembershipModelToJson(_MembershipModel instance) =>
    <String, dynamic>{'role': instance.role, 'team': instance.team};

_MembershipTeamModel _$MembershipTeamModelFromJson(Map<String, dynamic> json) =>
    _MembershipTeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$MembershipTeamModelToJson(
  _MembershipTeamModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar': instance.avatar,
};
