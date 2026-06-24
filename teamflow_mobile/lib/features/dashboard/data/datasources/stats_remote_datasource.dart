import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/dashboard_stats_model.dart';

abstract class StatsRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  final ApiService apiService;

  StatsRemoteDataSourceImpl(this.apiService);

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    final response = await apiService.get<DashboardStatsModel>(
      ApiEndpoints.dashboardStats,
      fromJson: (json) => DashboardStatsModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
