import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import 'task_state_notifier.dart';

class DeleteTaskController extends StateNotifier<AsyncValue<void>> {
  final DeleteTaskUseCase deleteTaskUseCase;
  final TasksStateNotifier taskStateNotifier;

  DeleteTaskController({
    required this.deleteTaskUseCase,
    required this.taskStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    state = const AsyncLoading();

    final result = await deleteTaskUseCase(DeleteTaskParams(taskId: taskId));

    result.fold(
      (failure) {
        state = AsyncError(mapFailureToMessage(failure), StackTrace.current);
      },
      (_) {
        taskStateNotifier.removeTask(taskId);
        state = const AsyncData(null);
      },
    );
  }
}
