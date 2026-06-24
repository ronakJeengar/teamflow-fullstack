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
};
