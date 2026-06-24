import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/activity_model.dart';

abstract class ActivitiesRepository {
  Future<Either<Failure, List<ActivityModel>>> getTaskActivities(String taskId);
  Future<Either<Failure, List<ActivityModel>>> getProjectActivities(String projectId);
}
