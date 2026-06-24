import '../../../../core/constants/api_endpoints.dart';
import '../models/activity_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/error/exceptions.dart';

abstract class ActivitiesRemoteDataSource {
  Future<List<ActivityModel>> getTaskActivities(String taskId);
  Future<List<ActivityModel>> getProjectActivities(String projectId);
}

class ActivitiesRemoteDataSourceImpl implements ActivitiesRemoteDataSource {
  final ApiService apiService;

  ActivitiesRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<ActivityModel>> getTaskActivities(String taskId) async {
    try {
      final response = await apiService.getList<ActivityModel>(
        ApiEndpoints.getTaskActivities(taskId),
        fromJson: (json) => ActivityModel.fromJson(json as Map<String, dynamic>),
      );
      if (response.status && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      throw ServerException('Failed to fetch task activities');
    }
  }

  @override
  Future<List<ActivityModel>> getProjectActivities(String projectId) async {
    try {
      final response = await apiService.getList<ActivityModel>(
        ApiEndpoints.getProjectActivities(projectId),
        fromJson: (json) => ActivityModel.fromJson(json as Map<String, dynamic>),
      );
      if (response.status && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      throw ServerException('Failed to fetch project activities');
    }
  }
}
