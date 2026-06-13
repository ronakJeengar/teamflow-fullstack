import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../domain/usecases/cancel_invitation_usecase.dart';
import 'invitations_state_notifier.dart';

class CancelInvitationController extends StateNotifier<AsyncValue<void>> {
  final CancelInvitationUseCase cancelInvitationUseCase;
  final InvitationsStateNotifier invitationsStateNotifier;

  CancelInvitationController({
    required this.cancelInvitationUseCase,
    required this.invitationsStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> cancelInvitation({
    required String teamId,
    required String token,
  }) async {
    state = const AsyncLoading();

    final result = await cancelInvitationUseCase(
      CancelInvitationParams(teamId: teamId, token: token),
    );

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (_) {
        invitationsStateNotifier.removeInvitation(token);

        state = const AsyncData(null);
      },
    );
  }
}
