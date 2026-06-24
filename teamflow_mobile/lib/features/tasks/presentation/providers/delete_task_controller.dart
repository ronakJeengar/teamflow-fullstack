import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/utils/failure_mapper.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../../../core/di/injection.dart';
import '../../../teams/domain/usecases/get_teams_use_case.dart';
import '../../../teams/domain/usecases/get_team_by_id_usecase.dart';
import '../../../teams/presentation/providers/teams_providers.dart';
import '../../../teams/presentation/providers/team_details_providers.dart';
import 'task_state_notifier.dart';
import 'task_providers.dart';

class DeleteTaskController extends StateNotifier<AsyncValue<void>> {
  final DeleteTaskUseCase deleteTaskUseCase;
  final TasksStateNotifier taskStateNotifier;
  final Ref? ref;

  DeleteTaskController({
    required this.deleteTaskUseCase,
    required this.taskStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    state = const AsyncLoading();

    final result = await deleteTaskUseCase(DeleteTaskParams(taskId: taskId));

    result.fold(
      (failure) {
        state = AsyncError(mapFailureToMessage(failure), StackTrace.current);
      },
      (_) {
        taskStateNotifier.removeTask(taskId);
        debugPrint('[Task Deleted] Task ID: $taskId');
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
          debugPrint('[Providers Invalidated] myTasksProvider, dashboardStatsProvider, and notification providers after task deletion');
        }
        state = const AsyncData(null);
      },
    );
  }
}
