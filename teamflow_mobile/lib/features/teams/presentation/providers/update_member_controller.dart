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
import '../../domain/usecases/update_member_usecase.dart';
import 'team_detail_state_notifier.dart';

class UpdateMemberController extends StateNotifier<AsyncValue<void>> {
  final UpdateMemberUseCase updateMemberUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;
  final Ref? ref;

  UpdateMemberController({
    required this.updateMemberUsecase,
    required this.teamDetailStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> updateMember({
    required String teamId,
    required String memberId,
    required String role,
  }) async {
    state = const AsyncLoading();

    // UpdateMemberParams matches exactly what's in update_member_usecase.dart
    final result = await updateMemberUsecase(
      UpdateMemberParams(teamId: teamId, memberId: memberId, role: role),
    );

    result.fold(
          (failure) =>
      state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
          (updatedMember) {
        // UpdateMemberUseCase returns TeamMemberEntity so we replace the whole object
        // mirrors teamsStateNotifier.replaceTeam()
        teamDetailStateNotifier.replaceMember(updatedMember);
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