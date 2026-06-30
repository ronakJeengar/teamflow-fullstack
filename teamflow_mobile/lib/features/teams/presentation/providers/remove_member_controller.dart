import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../dashboard/presentation/providers/workspaces_providers.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import 'teams_providers.dart';
import 'team_details_providers.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_team_by_id_usecase.dart';
import '../../domain/usecases/remove_member_usecase.dart';
import 'team_detail_state_notifier.dart';

class RemoveMemberController extends StateNotifier<AsyncValue<void>> {
  final RemoveMemberUseCase removeMemberUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;
  final Ref? ref;

  RemoveMemberController({
    required this.removeMemberUsecase,
    required this.teamDetailStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> removeMember({
    required String teamId,
    required String memberId,
  }) async {
    state = const AsyncLoading();

    // RemoveMemberParams matches exactly what's in remove_member_usecase.dart
    final result = await removeMemberUsecase(
      RemoveMemberParams(teamId: teamId, memberId: memberId),
    );

    result.fold(
          (failure) =>
      state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
          (_) {
        teamDetailStateNotifier.removeMember(memberId); // mirrors teamsStateNotifier.removeTeam()
        if (ref != null) {
          ref!.invalidate(myTasksProvider);
          ref!.invalidate(dashboardStatsProvider);
          ref!.invalidate(unreadNotificationsCountProvider);
          ref!.invalidate(notificationsListProvider);
          ref!.invalidate(workspacesListProvider);
          final activeWorkspaceId = ref!.read(authStateNotifierProvider).user?.activeWorkspaceId;
          if (activeWorkspaceId != null) {
            ref!.invalidate(workspaceMembersProvider(activeWorkspaceId));
          }
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