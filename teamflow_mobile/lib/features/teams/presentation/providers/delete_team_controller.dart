import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../domain/usecases/delete_team_usecase.dart';
import 'teams_state_notifier.dart';

class DeleteTeamController extends StateNotifier<AsyncValue<void>> {
  final DeleteTeamUseCase deleteTeamUsecase;
  final TeamsStateNotifier teamsStateNotifier;
  final Ref? ref;

  DeleteTeamController({
    required this.deleteTeamUsecase,
    required this.teamsStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> deleteTeam(String id) async {
    state = const AsyncLoading();

    final result = await deleteTeamUsecase(DeleteTeamParams(id));

    await result.fold(
      (failure) async =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (_) async {
        teamsStateNotifier.removeTeam(
          id,
        ); // mirrors authStateNotifier.setUnauthenticated()
        if (ref != null) {
          ref!.invalidate(myTasksProvider);
          ref!.invalidate(dashboardStatsProvider);
          ref!.invalidate(unreadNotificationsCountProvider);
          ref!.invalidate(notificationsListProvider);
          await ref!.read(authStateNotifierProvider.notifier).refreshMemberships();
        }
        state = const AsyncData(null);
      },
    );
  }
}
