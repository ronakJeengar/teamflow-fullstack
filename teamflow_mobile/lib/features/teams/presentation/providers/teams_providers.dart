import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/create_team_usecase.dart';
import '../../domain/usecases/get_teams_use_case.dart';
import '../../domain/usecases/update_team_usecase.dart';
import '../../domain/usecases/delete_team_usecase.dart';
import 'create_team_controller.dart';
import 'delete_team_controller.dart';
import 'teams_state_notifier.dart';
import 'update_team_controller.dart';

// ── Core state — mirrors authStateNotifierProvider ────────────────────────────

final teamsStateNotifierProvider =
    StateNotifierProvider<TeamsStateNotifier, TeamsState>(
      (ref) => TeamsStateNotifier(sl<GetTeamsUseCase>()),
    );

// ── Mutation controllers — mirror loginControllerProvider ─────────────────────

final createTeamControllerProvider =
    StateNotifierProvider<CreateTeamController, AsyncValue<void>>(
      (ref) => CreateTeamController(
        createTeamUsecase: sl<CreateTeamUseCase>(),
        teamsStateNotifier: ref.read(teamsStateNotifierProvider.notifier),
      ),
    );

final updateTeamControllerProvider =
    StateNotifierProvider<UpdateTeamController, AsyncValue<void>>(
      (ref) => UpdateTeamController(
        updateTeamUsecase: sl<UpdateTeamUseCase>(),
        teamsStateNotifier: ref.read(teamsStateNotifierProvider.notifier),
      ),
    );

final deleteTeamControllerProvider =
    StateNotifierProvider<DeleteTeamController, AsyncValue<void>>(
      (ref) => DeleteTeamController(
        deleteTeamUsecase: sl<DeleteTeamUseCase>(),
        teamsStateNotifier: ref.read(teamsStateNotifierProvider.notifier),
      ),
    );
