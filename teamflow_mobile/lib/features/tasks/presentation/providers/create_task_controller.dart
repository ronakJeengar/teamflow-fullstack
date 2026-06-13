import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/creaet_task_usecase.dart';
import 'task_state_notifier.dart';

class CreateTaskController extends StateNotifier<AsyncValue<void>> {
  final CreateTaskUseCase createTaskUseCase;
  final TasksStateNotifier taskStateNotifier;

  CreateTaskController({
    required this.createTaskUseCase,
    required this.taskStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> createTask({
    required String projectId,
    required String title,
  }) async {
    state = const AsyncLoading();

    final result = await createTaskUseCase(
      CreateTaskParams(projectId: projectId, title: title),
    );

    result.fold(
      (failure) {
        state = AsyncError(mapFailureToMessage(failure), StackTrace.current);
      },
      (task) {
        taskStateNotifier.addTask(task);
        state = const AsyncData(null);
      },
    );
  }
}
