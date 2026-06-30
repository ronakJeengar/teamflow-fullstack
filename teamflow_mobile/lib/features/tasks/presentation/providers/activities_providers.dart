import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repository/activities_repository.dart';
import '../../data/models/activity_model.dart';

final activitiesRepositoryProvider = Provider<ActivitiesRepository>((ref) {
  return sl<ActivitiesRepository>();
});

final taskActivitiesProvider = StateNotifierProvider.family<TaskActivitiesNotifier, AsyncValue<List<ActivityModel>>, String>((ref, taskId) {
  return TaskActivitiesNotifier(ref.watch(activitiesRepositoryProvider), taskId);
});

final projectActivitiesProvider = StateNotifierProvider.family<ProjectActivitiesNotifier, AsyncValue<List<ActivityModel>>, String>((ref, projectId) {
  return ProjectActivitiesNotifier(ref.watch(activitiesRepositoryProvider), projectId);
});

class TaskActivitiesNotifier extends StateNotifier<AsyncValue<List<ActivityModel>>> {
  final ActivitiesRepository repository;
  final String taskId;

  TaskActivitiesNotifier(this.repository, this.taskId) : super(const AsyncLoading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = const AsyncLoading();
    final result = await repository.getTaskActivities(taskId);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (activities) => state = AsyncData(activities),
    );
  }
}

class ProjectActivitiesNotifier extends StateNotifier<AsyncValue<List<ActivityModel>>> {
  final ActivitiesRepository repository;
  final String projectId;

  ProjectActivitiesNotifier(this.repository, this.projectId) : super(const AsyncLoading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = const AsyncLoading();
    final result = await repository.getProjectActivities(projectId);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (activities) => state = AsyncData(activities),
    );
  }
}

final workspaceActivitiesProvider = StateNotifierProvider.family<WorkspaceActivitiesNotifier, AsyncValue<List<ActivityModel>>, String>((ref, workspaceId) {
  return WorkspaceActivitiesNotifier(ref.watch(activitiesRepositoryProvider), workspaceId);
});

class WorkspaceActivitiesNotifier extends StateNotifier<AsyncValue<List<ActivityModel>>> {
  final ActivitiesRepository repository;
  final String workspaceId;

  WorkspaceActivitiesNotifier(this.repository, this.workspaceId) : super(const AsyncLoading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = const AsyncLoading();
    final result = await repository.getWorkspaceActivities(workspaceId);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (activities) => state = AsyncData(activities),
    );
  }
}
