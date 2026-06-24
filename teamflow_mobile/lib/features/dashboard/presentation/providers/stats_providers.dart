import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../data/models/dashboard_stats_model.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return sl<StatsRepository>();
});

final dashboardStatsProvider = FutureProvider<DashboardStatsModel>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  final result = await repository.getDashboardStats();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});
