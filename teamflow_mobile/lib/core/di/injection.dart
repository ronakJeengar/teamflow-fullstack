import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/get_memberships_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/presentation/providers/auth_state_notifier.dart';
import '../../features/auth/presentation/providers/login_controller.dart';
import '../../features/auth/presentation/providers/signup_controller.dart';

import '../../features/invitation/data/datasources/invitation_remote_datasource.dart';
import '../../features/invitation/data/repository/invitation_repository_Impl.dart';
import '../../features/invitation/domain/repository/invitation_repository.dart';
import '../../features/invitation/domain/usecases/accept_invitation_usecase.dart';
import '../../features/invitation/domain/usecases/cancel_invitation_usecase.dart';
import '../../features/invitation/domain/usecases/my_invitations_usecase.dart';
import '../../features/invitation/domain/usecases/send_invitation_usecase.dart';
import '../../features/invitation/domain/usecases/get_team_invitations_usecase.dart';
import '../../features/invitation/presentation/providers/accept_invitation_controller.dart';
import '../../features/invitation/presentation/providers/cancel_invitation_controller.dart';
import '../../features/invitation/presentation/providers/invitations_state_notifier.dart';
import '../../features/invitation/presentation/providers/team_invitations_state_notifier.dart';
import '../../features/invitation/presentation/providers/send_invitation_controller.dart';

import '../../features/projects/data/datasources/projects_remote_datasource.dart';
import '../../features/projects/data/repository/projects_repository_impl.dart';
import '../../features/projects/domain/repository/projects_repository.dart';
import '../../features/projects/domain/usecases/creaet_project_usecase.dart';
import '../../features/projects/domain/usecases/delete_project_usecase.dart';
import '../../features/projects/domain/usecases/get_projects_usecase.dart';
import '../../features/projects/domain/usecases/update_project_usecase.dart';

import '../../features/tasks/data/datasources/tasks_remote_datasource.dart';
import '../../features/tasks/data/repository/tasks_repository_impl.dart';
import '../../features/tasks/domain/repository/tasks_repository.dart';
import '../../features/tasks/domain/usecases/creaet_task_usecase.dart';
import '../../features/tasks/domain/usecases/delete_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/domain/usecases/update_task_usecase.dart';
import '../../features/tasks/presentation/providers/create_task_controller.dart';
import '../../features/tasks/presentation/providers/delete_task_controller.dart';
import '../../features/tasks/presentation/providers/task_state_notifier.dart';
import '../../features/tasks/presentation/providers/update_task_controller.dart';

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

import '../services/api_service.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/reposiotries/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/dashboard/data/datasources/stats_remote_datasource.dart';
import '../../features/dashboard/data/repositories/stats_repository_impl.dart';
import '../../features/dashboard/domain/repositories/stats_repository.dart';
import '../../features/dashboard/data/datasources/workspaces_remote_datasource.dart';
import '../../features/dashboard/data/repositories/workspaces_repository_impl.dart';
import '../../features/dashboard/domain/repositories/workspaces_repository.dart';
import '../../features/tasks/data/datasources/comments_remote_datasource.dart';
import '../../features/tasks/data/repository/comments_repository_impl.dart';
import '../../features/tasks/domain/repository/comments_repository.dart';
import '../../features/tasks/data/datasources/activities_remote_datasource.dart';
import '../../features/tasks/data/repository/activities_repository_impl.dart';
import '../../features/tasks/domain/repository/activities_repository.dart';
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repository/search_repository_impl.dart';
import '../../features/search/domain/repository/search_repository.dart';

final sl = GetIt.instance;

Future<void> setupDI({String? baseUrl}) async {
  final effectiveBaseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/api/v1/');

  sl.registerLazySingleton<ApiService>(() => ApiService(baseUrl: effectiveBaseUrl));

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  // =========================================================
  // AUTH FEATURE
  // =========================================================

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

  sl.registerLazySingleton<SignupUseCase>(() => SignupUseCase(sl()));

  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));

  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl()),
  );

  sl.registerLazySingleton<GetMyMembershipsUseCase>(
    () => GetMyMembershipsUseCase(sl()),
  );

  sl.registerFactory<AuthStateNotifier>(
    () => AuthStateNotifier(
      sl<GetCurrentUserUseCase>(),
      sl<GetMyMembershipsUseCase>(),
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

  sl.registerLazySingleton<TeamsRemoteDataSource>(
    () => TeamsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<TeamsRepository>(
    () => TeamsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<TeamMembersRemoteDataSource>(
    () => TeamMembersRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<TeamMembersRepository>(
    () => TeamMembersRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<GetTeamsUseCase>(() => GetTeamsUseCase(sl()));
  sl.registerLazySingleton<CreateTeamUseCase>(() => CreateTeamUseCase(sl()));
  sl.registerLazySingleton<UpdateTeamUseCase>(() => UpdateTeamUseCase(sl()));
  sl.registerLazySingleton<DeleteTeamUseCase>(() => DeleteTeamUseCase(sl()));
  sl.registerLazySingleton<GetTeamByIdUseCase>(() => GetTeamByIdUseCase(sl()));
  sl.registerLazySingleton<GetMembersUseCase>(() => GetMembersUseCase(sl()));
  sl.registerLazySingleton<AddMemberUseCase>(() => AddMemberUseCase(sl()));
  sl.registerLazySingleton<RemoveMemberUseCase>(
    () => RemoveMemberUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateMemberUseCase>(
    () => UpdateMemberUseCase(sl()),
  );

  sl.registerFactory<TeamsStateNotifier>(
    () => TeamsStateNotifier(sl<GetTeamsUseCase>()),
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

  sl.registerLazySingleton<ProjectsRemoteDataSource>(
    () => ProjectsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(remoteDataSource: sl()),
  );

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

  // =========================================================
  // TASKS FEATURE
  // =========================================================

  sl.registerLazySingleton<TasksRemoteDataSource>(
    () => TasksRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<GetTasksUseCase>(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton<CreateTaskUseCase>(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton<UpdateTaskUseCase>(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton<DeleteTaskUseCase>(() => DeleteTaskUseCase(sl()));

  sl.registerFactory<TasksStateNotifier>(
    () => TasksStateNotifier(getTasksUseCase: sl<GetTasksUseCase>()),
  );

  sl.registerFactory<CreateTaskController>(
    () => CreateTaskController(
      createTaskUseCase: sl<CreateTaskUseCase>(),
      taskStateNotifier: sl<TasksStateNotifier>(),
    ),
  );

  sl.registerFactory<UpdateTaskController>(
    () => UpdateTaskController(
      updateTaskUseCase: sl<UpdateTaskUseCase>(),
      taskStateNotifier: sl<TasksStateNotifier>(),
    ),
  );

  sl.registerFactory<DeleteTaskController>(
    () => DeleteTaskController(
      deleteTaskUseCase: sl<DeleteTaskUseCase>(),
      taskStateNotifier: sl<TasksStateNotifier>(),
    ),
  );

  // =========================================================
  // INVITATIONS FEATURE
  // =========================================================

  sl.registerLazySingleton<InvitationRemoteDataSource>(
    () => InvitationsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<InvitationRepository>(
    () => InvitationRepositoryImpl(sl<InvitationRemoteDataSource>()),
  );

  // USE CASES
  sl.registerLazySingleton<MyInvitationsUseCase>(
    () => MyInvitationsUseCase(sl<InvitationRepository>()),
  );
  sl.registerLazySingleton<GetTeamInvitationsUseCase>(
    () => GetTeamInvitationsUseCase(sl<InvitationRepository>()),
  );
  sl.registerLazySingleton<SendInvitationUseCase>(
    () => SendInvitationUseCase(sl<InvitationRepository>()),
  );
  sl.registerLazySingleton<AcceptInvitationUseCase>(
    () => AcceptInvitationUseCase(sl<InvitationRepository>()),
  );
  sl.registerLazySingleton<CancelInvitationUseCase>(
    () => CancelInvitationUseCase(sl<InvitationRepository>()),
  );

  // NOTIFIERS
  sl.registerFactory<InvitationsStateNotifier>(
    () => InvitationsStateNotifier(sl<MyInvitationsUseCase>()),
  );
  sl.registerFactory<TeamInvitationsStateNotifier>(
    () => TeamInvitationsStateNotifier(sl<GetTeamInvitationsUseCase>()),
  );

  // CONTROLLERS

  sl.registerFactory<SendInvitationController>(
    () => SendInvitationController(
      sendInvitationUseCase: sl<SendInvitationUseCase>(),
      invitationsStateNotifier: sl<InvitationsStateNotifier>(),
    ),
  );

  sl.registerFactory<AcceptInvitationController>(
    () => AcceptInvitationController(
      acceptInvitationUseCase: sl<AcceptInvitationUseCase>(),
      invitationsStateNotifier: sl<InvitationsStateNotifier>(),
      teamsStateNotifier: sl<TeamsStateNotifier>(),
      authStateNotifier: sl<AuthStateNotifier>(),
    ),
  );

  sl.registerFactory<CancelInvitationController>(
    () => CancelInvitationController(
      cancelInvitationUseCase: sl<CancelInvitationUseCase>(),
      invitationsStateNotifier: sl<InvitationsStateNotifier>(),
    ),
  );

  // =========================================================
  // NOTIFICATIONS FEATURE
  // =========================================================
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  // =========================================================
  // STATS FEATURE
  // =========================================================
  sl.registerLazySingleton<StatsRemoteDataSource>(
    () => StatsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<StatsRepository>(
    () => StatsRepositoryImpl(sl()),
  );

  // =========================================================
  // WORKSPACES FEATURE
  // =========================================================
  sl.registerLazySingleton<WorkspacesRemoteDataSource>(
    () => WorkspacesRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<WorkspacesRepository>(
    () => WorkspacesRepositoryImpl(sl()),
  );

  // =========================================================
  // COMMENTS FEATURE
  // =========================================================
  sl.registerLazySingleton<CommentsRemoteDataSource>(
    () => CommentsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(sl()),
  );

  // =========================================================
  // ACTIVITIES FEATURE
  // =========================================================
  sl.registerLazySingleton<ActivitiesRemoteDataSource>(
    () => ActivitiesRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ActivitiesRepository>(
    () => ActivitiesRepositoryImpl(sl()),
  );

  // =========================================================
  // SEARCH FEATURE
  // =========================================================
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl()),
  );
}
