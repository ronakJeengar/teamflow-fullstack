// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) =>
    _DashboardStatsModel(
      tasksDueToday: (json['tasksDueToday'] as num).toInt(),
      inProgress: (json['inProgress'] as num).toInt(),
      inReview: (json['inReview'] as num).toInt(),
      blocked: (json['blocked'] as num).toInt(),
      completedThisWeek: (json['completedThisWeek'] as num).toInt(),
      sparklines: (json['sparklines'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
      ),
      project_count: (json['project_count'] as num?)?.toInt(),
      member_count: (json['member_count'] as num?)?.toInt(),
      team_count: (json['team_count'] as num?)?.toInt(),
      task_count: (json['task_count'] as num?)?.toInt(),
      sprintProgress: json['sprintProgress'] as Map<String, dynamic>?,
      sprintVelocity: (json['sprintVelocity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DashboardStatsModelToJson(
  _DashboardStatsModel instance,
) => <String, dynamic>{
  'tasksDueToday': instance.tasksDueToday,
  'inProgress': instance.inProgress,
  'inReview': instance.inReview,
  'blocked': instance.blocked,
  'completedThisWeek': instance.completedThisWeek,
  'sparklines': instance.sparklines,
  'project_count': instance.project_count,
  'member_count': instance.member_count,
  'team_count': instance.team_count,
  'task_count': instance.task_count,
  'sprintProgress': instance.sprintProgress,
  'sprintVelocity': instance.sprintVelocity,
};
