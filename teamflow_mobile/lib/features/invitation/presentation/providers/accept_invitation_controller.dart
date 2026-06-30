import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../teams/presentation/providers/teams_providers.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../dashboard/presentation/providers/workspaces_providers.dart';
import '../../../dashboard/presentation/providers/stats_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../domain/usecases/accept_invitation_usecase.dart';
import 'invitations_state_notifier.dart';

class AcceptInvitationController extends StateNotifier<AsyncValue<void>> {
  final AcceptInvitationUseCase acceptInvitationUseCase;
  final InvitationsStateNotifier invitationsStateNotifier;
  final dynamic read;
  final dynamic invalidate;

  AcceptInvitationController({
    required this.acceptInvitationUseCase,
    required this.invitationsStateNotifier,
    required this.read,
    required this.invalidate,
  }) : super(const AsyncData(null));

  Future<void> acceptInvitation({required String token}) async {
    state = const AsyncLoading();

    final result = await acceptInvitationUseCase(
      AcceptInvitationParams(token: token),
    );

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (_) async {
        invitationsStateNotifier.markAccepted(token);

        // Invalidate workspaces list and details
        invalidate(workspacesListProvider);
        invalidate(dashboardStatsProvider);
        
        // Invalidate my tasks
        invalidate(myTasksProvider);
        
        // Invalidate notifications
        invalidate(unreadNotificationsCountProvider);
        invalidate(notificationsListProvider);
        
        // Invalidate task state
        invalidate(taskStateNotifierProvider);

        // Reload teams (which automatically updates projects list)
        await read(teamsStateNotifierProvider.notifier).loadTeams();

        // Refresh user session state
        await read(authStateNotifierProvider.notifier).refreshUserSession();

        state = const AsyncData(null);
      },
    );
  }
}
