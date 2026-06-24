import 'package:teamflow_mobile/features/tasks/data/models/task_model.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';

abstract class TasksRemoteDataSource {
  Future<TaskModel> createTask({
    required String title,
    String? description,
    required String projectId,
    String? assigneeId,
    String? status,
    String? priority,
  });

  Future<List<TaskModel>> getTasks(String projectId);

  Future<List<TaskModel>> getMyTasks();

  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assigneeId,
  });

  Future<void> deleteTask(String taskId);
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final ApiService apiService;

  TasksRemoteDataSourceImpl(this.apiService);

  @override
  Future<TaskModel> createTask({
    required String title,
    String? description,
    required String projectId,
    String? assigneeId,
    String? status,
    String? priority,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'description': description ?? '',
        'projectId': projectId,
      };
      if (assigneeId != null) body['assignedToId'] = assigneeId;
      if (status != null) body['status'] = status;
      if (priority != null) body['priority'] = priority;

      final response = await apiService.post<TaskModel>(
        ApiEndpoints.createTask,
        body: body,
        fromJson: (json) => TaskModel.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }

      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to create task',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected server error');
    }
  }

  @override
  Future<List<TaskModel>> getTasks(String projectId) async {
    try {
      final response = await apiService.getList<TaskModel>(
        ApiEndpoints.getTasks(projectId),
        fromJson: (json) => TaskModel.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }

      return [];
    } catch (e) {
      throw ServerException('Failed to fetch tasks');
    }
  }

  @override
  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assigneeId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (status != null) body['status'] = status;
      if (priority != null) body['priority'] = priority;
      if (assigneeId != null) body['assignedToId'] = assigneeId;

      final response = await apiService.patch<TaskModel>(
        ApiEndpoints.updateTask(taskId),
        body: body,
        fromJson: (json) => TaskModel.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }

      throw ServerException(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to update task',
      );
    } catch (e) {
      throw ServerException('Update task failed');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final response = await apiService.delete(
        ApiEndpoints.deleteTask(taskId),
        fromJson: (_) => {},
      );

      if (!response.status) {
        throw ServerException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to delete task',
        );
      }
    } catch (e) {
      throw ServerException('Delete task failed');
    }
  }

  @override
  Future<List<TaskModel>> getMyTasks() async {
    try {
      final response = await apiService.getList<TaskModel>(
        ApiEndpoints.getMyTasks,
        fromJson: (json) => TaskModel.fromJson(json),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      throw ServerException('Failed to fetch user tasks');
    }
  }
}
