import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/utils/failure_mapper.dart';
import '../../../invitation/presentation/providers/invitations_state_notifier.dart';
import '../../../teams/presentation/providers/teams_state_notifier.dart';
import '../../../teams/presentation/providers/team_detail_state_notifier.dart';
import '../../../tasks/presentation/providers/task_state_notifier.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';

import '../../domain/usecases/logout_usecase.dart';
import 'auth_state_notifier.dart';

class LogoutController extends StateNotifier<AsyncValue<void>> {
  final LogoutUseCase logoutUseCase;
  final AuthStateNotifier authStateNotifier;

  final TeamsStateNotifier teamsStateNotifier;
  final TeamDetailStateNotifier teamDetailStateNotifier;
  final TasksStateNotifier tasksStateNotifier;
  final InvitationsStateNotifier invitationsStateNotifier;
  final Ref? ref;

  LogoutController({
    required this.logoutUseCase,
    required this.authStateNotifier,
    required this.teamsStateNotifier,
    required this.teamDetailStateNotifier,
    required this.tasksStateNotifier,
    required this.invitationsStateNotifier,
    this.ref,
  }) : super(const AsyncData(null));

  Future<void> logout() async {
    state = const AsyncLoading();

    final result = await logoutUseCase();

    result.fold(
      (failure) {
        state = AsyncError(mapFailureToMessage(failure), StackTrace.current);
      },
      (_) {
        authStateNotifier.setUnauthenticated();

        teamsStateNotifier.clear();
        teamDetailStateNotifier.clear();
        tasksStateNotifier.clear();
        invitationsStateNotifier.clear();

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
