import '../../../../core/services/api_service.dart';
import '../models/sprint_model.dart';

abstract class SprintsRemoteDataSource {
  Future<List<SprintModel>> getSprints(String projectId);
  Future<SprintModel> createSprint(
    String projectId, {
    required String name,
    String? goal,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<SprintModel> getSprintById(String id);
  Future<SprintModel> updateSprint(
    String id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
    SprintStatus? status,
  });
  Future<void> deleteSprint(String id);
  Future<void> assignTasks(String id, List<String> taskIds);
  Future<void> removeTask(String id, String taskId);
  Future<SprintModel> startSprint(String id);
  Future<SprintModel> completeSprint(String id, {bool force = false});
  Future<SprintModel> cancelSprint(String id);
  Future<SprintStatsModel> getStats(String id);
  Future<List<BurndownEntryModel>> getBurndown(String id);
  Future<VelocityModel> getVelocity(String id);
}

class SprintsRemoteDataSourceImpl implements SprintsRemoteDataSource {
  final ApiService apiService;

  SprintsRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<SprintModel>> getSprints(String projectId) async {
    final response = await apiService.getList<SprintModel>(
      'projects/$projectId/sprints',
      fromJson: (json) => SprintModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    return [];
  }

  @override
  Future<SprintModel> createSprint(
    String projectId, {
    required String name,
    String? goal,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await apiService.post<SprintModel>(
      'projects/$projectId/sprints',
      body: {
        'name': name,
        'goal': goal,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
      fromJson: (json) => SprintModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<SprintModel> getSprintById(String id) async {
    final response = await apiService.get<SprintModel>(
      'sprints/$id',
      fromJson: (json) => SprintModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<SprintModel> updateSprint(
    String id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
    SprintStatus? status,
  }) async {
    String? statusStr(SprintStatus? s) {
      if (s == null) return null;
      switch (s) {
        case SprintStatus.ACTIVE:
          return 'ACTIVE';
        case SprintStatus.COMPLETED:
          return 'COMPLETED';
        case SprintStatus.CANCELLED:
          return 'CANCELLED';
        case SprintStatus.PLANNED:
        default:
          return 'PLANNED';
      }
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (goal != null) body['goal'] = goal;
    if (startDate != null) body['startDate'] = startDate.toIso8601String();
    if (endDate != null) body['endDate'] = endDate.toIso8601String();
    if (status != null) body['status'] = statusStr(status);

    final response = await apiService.patch<SprintModel>(
      'sprints/$id',
      body: body,
      fromJson: (json) => SprintModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<void> deleteSprint(String id) async {
    final response = await apiService.delete(
      'sprints/$id',
      fromJson: (_) => {},
    );
    if (!response.status) {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> assignTasks(String id, List<String> taskIds) async {
    final response = await apiService.post(
      'sprints/$id/tasks',
      body: {'taskIds': taskIds},
      fromJson: (_) => {},
    );
    if (!response.status) {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> removeTask(String id, String taskId) async {
    final response = await apiService.delete(
      'sprints/$id/tasks/$taskId',
      fromJson: (_) => {},
    );
    if (!response.status) {
      throw Exception(response.message);
    }
  }

  @override
  Future<SprintModel> startSprint(String id) async {
    final response = await apiService.post<SprintModel>(
      'sprints/$id/start',
      body: {},
      fromJson: (json) => SprintModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<SprintModel> completeSprint(String id, {bool force = false}) async {
    final response = await apiService.post<SprintModel>(
      'sprints/$id/complete',
      body: {'force': force},
      fromJson: (json) => SprintModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<SprintModel> cancelSprint(String id) async {
    final response = await apiService.post<SprintModel>(
      'sprints/$id/cancel',
      body: {},
      fromJson: (json) => SprintModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<SprintStatsModel> getStats(String id) async {
    final response = await apiService.get<SprintStatsModel>(
      'sprints/$id/stats',
      fromJson: (json) => SprintStatsModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<List<BurndownEntryModel>> getBurndown(String id) async {
    final response = await apiService.getList<BurndownEntryModel>(
      'sprints/$id/burndown',
      fromJson: (json) => BurndownEntryModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    return [];
  }

  @override
  Future<VelocityModel> getVelocity(String id) async {
    final response = await apiService.get<VelocityModel>(
      'sprints/$id/velocity',
      fromJson: (json) => VelocityModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
