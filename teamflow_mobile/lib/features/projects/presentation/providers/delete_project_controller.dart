import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../teams/presentation/providers/team_detail_state_notifier.dart';
import '../../../teams/presentation/providers/team_details_providers.dart';
import '../../../../core/di/injection.dart';
import '../../../teams/domain/usecases/get_team_by_id_usecase.dart';
import '../../../teams/presentation/providers/teams_providers.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../domain/usecases/delete_project_usecase.dart';

class DeleteProjectController extends StateNotifier<AsyncValue<void>> {
  final DeleteProjectUseCase deleteProjectUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;
  final Ref? ref;

  DeleteProjectController({
    required this.deleteProjectUsecase,
    required this.teamDetailStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> deleteProject({
    required String teamId,
    required String projectId,
  }) async {
    state = const AsyncLoading();

    final result = await deleteProjectUsecase(
      DeleteProjectParams(teamId: teamId, projectId: projectId),
    );

    result.fold(
          (failure) {
        state = AsyncError(
          mapFailureToMessage(failure),
          StackTrace.current,
        );
      },
          (_) {
        teamDetailStateNotifier.removeProject(projectId);
        if (ref != null) {
          ref!.invalidate(myTasksProvider);
          ref!.invalidate(dashboardStatsProvider);
          ref!.invalidate(unreadNotificationsCountProvider);
          ref!.invalidate(notificationsListProvider);
          ref!.read(teamsStateNotifierProvider.notifier).loadTeams();
          if (sl.isRegistered<GetTeamByIdUseCase>()) {
            ref!.read(teamDetailStateNotifierProvider.notifier).loadTeamDetail(teamId);
          }
        }
        state = const AsyncData(null);
      },
    );
  }
}
