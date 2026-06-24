import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/core/error/failures.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/stats_providers.dart';
import 'package:teamflow_mobile/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/creaet_task_usecase.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:teamflow_mobile/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:teamflow_mobile/features/tasks/domain/repository/tasks_repository.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_state_notifier.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/create_task_controller.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/update_task_controller.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/delete_task_controller.dart';

// ── Dummy Use Cases ──────────────────────────────────────

class DummyTasksRepository implements TasksRepository {
  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(String projectId) async => const Right([]);
  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    required String projectId,
    String? assigneeId,
    String? status,
    String? priority,
  }) async => throw UnimplementedError();
  @override
  Future<Either<Failure, TaskEntity>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assigneeId,
  }) async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async => throw UnimplementedError();
  @override
  Future<Either<Failure, List<TaskEntity>>> getMyTasks() async => const Right([]);
}

class FakeCreateTaskUseCase implements CreateTaskUseCase {
  @override
  TasksRepository get repository => DummyTasksRepository();
  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) async {
    return Right(TaskEntity(
      id: 't-new',
      title: params.title,
      status: TaskStatus.TODO,
      projectId: params.projectId,
      createdById: 'u1',
      assignedToId: 'u1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }
}

class FakeUpdateTaskUseCase implements UpdateTaskUseCase {
  @override
  TasksRepository get repository => DummyTasksRepository();
  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) async {
    return Right(TaskEntity(
      id: params.taskId,
      title: params.title ?? 'Updated Title',
      status: params.status != null ? TaskStatus.values.byName(params.status!) : TaskStatus.IN_PROGRESS,
      projectId: 'p1',
      createdById: 'u1',
      assignedToId: 'u1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }
}

class FakeDeleteTaskUseCase implements DeleteTaskUseCase {
  @override
  TasksRepository get repository => DummyTasksRepository();
  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return const Right(null);
  }
}

class FakeGetTasksUseCase implements GetTasksUseCase {
  @override
  TasksRepository get repository => DummyTasksRepository();
  @override
  Future<Either<Failure, List<TaskEntity>>> call(GetTasksParams params) async => const Right([]);
}

class FakeTasksStateNotifier extends TasksStateNotifier {
  FakeTasksStateNotifier() : super(getTasksUseCase: FakeGetTasksUseCase()) {
    state = TasksState.loaded([
      TaskEntity(
        id: 't1',
        title: 'Task 1',
        status: TaskStatus.TODO,
        projectId: 'p1',
        createdById: 'u1',
        assignedToId: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }
}

void main() {
  test('Task creation, update, status move, and deletion trigger invalidations', () async {
    int tasksInvalidatedCount = 0;
    int statsInvalidatedCount = 0;

    final mockTasksNotifier = FakeTasksStateNotifier();

    final container = ProviderContainer(
      overrides: [
        myTasksProvider.overrideWith((ref) {
          tasksInvalidatedCount++;
          return [];
        }),
        dashboardStatsProvider.overrideWith((ref) {
          statsInvalidatedCount++;
          return const DashboardStatsModel(
            tasksDueToday: 0,
            inProgress: 0,
            inReview: 0,
            blocked: 0,
            completedThisWeek: 0,
          );
        }),
        createTaskControllerProvider.overrideWith((ref) => CreateTaskController(
          createTaskUseCase: FakeCreateTaskUseCase(),
          taskStateNotifier: mockTasksNotifier,
          ref: ref,
        )),
        updateTaskControllerProvider.overrideWith((ref) => UpdateTaskController(
          updateTaskUseCase: FakeUpdateTaskUseCase(),
          taskStateNotifier: mockTasksNotifier,
          ref: ref,
        )),
        deleteTaskControllerProvider.overrideWith((ref) => DeleteTaskController(
          deleteTaskUseCase: FakeDeleteTaskUseCase(),
          taskStateNotifier: mockTasksNotifier,
          ref: ref,
        )),
      ],
    );

    // Listen to the providers to ensure they actively track updates and rebuild immediately when invalidated.
    final tasksSub = container.listen(myTasksProvider, (previous, next) {});
    final statsSub = container.listen(dashboardStatsProvider, (previous, next) {});

    expect(tasksInvalidatedCount, equals(1));
    expect(statsInvalidatedCount, equals(1));

    final createController = container.read(createTaskControllerProvider.notifier);
    final updateController = container.read(updateTaskControllerProvider.notifier);
    final deleteController = container.read(deleteTaskControllerProvider.notifier);

    // 1. Create Task -> Invalidates both
    await createController.createTask(projectId: 'p1', title: 'New Task');
    await Future.delayed(Duration.zero);
    expect(tasksInvalidatedCount, equals(2));
    expect(statsInvalidatedCount, equals(2));

    // 2. Update Task -> Invalidates both
    await updateController.updateTask(projectId: 'p1', taskId: 't1', title: 'Updated Task');
    await Future.delayed(Duration.zero);
    expect(tasksInvalidatedCount, equals(3));
    expect(statsInvalidatedCount, equals(3));

    // 3. Move Task Status -> Invalidates both
    await updateController.moveTask(taskId: 't1', newStatus: TaskStatus.IN_PROGRESS);
    await Future.delayed(Duration.zero);
    expect(tasksInvalidatedCount, equals(4));
    expect(statsInvalidatedCount, equals(4));

    // 4. Delete Task -> Invalidates both
    await deleteController.deleteTask(projectId: 'p1', taskId: 't1');
    await Future.delayed(Duration.zero);
    expect(tasksInvalidatedCount, equals(5));
    expect(statsInvalidatedCount, equals(5));

    tasksSub.close();
    statsSub.close();
  });
}
