import 'package:hooks_riverpod/legacy.dart';
import '../../data/models/task_model.dart';
import '../../domain/entitties/task_entity.dart';
import '../../domain/usecases/get_tasks_usecase.dart';

enum TasksStatus { unknown, loaded, error }

class TasksState {
  final TasksStatus status;
  final List<TaskEntity> tasks;
  final String? errorMessage;

  const TasksState({
    required this.status,
    this.tasks = const [],
    this.errorMessage,
  });

  const TasksState.unknown() : this(status: TasksStatus.unknown);

  const TasksState.loaded(List<TaskEntity> tasks)
    : this(status: TasksStatus.loaded, tasks: tasks);

  const TasksState.error(String message)
    : this(status: TasksStatus.error, errorMessage: message);

  TasksState copyWith({
    TasksStatus? status,
    List<TaskEntity>? tasks,
    String? errorMessage,
  }) => TasksState(
    status: status ?? this.status,
    tasks: tasks ?? this.tasks,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

class TasksStateNotifier extends StateNotifier<TasksState> {
  final GetTasksUseCase getTasksUseCase;

  TasksStateNotifier({required this.getTasksUseCase})
    : super(const TasksState.unknown());

  Future<void> loadTasks(String projectId) async {
    state = const TasksState.unknown();

    final result = await getTasksUseCase(GetTasksParams(projectId: projectId));

    result.fold(
      (failure) {
        state = TasksState.error(failure.message);
      },
      (tasks) {
        state = TasksState.loaded(tasks);
      },
    );
  }

  void addTask(TaskEntity task) {
    state = TasksState.loaded([...state.tasks, task]);
  }

  void replaceTask(TaskEntity updated) {
    state = TasksState.loaded(
      state.tasks
          .map((task) => task.id == updated.id ? updated : task)
          .toList(),
    );
  }

  void removeTask(String id) {
    state = TasksState.loaded(
      state.tasks.where((task) => task.id != id).toList(),
    );
  }

  void moveTask(String taskId, TaskStatus newStatus) {
    state = state.copyWith(
      tasks: state.tasks.map((task) {
        return task.id == taskId ? task.copyWith(status: newStatus) : task;
      }).toList(),
    );
  }

  void revertTask(String taskId, TaskStatus previousStatus) {
    state = state.copyWith(
      tasks: state.tasks.map((task) {
        return task.id == taskId ? task.copyWith(status: previousStatus) : task;
      }).toList(),
    );
  }

  void clear() {
    state = const TasksState.loaded([]);
  }
}
