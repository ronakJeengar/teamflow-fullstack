import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/core/error/failures.dart';
import 'package:teamflow_mobile/core/router/app_router.dart';
import 'package:teamflow_mobile/core/router/routes.dart';
import 'package:teamflow_mobile/features/tasks/presentation/pages/tasks_page.dart';
import 'package:teamflow_mobile/features/teams/presentation/pages/teams_page.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_state_notifier.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_state_notifier.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/membership_entity.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';
import 'package:teamflow_mobile/features/projects/domain/entitties/project_entity.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_teams_use_case.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_memberships_usecase.dart';
import 'package:teamflow_mobile/features/tasks/domain/repository/tasks_repository.dart';
import 'package:teamflow_mobile/features/teams/domain/repositories/teams_repository.dart';
import 'package:teamflow_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/update_task_controller.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:teamflow_mobile/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:teamflow_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:teamflow_mobile/features/notifications/domain/entities/notification_entity.dart';

import 'package:teamflow_mobile/features/teams/presentation/providers/team_details_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/team_detail_state_notifier.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_team_by_id_usecase.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_members_usecase.dart';
import 'package:teamflow_mobile/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:teamflow_mobile/features/projects/domain/repository/projects_repository.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_member_entity.dart';
import 'package:teamflow_mobile/features/teams/domain/repositories/team_members_repository.dart';

class FakeGetTeamByIdUseCase implements GetTeamByIdUseCase {
  @override
  TeamsRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, TeamEntity>> call(GetTeamByIdParams params) async => throw UnimplementedError();
}

class FakeGetMembersUseCase implements GetMembersUseCase {
  @override
  TeamMembersRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<TeamMemberEntity>>> call(GetMembersParams params) async => throw UnimplementedError();
}

class FakeGetProjectsByTeamUseCase implements GetProjectsByTeamUseCase {
  @override
  ProjectsRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<ProjectEntity>>> call(GetProjectsByTeamParams params) async => throw UnimplementedError();
}

class FakeTeamDetailStateNotifier extends TeamDetailStateNotifier {
  FakeTeamDetailStateNotifier(TeamDetailState state)
      : super(
          getTeamByIdUsecase: FakeGetTeamByIdUseCase(),
          getMembersUsecase: FakeGetMembersUseCase(),
          getProjectsUsecase: FakeGetProjectsByTeamUseCase(),
        ) {
    this.state = state;
  }
}

class FakeGetTasksUseCase implements GetTasksUseCase {
  @override
  TasksRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<TaskEntity>>> call(GetTasksParams params) async => const Right([]);
}

class FakeUpdateTaskUseCase implements UpdateTaskUseCase {
  @override
  TasksRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) async => throw UnimplementedError();
}

class FakeGetTeamsUseCase implements GetTeamsUseCase {
  @override
  TeamsRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<TeamEntity>>> call() async => const Right([]);
}

class FakeGetCurrentUserUseCase implements GetCurrentUserUseCase {
  final UserEntity? user;
  FakeGetCurrentUserUseCase(this.user);

  @override
  AuthRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, UserEntity?>> call() async => Right(user);
}

class FakeGetMyMembershipsUseCase implements GetMyMembershipsUseCase {
  final List<MembershipEntity> memberships;
  FakeGetMyMembershipsUseCase(this.memberships);

  @override
  AuthRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<MembershipEntity>>> call() async => Right(memberships);
}

class FakeTasksStateNotifier extends TasksStateNotifier {
  FakeTasksStateNotifier() : super(getTasksUseCase: FakeGetTasksUseCase()) {
    state = const TasksState.loaded([]);
  }

  @override
  Future<void> loadTasks(String projectId) async {}
}

class FakeTeamsStateNotifier extends TeamsStateNotifier {
  FakeTeamsStateNotifier(TeamsState state) : super(FakeGetTeamsUseCase()) {
    this.state = state;
  }

  @override
  Future<void> loadTeams() async {}
}

class FakeAuthStateNotifier extends AuthStateNotifier {
  FakeAuthStateNotifier(UserEntity user, List<MembershipEntity> memberships)
      : super(FakeGetCurrentUserUseCase(user), FakeGetMyMembershipsUseCase(memberships)) {
    state = AuthState(
      status: AuthStatus.authenticated,
      user: user,
      memberships: memberships,
    );
  }

  @override
  Future<void> refreshMemberships() async {}

  @override
  Future<void> refreshUserSession() async {}
}

class FakeUpdateTaskController extends UpdateTaskController {
  FakeUpdateTaskController()
      : super(updateTaskUseCase: FakeUpdateTaskUseCase(), taskStateNotifier: FakeTasksStateNotifier());
}

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<Either<Failure, int>> getUnreadCount() async => const Right(0);
  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async => const Right([]);
  @override
  Future<Either<Failure, void>> markAsRead(String id) async => const Right(null);
  @override
  Future<Either<Failure, void>> markAllAsRead() async => const Right(null);
}

class FakeUnreadNotificationsNotifier extends UnreadCountNotifier {
  FakeUnreadNotificationsNotifier() : super(FakeNotificationRepository());

  @override
  Future<void> loadUnreadCount() async {}
}

void main() {
  testWidgets('Router correctly parses teamId and projectId, and shows TasksPage', (WidgetTester tester) async {
    const testUser = UserEntity(
      id: 'user-789',
      name: 'Test User',
      email: 'test@example.com',
    );
    const testMemberships = [
      MembershipEntity(
        role: 'ADMIN',
        team: MembershipTeamEntity(id: 'team-789', name: 'Test Team'),
      ),
    ];

    final mockAuthNotifier = FakeAuthStateNotifier(testUser, testMemberships);
    final mockTeamsNotifier = FakeTeamsStateNotifier(
      TeamsState(
        status: TeamsStatus.loaded,
        teams: [
          TeamEntity(
            id: 'team-789',
            name: 'Test Team',
            ownerId: 'user-789',
            createdAt: '',
            updatedAt: '',
            projects: [
              ProjectEntity(
                id: 'project-456',
                name: 'Test Project',
                ownerId: 'user-789',
                createdAt: '',
              ),
            ],
          ),
        ],
      ),
    );
    final mockTasksNotifier = FakeTasksStateNotifier();
    final mockUpdateController = FakeUpdateTaskController();
    final mockUnreadNotifier = FakeUnreadNotificationsNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateNotifierProvider.overrideWith((ref) => mockAuthNotifier),
          teamsStateNotifierProvider.overrideWith((ref) => mockTeamsNotifier),
          taskStateNotifierProvider.overrideWith((ref) => mockTasksNotifier),
          updateTaskControllerProvider.overrideWith((ref) => mockUpdateController),
          unreadNotificationsCountProvider.overrideWith((ref) => mockUnreadNotifier),
          teamDetailStateNotifierProvider.overrideWith((ref) => FakeTeamDetailStateNotifier(const TeamDetailState.unknown())),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(goRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Now navigate to the tasks page using the new route
    final router = ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(goRouterProvider);
    router.go(Routes.tasksPath('team-789', 'project-456'));
    await tester.pumpAndSettle();

    // Verify TasksPage is displayed and is active
    expect(find.byType(TasksPage), findsOneWidget);

    // Verify that the route parameters were correctly bound and active
    final TasksPage tasksPage = tester.widget(find.byType(TasksPage));
    expect(tasksPage.teamId, equals('team-789'));
    expect(tasksPage.projectId, equals('project-456'));
  });

  testWidgets('Router redirects to teams list if user has no access to the team', (WidgetTester tester) async {
    const testUser = UserEntity(
      id: 'user-789',
      name: 'Test User',
      email: 'test@example.com',
    );
    // User only has membership for team-789
    const testMemberships = [
      MembershipEntity(
        role: 'ADMIN',
        team: MembershipTeamEntity(id: 'team-789', name: 'Test Team'),
      ),
    ];

    final mockAuthNotifier = FakeAuthStateNotifier(testUser, testMemberships);
    final mockTeamsNotifier = FakeTeamsStateNotifier(
      TeamsState(
        status: TeamsStatus.loaded,
        teams: [
          TeamEntity(
            id: 'team-789',
            name: 'Test Team',
            ownerId: 'user-789',
            createdAt: '',
            updatedAt: '',
            projects: [],
          ),
        ],
      ),
    );
    final mockUnreadNotifier = FakeUnreadNotificationsNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateNotifierProvider.overrideWith((ref) => mockAuthNotifier),
          teamsStateNotifierProvider.overrideWith((ref) => mockTeamsNotifier),
          unreadNotificationsCountProvider.overrideWith((ref) => mockUnreadNotifier),
          teamDetailStateNotifierProvider.overrideWith((ref) => FakeTeamDetailStateNotifier(const TeamDetailState.unknown())),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(goRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final router = ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(goRouterProvider);
    
    // Attempt navigation to a team the user doesn't belong to (team-xyz)
    router.go(Routes.tasksPath('team-xyz', 'project-abc'));
    await tester.pumpAndSettle();

    // Verify we are redirected to /teams (not landing on TasksPage)
    expect(find.byType(TasksPage), findsNothing);
    expect(find.byType(TeamsPage), findsOneWidget);
  });
}
