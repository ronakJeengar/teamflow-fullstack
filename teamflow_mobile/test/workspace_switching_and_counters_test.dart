import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/core/error/failures.dart';
import 'package:teamflow_mobile/features/auth/presentation/pages/home_page.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/workspaces_providers.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/stats_providers.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/workspace_controller.dart';
import 'package:teamflow_mobile/features/dashboard/domain/repositories/workspaces_repository.dart';
import 'package:teamflow_mobile/features/dashboard/data/models/workspace_model.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/membership_entity.dart';
import 'package:teamflow_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_memberships_usecase.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:teamflow_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:teamflow_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_state_notifier.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';
import 'package:teamflow_mobile/features/teams/domain/repositories/teams_repository.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_teams_use_case.dart';
import 'package:teamflow_mobile/features/dashboard/data/models/dashboard_stats_model.dart';

class FakeGetCurrentUserUseCase implements GetCurrentUserUseCase {
  @override
  AuthRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity?>> call() async => const Right(null);
}

class FakeGetMyMembershipsUseCase implements GetMyMembershipsUseCase {
  @override
  AuthRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<MembershipEntity>>> call() async => const Right([]);
}

class FakeGetTeamsUseCase implements GetTeamsUseCase {
  @override
  TeamsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<TeamEntity>>> call() async => const Right([]);
}

class FakeWorkspacesRepository implements WorkspacesRepository {
  bool switchWorkspaceCalled = false;

  @override
  Future<Either<Failure, void>> switchWorkspace(String workspaceId) async {
    switchWorkspaceCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<WorkspaceModel>>> getWorkspaces() async {
    return const Right([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthStateNotifier extends AuthStateNotifier {
  bool refreshUserSessionCalled = false;

  FakeAuthStateNotifier() : super(
    FakeGetCurrentUserUseCase(),
    FakeGetMyMembershipsUseCase(),
  ) {
    state = const AuthState(
      status: AuthStatus.authenticated,
      user: UserEntity(
        id: 'u1',
        name: 'User One',
        email: 'user@example.com',
        activeWorkspaceId: 'w1',
      ),
      memberships: [],
    );
  }

  @override
  Future<void> _checkCurrentUser() async {}

  @override
  Future<void> refreshUserSession() async {
    refreshUserSessionCalled = true;
  }
}

class FakeTeamsStateNotifier extends TeamsStateNotifier {
  bool loadTeamsCalled = false;

  FakeTeamsStateNotifier() : super(FakeGetTeamsUseCase()) {
    state = const TeamsState.loaded([]);
  }

  @override
  Future<void> loadTeams() async {
    loadTeamsCalled = true;
  }
}

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<Either<Failure, int>> getUnreadCount() async => const Right(0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUnreadCountNotifier extends UnreadCountNotifier {
  FakeUnreadCountNotifier() : super(FakeNotificationRepository()) {
    state = 0;
  }
  
  @override
  Future<void> loadUnreadCount() async {}
}

void main() {
  testWidgets('Empty workspaces list renders safe fallback on home page', (WidgetTester tester) async {
    // Configure virtual surface size to ensure vertical space for rendering without layouts contract
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeTeams = FakeTeamsStateNotifier();
    final fakeAuth = FakeAuthStateNotifier();
    fakeAuth.state = const AuthState(
      status: AuthStatus.authenticated,
      user: UserEntity(
        id: 'u1',
        name: 'User One',
        email: 'user@example.com',
        activeWorkspaceId: null,
      ),
      memberships: [],
    );

    final container = ProviderContainer(
      overrides: [
        workspacesListProvider.overrideWith((ref) => <WorkspaceModel>[]),
        dashboardStatsProvider.overrideWith((ref) => const DashboardStatsModel(
          tasksDueToday: 0,
          inProgress: 0,
          inReview: 0,
          blocked: 0,
          completedThisWeek: 0,
        )),
        authStateNotifierProvider.overrideWith((ref) => fakeAuth),
        myTasksProvider.overrideWith((ref) => []),
        unreadNotificationsCountProvider.overrideWith((ref) => FakeUnreadCountNotifier()),
        teamsStateNotifierProvider.overrideWith((ref) => fakeTeams),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: HomePage(),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('No workspaces found. Create one to get started.'), findsOneWidget);
  });

  test('Workspace switch triggers session refresh and workspaces list invalidation', () async {
    final fakeRepo = FakeWorkspacesRepository();
    final fakeAuth = FakeAuthStateNotifier();
    final fakeTeams = FakeTeamsStateNotifier();

    final container = ProviderContainer(
      overrides: [
        workspacesRepositoryProvider.overrideWith((ref) => fakeRepo),
        authStateNotifierProvider.overrideWith((ref) => fakeAuth),
        teamsStateNotifierProvider.overrideWith((ref) => fakeTeams),
      ],
    );

    final controller = container.read(workspaceControllerProvider.notifier);
    final success = await controller.switchWorkspace('w-new');

    expect(success, isTrue);
    expect(fakeRepo.switchWorkspaceCalled, isTrue);
    expect(fakeAuth.refreshUserSessionCalled, isTrue);
    expect(fakeTeams.loadTeamsCalled, isTrue);
  });
}
