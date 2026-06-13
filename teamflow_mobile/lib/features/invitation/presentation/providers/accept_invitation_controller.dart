import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../teams/presentation/providers/teams_state_notifier.dart';
import '../../domain/usecases/accept_invitation_usecase.dart';
import 'invitations_state_notifier.dart';

class AcceptInvitationController extends StateNotifier<AsyncValue<void>> {
  final AcceptInvitationUseCase acceptInvitationUseCase;
  final InvitationsStateNotifier invitationsStateNotifier;
  final TeamsStateNotifier teamsStateNotifier;

  AcceptInvitationController({
    required this.acceptInvitationUseCase,
    required this.invitationsStateNotifier,
    required this.teamsStateNotifier,
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

        // refresh teams because user joined a new team
        await teamsStateNotifier.loadTeams();

        state = const AsyncData(null);
      },
    );
  }
}
