import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../domain/usecases/create_team_usecase.dart';
import 'teams_state_notifier.dart';

class CreateTeamController extends StateNotifier<AsyncValue<void>> {
  final CreateTeamUseCase createTeamUsecase;
  final TeamsStateNotifier teamsStateNotifier;
  final Ref? ref;

  CreateTeamController({
    required this.createTeamUsecase,
    required this.teamsStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> createTeam(String name, {String? description}) async {
    state = const AsyncLoading();

    final result = await createTeamUsecase(
      CreateTeamParams(name: name, description: description),
    );

    result.fold(
      (failure) =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (team) {
        teamsStateNotifier.addTeam(team);
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
