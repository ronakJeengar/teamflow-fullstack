import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats_model.freezed.dart';
part 'dashboard_stats_model.g.dart';

@freezed
abstract class DashboardStatsModel with _$DashboardStatsModel {
  const factory DashboardStatsModel({
    required int tasksDueToday,
    required int inProgress,
    required int inReview,
    required int blocked,
    required int completedThisWeek,
    Map<String, List<int>>? sparklines,
  }) = _DashboardStatsModel;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);
}
