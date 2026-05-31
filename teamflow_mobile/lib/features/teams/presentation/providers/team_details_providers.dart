import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../../projects/domain/usecases/creaet_project_usecase.dart';
import '../../../projects/domain/usecases/delete_project_usecase.dart';
import '../../../projects/domain/usecases/get_projects_usecase.dart';
import '../../../projects/domain/usecases/update_project_usecase.dart';
import '../../../projects/presentation/providers/create_project_controller.dart';
import '../../../projects/presentation/providers/delete_project_controller.dart';
import '../../../projects/presentation/providers/update_project_controller.dart';
import '../../domain/usecases/get_team_by_id_usecase.dart';
import '../../domain/usecases/get_members_usecase.dart';
import '../../domain/usecases/add_member_usecase.dart';
import '../../domain/usecases/remove_member_usecase.dart';
import '../../domain/usecases/update_member_usecase.dart';
import 'team_detail_state_notifier.dart';
import 'add_member_controller.dart';
import 'remove_member_controller.dart';
import 'update_member_controller.dart';

// ── Core state — mirrors teamsStateNotifierProvider ───────────────────────────

final teamDetailStateNotifierProvider =
    StateNotifierProvider<TeamDetailStateNotifier, TeamDetailState>(
      (ref) => TeamDetailStateNotifier(
        getTeamByIdUsecase: sl<GetTeamByIdUseCase>(),
        getMembersUsecase: sl<GetMembersUseCase>(),
        getProjectsUsecase: sl<GetProjectsByTeamUseCase>(),
      ),
    );

// ── Project mutation controllers — mirror teams_providers.dart pattern ─────────

final createProjectControllerProvider =
    StateNotifierProvider<CreateProjectController, AsyncValue<void>>(
      (ref) => CreateProjectController(
        createProjectUsecase: sl<CreateProjectUseCase>(),
        teamDetailStateNotifier: ref.read(
          teamDetailStateNotifierProvider.notifier,
        ),
      ),
    );

final updateProjectControllerProvider =
    StateNotifierProvider<UpdateProjectController, AsyncValue<void>>(
      (ref) => UpdateProjectController(
        updateProjectUsecase: sl<UpdateProjectUseCase>(),
        teamDetailStateNotifier: ref.read(
          teamDetailStateNotifierProvider.notifier,
        ),
      ),
    );

final deleteProjectControllerProvider =
    StateNotifierProvider<DeleteProjectController, AsyncValue<void>>(
      (ref) => DeleteProjectController(
        deleteProjectUsecase: sl<DeleteProjectUseCase>(),
        teamDetailStateNotifier: ref.read(
          teamDetailStateNotifierProvider.notifier,
        ),
      ),
    );

// ── Member mutation controllers — mirror teams_providers.dart pattern ──────────

final addMemberControllerProvider =
    StateNotifierProvider<AddMemberController, AsyncValue<void>>(
      (ref) => AddMemberController(
        addMemberUsecase: sl<AddMemberUseCase>(),
        teamDetailStateNotifier: ref.read(
          teamDetailStateNotifierProvider.notifier,
        ),
      ),
    );

final removeMemberControllerProvider =
    StateNotifierProvider<RemoveMemberController, AsyncValue<void>>(
      (ref) => RemoveMemberController(
        removeMemberUsecase: sl<RemoveMemberUseCase>(),
        teamDetailStateNotifier: ref.read(
          teamDetailStateNotifierProvider.notifier,
        ),
      ),
    );

final updateMemberControllerProvider =
    StateNotifierProvider<UpdateMemberController, AsyncValue<void>>(
      (ref) => UpdateMemberController(
        updateMemberUsecase: sl<UpdateMemberUseCase>(),
        teamDetailStateNotifier: ref.read(
          teamDetailStateNotifierProvider.notifier,
        ),
      ),
    );
