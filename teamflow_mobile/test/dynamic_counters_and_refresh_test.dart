import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/core/error/failures.dart';
import 'package:teamflow_mobile/features/teams/presentation/widget/team_card.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_member_entity.dart';
import 'package:teamflow_mobile/features/projects/domain/entitties/project_entity.dart';
import 'package:teamflow_mobile/core/widgets/project_card.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/membership_entity.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_memberships_usecase.dart';
import 'package:teamflow_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_state_notifier.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_teams_use_case.dart';
import 'package:teamflow_mobile/features/teams/domain/repositories/teams_repository.dart';
import 'package:teamflow_mobile/features/invitation/presentation/providers/accept_invitation_controller.dart';
import 'package:teamflow_mobile/features/invitation/domain/usecases/accept_invitation_usecase.dart';
import 'package:teamflow_mobile/features/invitation/domain/usecases/my_invitations_usecase.dart';
import 'package:teamflow_mobile/features/invitation/presentation/providers/invitations_state_notifier.dart';
import 'package:teamflow_mobile/features/invitation/domain/repository/invitation_repository.dart';
import 'package:teamflow_mobile/features/invitation/domain/entities/invitation_entity.dart' hide TeamEntity;

// ── Fakes for Refresh & Invitation Tests ───────────────────────

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

class FakeAuthStateNotifier extends AuthStateNotifier {
  bool refreshUserSessionCalled = false;
  FakeAuthStateNotifier() : super(FakeGetCurrentUserUseCase(), FakeGetMyMembershipsUseCase()) {
    refreshUserSessionCalled = false;
  }

  @override
  Future<void> refreshUserSession() async {
    refreshUserSessionCalled = true;
  }
}

class FakeGetTeamsUseCase implements GetTeamsUseCase {
  @override
  TeamsRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<TeamEntity>>> call() async => const Right([]);
}

class FakeTeamsStateNotifier extends TeamsStateNotifier {
  bool loadTeamsCalled = false;
  FakeTeamsStateNotifier() : super(FakeGetTeamsUseCase()) {
    loadTeamsCalled = false;
  }

  @override
  Future<void> loadTeams() async {
    loadTeamsCalled = true;
  }
}

class FakeMyInvitationsUseCase implements MyInvitationsUseCase {
  @override
  InvitationRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<InvitationEntity>>> call() async => const Right([]);
}

class FakeAcceptInvitationUseCase implements AcceptInvitationUseCase {
  @override
  InvitationRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> call(AcceptInvitationParams params) async => const Right(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TeamCard & Avatar Stack Tests', () {
    testWidgets('Displays member count and project count dynamically from backend list', (WidgetTester tester) async {
      final team = TeamEntity(
        id: 'team-1',
        name: 'Alpha Team',
        ownerId: 'owner-1',
        members: const [
          TeamMemberEntity(
            id: 'tm-1',
            teamId: 'team-1',
            userId: 'u1',
            role: TeamMemberRoleEntity.ADMIN,
            joinedAt: '',
          ),
          TeamMemberEntity(
            id: 'tm-2',
            teamId: 'team-1',
            userId: 'u2',
            role: TeamMemberRoleEntity.MEMBER,
            joinedAt: '',
          ),
        ],
        projects: const [
          ProjectEntity(id: 'p1', name: 'Proj A', ownerId: 'owner-1', createdAt: ''),
          ProjectEntity(id: 'p2', name: 'Proj B', ownerId: 'owner-1', createdAt: ''),
          ProjectEntity(id: 'p3', name: 'Proj C', ownerId: 'owner-1', createdAt: ''),
        ],
        createdAt: '',
        updatedAt: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamCard(
              team: team,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('2 members'), findsOneWidget);
      expect(find.text('3 projects'), findsOneWidget);
      expect(find.text('3 active now'), findsNothing);
    });

    testWidgets('Avatar stack shows +extra members label when members count > 5', (WidgetTester tester) async {
      final team = TeamEntity(
        id: 'team-1',
        name: 'Alpha Team',
        ownerId: 'owner-1',
        members: const [
          TeamMemberEntity(
            id: 'tm-1',
            teamId: 'team-1',
            userId: 'u1',
            role: TeamMemberRoleEntity.ADMIN,
            joinedAt: '',
            user: UserEntity(id: 'u1', name: 'User 1', email: 'u1@example.com'),
          ),
          TeamMemberEntity(
            id: 'tm-2',
            teamId: 'team-1',
            userId: 'u2',
            role: TeamMemberRoleEntity.MEMBER,
            joinedAt: '',
            user: UserEntity(id: 'u2', name: 'User 2', email: 'u2@example.com'),
          ),
          TeamMemberEntity(
            id: 'tm-3',
            teamId: 'team-1',
            userId: 'u3',
            role: TeamMemberRoleEntity.MEMBER,
            joinedAt: '',
            user: UserEntity(id: 'u3', name: 'User 3', email: 'u3@example.com'),
          ),
          TeamMemberEntity(
            id: 'tm-4',
            teamId: 'team-1',
            userId: 'u4',
            role: TeamMemberRoleEntity.MEMBER,
            joinedAt: '',
            user: UserEntity(id: 'u4', name: 'User 4', email: 'u4@example.com'),
          ),
          TeamMemberEntity(
            id: 'tm-5',
            teamId: 'team-1',
            userId: 'u5',
            role: TeamMemberRoleEntity.MEMBER,
            joinedAt: '',
            user: UserEntity(id: 'u5', name: 'User 5', email: 'u5@example.com'),
          ),
          TeamMemberEntity(
            id: 'tm-6',
            teamId: 'team-1',
            userId: 'u6',
            role: TeamMemberRoleEntity.MEMBER,
            joinedAt: '',
            user: UserEntity(id: 'u6', name: 'User 6', email: 'u6@example.com'),
          ),
          TeamMemberEntity(
            id: 'tm-7',
            teamId: 'team-1',
            userId: 'u7',
            role: TeamMemberRoleEntity.MEMBER,
            joinedAt: '',
            user: UserEntity(id: 'u7', name: 'User 7', email: 'u7@example.com'),
          ),
        ],
        projects: const [],
        createdAt: '',
        updatedAt: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamCard(
              team: team,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('+2 members'), findsOneWidget);
    });
  });

  group('ProjectCard Tests', () {
    testWidgets('Displays dynamic task count from backend _count property', (WidgetTester tester) async {
      const project = ProjectEntity(
        id: 'proj-1',
        name: 'TeamFlow App',
        ownerId: 'owner-1',
        createdAt: '2026-06-23T22:55:00Z',
        count: ProjectCountEntity(tasks: 45),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProjectCard(
              project: project,
              canManage: false,
              category: 'Engineering',
              ownerName: 'Alice',
              onEdit: () {},
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Engineering · 45 tasks'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('68%'), findsNothing);
    });

    testWidgets('Defaults task count to 0 if count field is null from backend', (WidgetTester tester) async {
      const project = ProjectEntity(
        id: 'proj-1',
        name: 'TeamFlow App',
        ownerId: 'owner-1',
        createdAt: '2026-06-23T22:55:00Z',
        count: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProjectCard(
              project: project,
              canManage: false,
              category: 'Marketing',
              onEdit: () {},
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Marketing · 0 tasks'), findsOneWidget);
    });
  });

  group('Workspace & Invite Refresh Tests', () {
    test('Invitation acceptance refreshes teams and auth session', () async {
      final fakeTeams = FakeTeamsStateNotifier();
      final fakeAuth = FakeAuthStateNotifier();
      final fakeInvitations = InvitationsStateNotifier(FakeMyInvitationsUseCase());

      final controller = AcceptInvitationController(
        acceptInvitationUseCase: FakeAcceptInvitationUseCase(),
        invitationsStateNotifier: fakeInvitations,
        read: <T>(provider) {
          if (provider == teamsStateNotifierProvider.notifier) {
            return fakeTeams as T;
          }
          if (provider == authStateNotifierProvider.notifier) {
            return fakeAuth as T;
          }
          throw UnimplementedError();
        },
        invalidate: (provider) {},
      );

      await controller.acceptInvitation(token: 'token-abc');

      // Flush microtasks so the async callback inside controller runs
      await Future.delayed(Duration.zero);

      expect(fakeTeams.loadTeamsCalled, isTrue);
      expect(fakeAuth.refreshUserSessionCalled, isTrue);
    });
  });
}
