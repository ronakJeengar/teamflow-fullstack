import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/di/injection.dart';

import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';



final taskStateNotifierProvider =
StateNotifierProvider<TaskStateNotifier, TaskState>(
      (ref) => TaskStateNotifier(
    getTasksUseCase: sl<GetTasksUseCase>(),
  ),
);

final createTaskControllerProvider =
StateNotifierProvider<CreateTaskController, AsyncValue<void>>(
      (ref) => CreateTaskController(
    createTaskUseCase: sl<CreateTaskUseCase>(),
    taskStateNotifier: ref.read(taskStateNotifierProvider.notifier),
  ),
);

final updateTaskControllerProvider =
StateNotifierProvider<UpdateTaskController, AsyncValue<void>>(
      (ref) => UpdateTaskController(
    updateTaskUseCase: sl<UpdateTaskUseCase>(),
    taskStateNotifier: ref.read(taskStateNotifierProvider.notifier),
  ),
);

final deleteTaskControllerProvider =
StateNotifierProvider<DeleteTaskController, AsyncValue<void>>(
      (ref) => DeleteTaskController(
    deleteTaskUseCase: sl<DeleteTaskUseCase>(),
    taskStateNotifier: ref.read(taskStateNotifierProvider.notifier),
  ),
);