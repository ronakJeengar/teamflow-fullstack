import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/presentation/providers/auth_state_notifier.dart';
import '../../features/auth/presentation/providers/login_controller.dart';
import '../../features/auth/presentation/providers/signup_controller.dart';

import '../../features/projects/data/repository/projects_repository_impl.dart';
import '../../features/projects/domain/repository/projects_repository.dart';
import '../../features/teams/data/datasources/team_member_remote_datasource.dart';
import '../../features/teams/data/datasources/teams_remote_datasource.dart';
import '../../features/teams/data/repositories/team_member_repository_impl.dart';
import '../../features/teams/data/repositories/teams_repository_impl.dart';
import '../../features/teams/domain/repositories/team_members_repository.dart';
import '../../features/teams/domain/repositories/teams_repository.dart';
import '../../features/teams/domain/usecases/create_team_usecase.dart';
import '../../features/teams/domain/usecases/delete_team_usecase.dart';
import '../../features/teams/domain/usecases/get_teams_use_case.dart';
import '../../features/teams/domain/usecases/update_team_usecase.dart';
import '../../features/teams/domain/usecases/get_team_by_id_usecase.dart';
import '../../features/teams/domain/usecases/get_members_usecase.dart';
import '../../features/teams/domain/usecases/add_member_usecase.dart';
import '../../features/teams/domain/usecases/remove_member_usecase.dart';
import '../../features/teams/domain/usecases/update_member_usecase.dart';
import '../../features/teams/presentation/providers/create_team_controller.dart';
import '../../features/teams/presentation/providers/delete_team_controller.dart';
import '../../features/teams/presentation/providers/teams_state_notifier.dart';
import '../../features/teams/presentation/providers/update_team_controller.dart';

import '../../features/projects/data/datasources/projects_remote_datasource.dart';
import '../../features/projects/domain/usecases/creaet_project_usecase.dart';
import '../../features/projects/domain/usecases/delete_project_usecase.dart';
import '../../features/projects/domain/usecases/get_projects_usecase.dart';
import '../../features/projects/domain/usecases/update_project_usecase.dart';

import '../services/api_service.dart';

final sl = GetIt.instance;

Future<void> setupDI({
  String baseUrl = 'http://10.0.2.2:3000/api/v1/',
}) async {

  // =========================================================
  // CORE
  // =========================================================

  sl.registerLazySingleton<ApiService>(
        () => ApiService(baseUrl: baseUrl),
  );

  sl.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ),
  );

  // =========================================================
  // AUTH FEATURE
  // =========================================================

  // DATA SOURCES

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(sl()),
  );

  // REPOSITORY

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // USE CASES

  sl.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(sl()),
  );

  sl.registerLazySingleton<SignupUseCase>(
        () => SignupUseCase(sl()),
  );

  sl.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(sl()),
  );

  sl.registerLazySingleton<GetCurrentUserUseCase>(
        () => GetCurrentUserUseCase(sl()),
  );

  // CONTROLLERS / NOTIFIERS

  sl.registerFactory<AuthStateNotifier>(
        () => AuthStateNotifier(
      sl<GetCurrentUserUseCase>(),
    ),
  );

  sl.registerFactory<LoginController>(
        () => LoginController(
      loginUseCase: sl<LoginUseCase>(),
      authStateNotifier: sl<AuthStateNotifier>(),
    ),
  );

  sl.registerFactory<SignupController>(
        () => SignupController(
      signupUseCase: sl<SignupUseCase>(),
      authStateNotifier: sl<AuthStateNotifier>(),
    ),
  );

  // =========================================================
  // TEAMS FEATURE
  // =========================================================

  // DATA SOURCES

  sl.registerLazySingleton<TeamsRemoteDataSource>(
        () => TeamsRemoteDataSourceImpl(sl()),
  );

  // REPOSITORY

  sl.registerLazySingleton<TeamsRepository>(
        () => TeamsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // DATA SOURCE (if separate from teams)
  sl.registerLazySingleton<TeamMembersRemoteDataSource>(
        () => TeamMembersRemoteDataSourceImpl(sl()),
  );

// REPOSITORY
  sl.registerLazySingleton<TeamMembersRepository>(
        () => TeamMembersRepositoryImpl(remoteDataSource: sl()),
  );

  // USE CASES — team list

  sl.registerLazySingleton<GetTeamsUseCase>(
        () => GetTeamsUseCase(sl()),
  );

  sl.registerLazySingleton<CreateTeamUseCase>(
        () => CreateTeamUseCase(sl()),
  );

  sl.registerLazySingleton<UpdateTeamUseCase>(
        () => UpdateTeamUseCase(sl()),
  );

  sl.registerLazySingleton<DeleteTeamUseCase>(
        () => DeleteTeamUseCase(sl()),
  );

  // USE CASES — team detail

  sl.registerLazySingleton<GetTeamByIdUseCase>(
        () => GetTeamByIdUseCase(sl()),
  );

  sl.registerLazySingleton<GetMembersUseCase>(
        () => GetMembersUseCase(sl()),
  );

  sl.registerLazySingleton<AddMemberUseCase>(
        () => AddMemberUseCase(sl()),
  );

  sl.registerLazySingleton<RemoveMemberUseCase>(
        () => RemoveMemberUseCase(sl()),
  );

  sl.registerLazySingleton<UpdateMemberUseCase>(
        () => UpdateMemberUseCase(sl()),
  );

  // NOTIFIERS / CONTROLLERS — teams

  sl.registerFactory<TeamsStateNotifier>(
        () => TeamsStateNotifier(
      sl<GetTeamsUseCase>(),
    ),
  );

  sl.registerFactory<CreateTeamController>(
        () => CreateTeamController(
      createTeamUsecase: sl<CreateTeamUseCase>(),
      teamsStateNotifier: sl<TeamsStateNotifier>(),
    ),
  );

  sl.registerFactory<UpdateTeamController>(
        () => UpdateTeamController(
      updateTeamUsecase: sl<UpdateTeamUseCase>(),
      teamsStateNotifier: sl<TeamsStateNotifier>(),
    ),
  );

  sl.registerFactory<DeleteTeamController>(
        () => DeleteTeamController(
      deleteTeamUsecase: sl<DeleteTeamUseCase>(),
      teamsStateNotifier: sl<TeamsStateNotifier>(),
    ),
  );

  // =========================================================
  // PROJECTS FEATURE
  // =========================================================

  // DATA SOURCES

  sl.registerLazySingleton<ProjectsRemoteDataSource>(
        () => ProjectsRemoteDataSourceImpl(sl()),
  );

  // REPOSITORY

  sl.registerLazySingleton<ProjectsRepository>(
        () => ProjectsRepositoryImpl(
          remoteDataSource: sl(),
    ),
  );

  // USE CASES

  sl.registerLazySingleton<GetProjectsByTeamUseCase>(
        () => GetProjectsByTeamUseCase(sl()),
  );

  sl.registerLazySingleton<CreateProjectUseCase>(
        () => CreateProjectUseCase(sl()),
  );

  sl.registerLazySingleton<UpdateProjectUseCase>(
        () => UpdateProjectUseCase(sl()),
  );

  sl.registerLazySingleton<DeleteProjectUseCase>(
        () => DeleteProjectUseCase(sl()),
  );
}