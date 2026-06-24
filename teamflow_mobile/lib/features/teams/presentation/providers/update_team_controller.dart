import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../domain/usecases/update_team_usecase.dart';
import 'teams_state_notifier.dart';

class UpdateTeamController extends StateNotifier<AsyncValue<void>> {
  final UpdateTeamUseCase updateTeamUsecase;
  final TeamsStateNotifier teamsStateNotifier;
  final Ref? ref;

  UpdateTeamController({
    required this.updateTeamUsecase,
    required this.teamsStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> updateTeam({required String id, required String name}) async {
    state = const AsyncLoading();

    final result = await updateTeamUsecase(
      UpdateTeamParams(teamId: id, name: name),
    );

    result.fold(
      (failure) =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (team) {
        teamsStateNotifier.replaceTeam(team);
        if (ref != null) {
          ref!.invalidate(myTasksProvider);
          ref!.invalidate(dashboardStatsProvider);
          ref!.invalidate(unreadNotificationsCountProvider);
          ref!.invalidate(notificationsListProvider);
        }
        state = const AsyncData(null);
      },
    );
  }
}