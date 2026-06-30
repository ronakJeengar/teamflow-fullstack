import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../data/models/sprint_model.dart';
import '../../domain/repositories/sprints_repository.dart';
import 'sprints_providers.dart';

class SprintController extends StateNotifier<AsyncValue<void>> {
  final SprintsRepository repository;
  final Ref ref;

  SprintController({
    required this.repository,
    required this.ref,
  }) : super(const AsyncData(null));

  Future<bool> createSprint(
    String projectId, {
    required String name,
    String? goal,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncLoading();
    final result = await repository.createSprint(
      projectId,
      name: name,
      goal: goal,
      startDate: startDate,
      endDate: endDate,
    );
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (sprint) {
        state = const AsyncData(null);
        ref.invalidate(sprintsListProvider(projectId));
        return true;
      },
    );
  }

  Future<bool> updateSprint(
    String id, {
    required String projectId,
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
    SprintStatus? status,
  }) async {
    state = const AsyncLoading();
    final result = await repository.updateSprint(
      id,
      name: name,
      goal: goal,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (sprint) {
        state = const AsyncData(null);
        ref.invalidate(sprintsListProvider(projectId));
        ref.invalidate(sprintDetailsProvider(id));
        return true;
      },
    );
  }

  Future<bool> deleteSprint(String id, String projectId) async {
    state = const AsyncLoading();
    final result = await repository.deleteSprint(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(sprintsListProvider(projectId));
        return true;
      },
    );
  }

  Future<bool> assignTasks(String id, String projectId, List<String> taskIds) async {
    state = const AsyncLoading();
    final result = await repository.assignTasks(id, taskIds);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(sprintDetailsProvider(id));
        ref.invalidate(sprintStatsProvider(id));
        ref.invalidate(sprintBurndownProvider(id));
        return true;
      },
    );
  }

  Future<bool> removeTask(String id, String projectId, String taskId) async {
    state = const AsyncLoading();
    final result = await repository.removeTask(id, taskId);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(sprintDetailsProvider(id));
        ref.invalidate(sprintStatsProvider(id));
        ref.invalidate(sprintBurndownProvider(id));
        return true;
      },
    );
  }

  Future<bool> startSprint(String id, String projectId) async {
    state = const AsyncLoading();
    final result = await repository.startSprint(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (sprint) {
        state = const AsyncData(null);
        ref.invalidate(sprintsListProvider(projectId));
        ref.invalidate(sprintDetailsProvider(id));
        ref.invalidate(sprintStatsProvider(id));
        return true;
      },
    );
  }

  Future<bool> completeSprint(String id, String projectId, {bool force = false}) async {
    state = const AsyncLoading();
    final result = await repository.completeSprint(id, force: force);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (sprint) {
        state = const AsyncData(null);
        ref.invalidate(sprintsListProvider(projectId));
        ref.invalidate(sprintDetailsProvider(id));
        ref.invalidate(sprintStatsProvider(id));
        ref.invalidate(sprintBurndownProvider(id));
        ref.invalidate(sprintVelocityProvider(id));
        return true;
      },
    );
  }

  Future<bool> cancelSprint(String id, String projectId) async {
    state = const AsyncLoading();
    final result = await repository.cancelSprint(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (sprint) {
        state = const AsyncData(null);
        ref.invalidate(sprintsListProvider(projectId));
        ref.invalidate(sprintDetailsProvider(id));
        ref.invalidate(sprintStatsProvider(id));
        return true;
      },
    );
  }
}

final sprintControllerProvider = StateNotifierProvider<SprintController, AsyncValue<void>>((ref) {
  return SprintController(
    repository: ref.watch(sprintsRepositoryProvider),
    ref: ref,
  );
});
