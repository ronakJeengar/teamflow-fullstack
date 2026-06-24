import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/creaet_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/repository/tasks_repository.dart';
import '../../domain/entitties/task_entity.dart';

import 'create_task_controller.dart';
import 'delete_task_controller.dart';
import 'task_state_notifier.dart';
import 'update_task_controller.dart';

final taskStateNotifierProvider =
StateNotifierProvider<TasksStateNotifier, TasksState>(
        (ref) => TasksStateNotifier(
        getTasksUseCase: sl<GetTasksUseCase>(),
    ),
);

final createTaskControllerProvider =
StateNotifierProvider<CreateTaskController, AsyncValue<void>>(
        (ref) => CreateTaskController(
        createTaskUseCase: sl<CreateTaskUseCase>(),
        taskStateNotifier: ref.read(taskStateNotifierProvider.notifier),
        ref: ref,
    ),
);

final updateTaskControllerProvider =
StateNotifierProvider<UpdateTaskController, AsyncValue<void>>(
        (ref) => UpdateTaskController(
        updateTaskUseCase: sl<UpdateTaskUseCase>(),
        taskStateNotifier: ref.read(taskStateNotifierProvider.notifier),
        ref: ref,
    ),
);

final deleteTaskControllerProvider =
StateNotifierProvider<DeleteTaskController, AsyncValue<void>>(
        (ref) => DeleteTaskController(
        deleteTaskUseCase: sl<DeleteTaskUseCase>(),
        taskStateNotifier: ref.read(taskStateNotifierProvider.notifier),
        ref: ref,
    ),
);

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return sl<TasksRepository>();
});

final myTasksProvider = FutureProvider<List<TaskEntity>>((ref) async {
  final repository = ref.watch(tasksRepositoryProvider);
  final result = await repository.getMyTasks();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tasks) => tasks,
  );
});