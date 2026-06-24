import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/dashboard_stats_model.dart';

abstract class StatsRepository {
  Future<Either<Failure, DashboardStatsModel>> getDashboardStats();
}
