import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/utils/failure_mapper.dart';
import '../../data/models/task_model.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_state_notifier.dart';

class UpdateTaskController extends StateNotifier<AsyncValue<void>> {
  final UpdateTaskUseCase updateTaskUseCase;
  final TasksStateNotifier taskStateNotifier;

  UpdateTaskController({
    required this.updateTaskUseCase,
    required this.taskStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required String title,
  }) async {
    state = const AsyncLoading();

    final result = await updateTaskUseCase(
      UpdateTaskParams(taskId: taskId, title: title),
    );

    result.fold(
      (failure) {
        state = AsyncError(mapFailureToMessage(failure), StackTrace.current);
      },
      (task) {
        taskStateNotifier.replaceTask(task);
        state = const AsyncData(null);
      },
    );
  }

  Future<void> moveTask({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    // Find previous status before optimistic update
    final previousStatus = taskStateNotifier.state.tasks
        .firstWhere((t) => t.id == taskId)
        .status;

    // Optimistic update immediately
    taskStateNotifier.moveTask(taskId, newStatus);

    final result = await updateTaskUseCase(
      UpdateTaskParams(taskId: taskId, status: newStatus.name),
    );

    result.fold(
      (failure) {
        // Revert on failure
        taskStateNotifier.revertTask(taskId, previousStatus);
        state = AsyncError(mapFailureToMessage(failure), StackTrace.current);
      },
      (task) {
        taskStateNotifier.replaceTask(task);
        state = const AsyncData(null);
      },
    );
  }
}
