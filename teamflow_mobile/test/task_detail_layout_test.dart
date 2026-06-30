import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/features/tasks/task_detail_page.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:teamflow_mobile/features/tasks/data/models/comment_model.dart';
import 'package:teamflow_mobile/features/tasks/data/models/activity_model.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_state_notifier.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/comments_providers.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/activities_providers.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_state_notifier.dart';
import 'package:teamflow_mobile/features/teams/domain/usecases/get_teams_use_case.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:teamflow_mobile/features/auth/domain/usecases/get_memberships_usecase.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/membership_entity.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:teamflow_mobile/features/tasks/domain/repository/comments_repository.dart';
import 'package:teamflow_mobile/features/tasks/domain/repository/activities_repository.dart';
import 'package:teamflow_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:teamflow_mobile/features/teams/domain/repositories/teams_repository.dart';
import 'package:teamflow_mobile/features/tasks/domain/repository/tasks_repository.dart';
import 'package:teamflow_mobile/core/error/failures.dart';

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

class FakeGetTasksUseCase implements GetTasksUseCase {
  @override
  TasksRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<TaskEntity>>> call(GetTasksParams params) async => const Right([]);
}

class FakeCommentsRepository implements CommentsRepository {
  @override
  Future<Either<Failure, List<CommentModel>>> getComments(String taskId, {int? page, int? limit}) async {
    return Right([
      CommentModel(
        id: 'c1',
        content: 'Test Comment Content',
        taskId: taskId,
        userId: 'u1',
        createdAt: '2026-06-29T10:00:00Z',
        updatedAt: '2026-06-29T10:00:00Z',
      ),
    ]);
  }
  @override
  Future<Either<Failure, CommentModel>> createComment(String taskId, String content) async => throw UnimplementedError();
  @override
  Future<Either<Failure, CommentModel>> updateComment(String commentId, String content) async => throw UnimplementedError();
  @override
  Future<Either<Failure, Unit>> deleteComment(String commentId) async => Right(unit);
}

class FakeActivitiesRepository implements ActivitiesRepository {
  @override
  Future<Either<Failure, List<ActivityModel>>> getTaskActivities(String taskId) async {
    return Right([
      ActivityModel(
        id: 'act1',
        type: 'TASK',
        content: 'changed status from TODO to IN_PROGRESS',
        userId: 'u1',
        taskId: taskId,
        createdAt: '2026-06-29T10:05:00Z',
        user: ActivityUser(id: 'u1', name: 'User One'),
      ),
    ]);
  }
  @override
  Future<Either<Failure, List<ActivityModel>>> getProjectActivities(String projectId) async => throw UnimplementedError();
  @override
  Future<Either<Failure, List<ActivityModel>>> getWorkspaceActivities(String workspaceId) async => throw UnimplementedError();
}

void main() {
  testWidgets('TaskDetailPage builds and renders activities and comments cleanly', (WidgetTester tester) async {
    final task = TaskEntity(
      id: 'task-1',
      title: 'Fix hit test issue',
      description: 'Find why hit test a render box with no size happens.',
      status: TaskStatus.TODO,
      priority: 'HIGH',
      createdAt: DateTime.parse('2026-06-29T09:00:00Z'),
      updatedAt: DateTime.parse('2026-06-29T09:00:00Z'),
      projectId: 'proj-1',
      createdById: 'u1',
    );

    final authNotifier = AuthStateNotifier(FakeGetCurrentUserUseCase(), FakeGetMyMembershipsUseCase());
    final teamsNotifier = TeamsStateNotifier(FakeGetTeamsUseCase());
    final tasksNotifier = TasksStateNotifier(getTasksUseCase: FakeGetTasksUseCase())..state = TasksState.loaded([task]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateNotifierProvider.overrideWith((ref) => authNotifier),
          teamsStateNotifierProvider.overrideWith((ref) => teamsNotifier),
          taskStateNotifierProvider.overrideWith((ref) => tasksNotifier),
          commentsRepositoryProvider.overrideWithValue(FakeCommentsRepository()),
          activitiesRepositoryProvider.overrideWithValue(FakeActivitiesRepository()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TaskDetailPage(
              task: task,
              projectName: 'Fullstack App',
              teamId: 'team-1',
            ),
          ),
        ),
      ),
    );

    // Pump to complete layout frame
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify it renders title
    expect(find.text('Fix hit test issue'), findsOneWidget);

    // Verify it renders the first tab (Activity)
    expect(find.text('changed status from TODO to IN_PROGRESS'), findsOneWidget);

    // Switch to Comments tab
    await tester.tap(find.text('Comments'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify it renders the comment
    expect(find.text('Test Comment Content'), findsOneWidget);
  });
}
