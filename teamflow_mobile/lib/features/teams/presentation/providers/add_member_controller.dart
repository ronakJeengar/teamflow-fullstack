import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import 'teams_providers.dart';
import 'team_details_providers.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_team_by_id_usecase.dart';
import '../../domain/usecases/add_member_usecase.dart';
import 'team_detail_state_notifier.dart';

class AddMemberController extends StateNotifier<AsyncValue<void>> {
  final AddMemberUseCase addMemberUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;
  final Ref? ref;

  AddMemberController({
    required this.addMemberUsecase,
    required this.teamDetailStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> addMember({
    required String teamId,
    required String userId,
    required String role,
  }) async {
    state = const AsyncLoading();

    // AddMemberParams matches exactly what's in add_member_usecase.dart
    final result = await addMemberUsecase(
      AddMemberParams(teamId: teamId, userId: userId, role: role),
    );

    result.fold(
          (failure) =>
      state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
          (newMember) {
        teamDetailStateNotifier.addMember(newMember); // mirrors teamsStateNotifier.addTeam()
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