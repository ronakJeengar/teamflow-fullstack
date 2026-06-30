import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/utils/failure_mapper.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../data/models/task_model.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../../../core/di/injection.dart';
import '../../../teams/domain/usecases/get_teams_use_case.dart';
import '../../../teams/domain/usecases/get_team_by_id_usecase.dart';
import '../../../teams/presentation/providers/teams_providers.dart';
import '../../../teams/presentation/providers/team_details_providers.dart';
import 'task_state_notifier.dart';
import 'task_providers.dart';

class UpdateTaskController extends StateNotifier<AsyncValue<void>> {
  final UpdateTaskUseCase updateTaskUseCase;
  final TasksStateNotifier taskStateNotifier;
  final Ref? ref;

  UpdateTaskController({
    required this.updateTaskUseCase,
    required this.taskStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> updateTask({
    required String projectId,
    required String taskId,
    String? title,
    String? assigneeId,
    String? priority,
    String? sprintId,
    int? storyPoints,
    String? backlogStatus,
    bool? isRecurring,
    String? recurrence,
    String? parentId,
  }) async {
    state = const AsyncLoading();

    final result = await updateTaskUseCase(
      UpdateTaskParams(
        taskId: taskId,
        title: title,
        assigneeId: assigneeId,
        priority: priority,
        sprintId: sprintId,
        storyPoints: storyPoints,
        backlogStatus: backlogStatus,
        isRecurring: isRecurring,
        recurrence: recurrence,
        parentId: parentId,
      ),
    );

    result.fold(
      (failure) {
        state = AsyncError(mapFailureToMessage(failure), StackTrace.current);
      },
      (task) {
        taskStateNotifier.replaceTask(task);
        debugPrint('[Task Updated] Task ID: ${task.id}, Assigned to: ${task.assignedToId}');
        if (ref != null) {
          ref!.invalidate(myTasksProvider);
          ref!.invalidate(dashboardStatsProvider);
          ref!.invalidate(unreadNotificationsCountProvider);
          ref!.invalidate(notificationsListProvider);
          if (sl.isRegistered<GetTeamsUseCase>()) {
            ref!.read(teamsStateNotifierProvider.notifier).loadTeams();
          }
          if (sl.isRegistered<GetTeamByIdUseCase>()) {
            final currentTeamId = ref!.read(teamDetailStateNotifierProvider).team?.id;
            if (currentTeamId != null) {
              ref!.read(teamDetailStateNotifierProvider.notifier).loadTeamDetail(currentTeamId);
            }
          }
          debugPrint('[Providers Invalidated] myTasksProvider, dashboardStatsProvider, and notification providers after task update');
        }
        state = const AsyncData(null);
      },
    );
  }

  Future<void> moveTask({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    // Find previous status before optimistic update
    final previousStatus = taskStateNotifier.state.tasks
        .firstWhere((t) => t.id == taskId)
        .status;

    // Optimistic update immediately
    taskStateNotifier.moveTask(taskId, newStatus);

    final result = await updateTaskUseCase(
      UpdateTaskParams(taskId: taskId, status: newStatus.name),
    );

    result.fold(
      (failure) {
        // Revert on failure
        taskStateNotifier.revertTask(taskId, previousStatus);
        state = AsyncError(mapFailureToMessage(failure), StackTrace.current);
      },
      (task) {
        taskStateNotifier.replaceTask(task);
        debugPrint('[Task Moved] Task ID: ${task.id}, New Status: ${task.status.name}');
        if (ref != null) {
          ref!.invalidate(myTasksProvider);
          ref!.invalidate(dashboardStatsProvider);
          ref!.invalidate(unreadNotificationsCountProvider);
          ref!.invalidate(notificationsListProvider);
          if (sl.isRegistered<GetTeamsUseCase>()) {
            ref!.read(teamsStateNotifierProvider.notifier).loadTeams();
          }
          if (sl.isRegistered<GetTeamByIdUseCase>()) {
            final currentTeamId = ref!.read(teamDetailStateNotifierProvider).team?.id;
            if (currentTeamId != null) {
              ref!.read(teamDetailStateNotifierProvider.notifier).loadTeamDetail(currentTeamId);
            }
          }
          debugPrint('[Providers Invalidated] myTasksProvider, dashboardStatsProvider, and notification providers after status move');
        }
        state = const AsyncData(null);
      },
    );
  }
}
