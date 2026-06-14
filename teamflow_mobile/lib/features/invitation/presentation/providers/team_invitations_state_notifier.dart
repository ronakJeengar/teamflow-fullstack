import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/invitation_entity.dart';
import '../../domain/usecases/get_team_invitations_usecase.dart';

class TeamInvitationsState {
  final bool isLoading;
  final List<InvitationEntity> invitations;
  final String? error;

  const TeamInvitationsState({
    this.isLoading = false,
    this.invitations = const [],
    this.error,
  });

  TeamInvitationsState copyWith({
    bool? isLoading,
    List<InvitationEntity>? invitations,
    String? error,
  }) {
    return TeamInvitationsState(
      isLoading: isLoading ?? this.isLoading,
      invitations: invitations ?? this.invitations,
      error: error,
    );
  }
}

class TeamInvitationsStateNotifier
    extends StateNotifier<TeamInvitationsState> {
  final GetTeamInvitationsUseCase _getTeamInvitationsUseCase;

  TeamInvitationsStateNotifier(this._getTeamInvitationsUseCase)
      : super(const TeamInvitationsState());

  Future<void> loadTeamInvitations(String teamId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getTeamInvitationsUseCase(
      GetTeamInvitationsParams(teamId: teamId),
    );

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
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

  void clear() {
    state = const TeamInvitationsState();
  }
}