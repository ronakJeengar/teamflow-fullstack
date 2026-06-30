import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/sprint_model.dart';
import '../../domain/repositories/sprints_repository.dart';

final sprintsRepositoryProvider = Provider<SprintsRepository>((ref) {
  return sl<SprintsRepository>();
});

final sprintsListProvider = FutureProvider.family<List<SprintModel>, String>((ref, projectId) async {
  final repository = ref.watch(sprintsRepositoryProvider);
  final result = await repository.getSprints(projectId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (sprints) => sprints,
  );
});

final sprintDetailsProvider = FutureProvider.family<SprintModel, String>((ref, sprintId) async {
  final repository = ref.watch(sprintsRepositoryProvider);
  final result = await repository.getSprintById(sprintId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (sprint) => sprint,
  );
});

final sprintStatsProvider = FutureProvider.family<SprintStatsModel, String>((ref, sprintId) async {
  final repository = ref.watch(sprintsRepositoryProvider);
  final result = await repository.getStats(sprintId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});

final sprintBurndownProvider = FutureProvider.family<List<BurndownEntryModel>, String>((ref, sprintId) async {
  final repository = ref.watch(sprintsRepositoryProvider);
  final result = await repository.getBurndown(sprintId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

final sprintVelocityProvider = FutureProvider.family<VelocityModel, String>((ref, sprintId) async {
  final repository = ref.watch(sprintsRepositoryProvider);
  final result = await repository.getVelocity(sprintId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (velocity) => velocity,
  );
});
