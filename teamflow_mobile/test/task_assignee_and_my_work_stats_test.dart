import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/core/widgets/task_card.dart';
import 'package:teamflow_mobile/features/auth/presentation/pages/home_page.dart';
import 'package:teamflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/stats_providers.dart';
import 'package:teamflow_mobile/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/workspaces_providers.dart';
import 'package:teamflow_mobile/features/dashboard/data/models/workspace_model.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/user_entity.dart';
import 'workspace_switching_and_counters_test.dart';

void main() {
  testWidgets('TaskCard renders assignee name dynamically from task.assignedTo object', (WidgetTester tester) async {
    final task = TaskEntity(
      id: 't-assigned',
      title: 'Fix assignee rendering',
      status: TaskStatus.TODO,
      projectId: 'p1',
      createdById: 'u1',
      assignedToId: 'u2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      assignedTo: const TaskAssigneeEntity(
        id: 'u2',
        name: 'Bob Ross',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    // Verify Bob Ross is rendered
    expect(find.text('Bob Ross'), findsOneWidget);
    expect(find.text('Assign task'), findsNothing);
  });

  testWidgets('TaskCard renders Assign task when task.assignedTo is null', (WidgetTester tester) async {
    final task = TaskEntity(
      id: 't-unassigned',
      title: 'Write some tests',
      status: TaskStatus.TODO,
      projectId: 'p1',
      createdById: 'u1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    // Verify Assign task is rendered instead of Unassigned
    expect(find.text('Assign task'), findsOneWidget);
    expect(find.text('Unassigned'), findsNothing);
  });

  testWidgets('My Work page tabs display dynamic backend-driven counts and filter correctly', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeTeams = FakeTeamsStateNotifier();
    final fakeAuth = FakeAuthStateNotifier();

    final testTasks = [
      TaskEntity(
        id: 't1',
        title: 'Assigned Task 1',
        status: TaskStatus.IN_PROGRESS,
        projectId: 'p1',
        createdById: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TaskEntity(
        id: 't2',
        title: 'Completed Task',
        status: TaskStatus.DONE,
        projectId: 'p1',
        createdById: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        workspacesListProvider.overrideWith((ref) => [
          const WorkspaceModel(id: 'w1', name: 'Work 1', ownerId: 'u1', createdAt: ''),
        ]),
        dashboardStatsProvider.overrideWith((ref) => const DashboardStatsModel(
          tasksDueToday: 0,
          inProgress: 1,
          inReview: 0,
          blocked: 0,
          completedThisWeek: 1,
        )),
        authStateNotifierProvider.overrideWith((ref) => fakeAuth),
        myTasksProvider.overrideWith((ref) => testTasks),
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

    // Verify section header is My Work
    expect(find.text('My Work'), findsAtLeastNWidgets(2));

    // Verify tabs are present
    expect(find.text('Assigned'), findsAtLeastNWidgets(1));
    expect(find.text('In Progress'), findsAtLeastNWidgets(1));
    expect(find.text('Completed'), findsAtLeastNWidgets(1));

    // Default tab is Assigned, so both tasks are visible
    expect(find.text('Assigned Task 1'), findsOneWidget);
    expect(find.text('Completed Task'), findsOneWidget);

    final tabFinder = find.byWidgetPredicate(
      (widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal,
    );

    // Tap In Progress tab
    await tester.tap(find.descendant(of: tabFinder, matching: find.text('In Progress')));
    await tester.pumpAndSettle();

    // Only In Progress task visible
    expect(find.text('Assigned Task 1'), findsOneWidget);
    expect(find.text('Completed Task'), findsNothing);

    // Tap Completed tab
    await tester.tap(find.descendant(of: tabFinder, matching: find.text('Completed')));
    await tester.pumpAndSettle();

    // Only Completed task visible
    expect(find.text('Assigned Task 1'), findsNothing);
    expect(find.text('Completed Task'), findsOneWidget);
  });
}
