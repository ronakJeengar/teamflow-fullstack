// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectCount _$ProjectCountFromJson(Map<String, dynamic> json) =>
    _ProjectCount(tasks: (json['tasks'] as num).toInt());

Map<String, dynamic> _$ProjectCountToJson(_ProjectCount instance) =>
    <String, dynamic>{'tasks': instance.tasks};

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  name: json['name'] as String,
  ownerId: json['ownerId'] as String,
  createdAt: json['createdAt'] as String,
  count: json['_count'] == null
      ? null
      : ProjectCount.fromJson(json['_count'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ownerId': instance.ownerId,
  'createdAt': instance.createdAt,
  '_count': instance.count,
};
