import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/di/injection.dart';

import '../../../teams/presentation/providers/teams_providers.dart';
import '../../domain/usecases/my_invitations_usecase.dart';
import '../../domain/usecases/send_invitation_usecase.dart';
import '../../domain/usecases/accept_invitation_usecase.dart';
import '../../domain/usecases/cancel_invitation_usecase.dart';
import '../../domain/usecases/get_team_invitations_usecase.dart';

import 'invitations_state_notifier.dart';
import 'team_invitations_state_notifier.dart';
import 'send_invitation_controller.dart';
import 'accept_invitation_controller.dart';
import 'cancel_invitation_controller.dart';

// ── My Invitations ─────────────────────────────────────

final invitationsStateNotifierProvider =
    StateNotifierProvider<InvitationsStateNotifier, InvitationsState>(
      (ref) => InvitationsStateNotifier(sl<MyInvitationsUseCase>()),
    );

// ── Team Invitations ───────────────────────────────────

final teamInvitationsStateNotifierProvider =
    StateNotifierProvider<TeamInvitationsStateNotifier, TeamInvitationsState>(
      (ref) => TeamInvitationsStateNotifier(sl<GetTeamInvitationsUseCase>()),
    );

// ── Send Invitation ────────────────────────────────────

final sendInvitationControllerProvider =
    StateNotifierProvider<SendInvitationController, AsyncValue<void>>(
      (ref) => SendInvitationController(
        sendInvitationUseCase: sl<SendInvitationUseCase>(),
        invitationsStateNotifier: ref.read(
          invitationsStateNotifierProvider.notifier,
        ),
      ),
    );

// ── Accept Invitation ──────────────────────────────────

final acceptInvitationControllerProvider =
    StateNotifierProvider<AcceptInvitationController, AsyncValue<void>>(
      (ref) => AcceptInvitationController(
        acceptInvitationUseCase: sl<AcceptInvitationUseCase>(),
        invitationsStateNotifier: ref.read(
          invitationsStateNotifierProvider.notifier,
        ),
        teamsStateNotifier: ref.read(teamsStateNotifierProvider.notifier),
      ),
    );
// ── Cancel Invitation ──────────────────────────────────

final cancelInvitationControllerProvider =
    StateNotifierProvider<CancelInvitationController, AsyncValue<void>>(
      (ref) => CancelInvitationController(
        cancelInvitationUseCase: sl<CancelInvitationUseCase>(),
        invitationsStateNotifier: ref.read(
          invitationsStateNotifierProvider.notifier,
        ),
      ),
    );
