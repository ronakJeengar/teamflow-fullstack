import 'package:hooks_riverpod/legacy.dart';

import '../../domain/entities/invitation_entity.dart';
import '../../domain/usecases/my_invitations_usecase.dart';

class InvitationsState {
  final bool isLoading;
  final List<InvitationEntity> invitations;
  final String? error;

  const InvitationsState({
    this.isLoading = false,
    this.invitations = const [],
    this.error,
  });

  InvitationsState copyWith({
    bool? isLoading,
    List<InvitationEntity>? invitations,
    String? error,
  }) {
    return InvitationsState(
      isLoading: isLoading ?? this.isLoading,
      invitations: invitations ?? this.invitations,
      error: error,
    );
  }
}

class InvitationsStateNotifier extends StateNotifier<InvitationsState> {
  final MyInvitationsUseCase myInvitationsUseCase;

  InvitationsStateNotifier(this.myInvitationsUseCase)
      : super(const InvitationsState());

  Future<void> loadInvitations() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final result = await myInvitationsUseCase();

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
          (invitations) {
        state = state.copyWith(
          isLoading: false,
          invitations: invitations,
          error: null,
        );
      },
    );
  }

  /// Accept invitation locally
  void markAccepted(String token) {
    state = state.copyWith(
      invitations: state.invitations.map((invitation) {
        if (invitation.token == token) {
          return invitation.copyWith(
            status: 'ACCEPTED',
          );
        }
        return invitation;
      }).toList(),
    );
  }

  /// Remove cancelled invitation
  void removeInvitation(String token) {
    state = state.copyWith(
      invitations: state.invitations
          .where((invitation) => invitation.token != token)
          .toList(),
    );
  }

  /// Add new invitation
  void addInvitation(InvitationEntity invitation) {
    state = state.copyWith(
      invitations: [
        invitation,
        ...state.invitations,
      ],
    );
  }

  void clear() {
    state = const InvitationsState();
  }
}