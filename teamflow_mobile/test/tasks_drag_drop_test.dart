import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/core/error/failures.dart';
import 'package:teamflow_mobile/features/tasks/presentation/pages/tasks_page.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/features/tasks/data/models/task_model.dart';
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
import 'package:teamflow_mobile/features/tasks/presentation/providers/update_task_controller.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_teams_use_case.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_memberships_usecase.dart';
import 'package:teamflow_mobile/features/tasks/domain/repository/tasks_repository.dart';
import 'package:teamflow_mobile/features/teams/domain/repositories/teams_repository.dart';
import 'package:teamflow_mobile/features/auth/domain/repositories/auth_repository.dart';

import 'package:teamflow_mobile/features/teams/presentation/providers/team_details_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/team_detail_state_notifier.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_team_by_id_usecase.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_members_usecase.dart';
import 'package:teamflow_mobile/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:teamflow_mobile/features/projects/domain/repository/projects_repository.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_member_entity.dart';
import 'package:teamflow_mobile/features/teams/domain/repositories/team_members_repository.dart';

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
  FakeTasksStateNotifier(TasksState state) : super(getTasksUseCase: FakeGetTasksUseCase()) {
    this.state = state;
  }

  @override
  Future<void> loadTasks(String projectId) async {}

  @override
  void moveTask(String taskId, TaskStatus newStatus) {
    state = state.copyWith(
      tasks: state.tasks.map((task) {
        return task.id == taskId ? task.copyWith(status: newStatus) : task;
      }).toList(),
    );
  }
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
      : super(FakeGetCurrentUserUseCase(user), FakeGetMyMembershipsUseCase(memberships));

  @override
  Future<void> refreshMemberships() async {}
}

class FakeUpdateTaskController extends UpdateTaskController {
  final FakeTasksStateNotifier mockTasksNotifier;
  
  FakeUpdateTaskController(this.mockTasksNotifier)
      : super(updateTaskUseCase: FakeUpdateTaskUseCase(), taskStateNotifier: mockTasksNotifier);

  @override
  Future<void> moveTask({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    mockTasksNotifier.moveTask(taskId, newStatus);
  }
}

class FakeGetTeamByIdUseCase implements GetTeamByIdUseCase {
  @override
  TeamsRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, TeamEntity>> call(GetTeamByIdParams params) async => const Left(ServerFailure('Test stub'));
}

class FakeGetMembersUseCase implements GetMembersUseCase {
  @override
  TeamMembersRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<TeamMemberEntity>>> call(GetMembersParams params) async => const Left(ServerFailure('Test stub'));
}

class FakeGetProjectsByTeamUseCase implements GetProjectsByTeamUseCase {
  @override
  ProjectsRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<ProjectEntity>>> call(GetProjectsByTeamParams params) async => const Left(ServerFailure('Test stub'));
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

void main() {
  testWidgets('Drag and drop status change works successfully', (WidgetTester tester) async {
    final testTask = TaskEntity(
      id: 'task-123',
      title: 'Drag and Drop Test Task',
      description: 'Test Dragging',
      status: TaskStatus.TODO,
      projectId: 'project-456',
      createdById: 'user-789',
      assignedToId: 'user-789',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockTasksState = TasksState.loaded([testTask]);
    final mockTasksNotifier = FakeTasksStateNotifier(mockTasksState);

    final mockTeamsState = TeamsState(
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
    );
    final mockTeamsNotifier = FakeTeamsStateNotifier(mockTeamsState);

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
    final mockUpdateController = FakeUpdateTaskController(mockTasksNotifier);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskStateNotifierProvider.overrideWith((ref) => mockTasksNotifier),
          teamsStateNotifierProvider.overrideWith((ref) => mockTeamsNotifier),
          authStateNotifierProvider.overrideWith((ref) => mockAuthNotifier),
          updateTaskControllerProvider.overrideWith((ref) => mockUpdateController),
          teamDetailStateNotifierProvider.overrideWith((ref) => FakeTeamDetailStateNotifier(const TeamDetailState.unknown())),
        ],
        child: const MaterialApp(
          home: TasksPage(projectId: 'project-456', teamId: 'team-789'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify task is initially in 'To Do' (activeTab = 0)
    expect(find.text('Drag and Drop Test Task'), findsOneWidget);

    // Find the draggable card
    final draggableFinder = find.byType(LongPressDraggable<TaskEntity>);
    expect(draggableFinder, findsOneWidget);

    // Find the 'In Progress' target column header
    final inProgressTabFinder = find.text('In Progress');
    expect(inProgressTabFinder, findsOneWidget);

    // Perform long press drag and drop
    final gesture = await tester.startGesture(tester.getCenter(draggableFinder));
    // Wait for long press delay (300ms)
    await tester.pump(const Duration(milliseconds: 400));
    
    // Move it to the 'In Progress' tab header
    await gesture.moveTo(tester.getCenter(inProgressTabFinder));
    await tester.pumpAndSettle();
    
    // Release (drop) the task
    await gesture.up();
    await tester.pumpAndSettle();

    // The task status is updated to IN_PROGRESS. Since activeTab is switched to 1 (In Progress), 
    // the task should still be visible on screen!
    expect(find.text('Drag and Drop Test Task'), findsOneWidget);
    
    // Let's verify that the task's status in notifier state is now IN_PROGRESS
    expect(mockTasksNotifier.state.tasks.first.status, TaskStatus.IN_PROGRESS);
  });
}
