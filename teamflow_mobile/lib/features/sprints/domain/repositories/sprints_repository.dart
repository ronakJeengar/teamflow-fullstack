import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/sprint_model.dart';

abstract class SprintsRepository {
  Future<Either<Failure, List<SprintModel>>> getSprints(String projectId);
  Future<Either<Failure, SprintModel>> createSprint(
    String projectId, {
    required String name,
    String? goal,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<Either<Failure, SprintModel>> getSprintById(String id);
  Future<Either<Failure, SprintModel>> updateSprint(
    String id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
    SprintStatus? status,
  });
  Future<Either<Failure, void>> deleteSprint(String id);
  Future<Either<Failure, void>> assignTasks(String id, List<String> taskIds);
  Future<Either<Failure, void>> removeTask(String id, String taskId);
  Future<Either<Failure, SprintModel>> startSprint(String id);
  Future<Either<Failure, SprintModel>> completeSprint(String id, {bool force = false});
  Future<Either<Failure, SprintModel>> cancelSprint(String id);
  Future<Either<Failure, SprintStatsModel>> getStats(String id);
  Future<Either<Failure, List<BurndownEntryModel>>> getBurndown(String id);
  Future<Either<Failure, VelocityModel>> getVelocity(String id);
}
