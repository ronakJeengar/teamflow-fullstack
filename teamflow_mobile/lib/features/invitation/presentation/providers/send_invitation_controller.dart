import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/send_invitation_usecase.dart';
import 'invitations_state_notifier.dart';

class SendInvitationController extends StateNotifier<AsyncValue<void>> {
  final SendInvitationUseCase sendInvitationUseCase;
  final InvitationsStateNotifier invitationsStateNotifier;

  SendInvitationController({
    required this.sendInvitationUseCase,
    required this.invitationsStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> sendInvitation({
    required String teamId,
    required String email,
    required String role,
  }) async {
    state = const AsyncLoading();

    final result = await sendInvitationUseCase(
      SendInvitationParams(teamId: teamId, email: email, role: role),
    );

    result.fold(
      (failure) =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (_) async {
        await invitationsStateNotifier.loadInvitations();

        state = const AsyncData(null);
      },
    );
  }
}
