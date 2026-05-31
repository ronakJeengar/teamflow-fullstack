import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entitties/project_entity.dart';

abstract class ProjectsRepository {
  /// Create Project
  Future<Either<Failure, ProjectEntity>> createProject({
    required String teamId,
    required String name,
    String? description,
  });

  /// Get Projects By Team
  Future<Either<Failure, List<ProjectEntity>>> getProjectsByTeamId(
    String teamId,
  );

  /// Update Project
  Future<Either<Failure, ProjectEntity>> updateProject({
    required String teamId,
    required String projectId,
    required String name,
    String? description,
  });

  /// Delete Project
  Future<Either<Failure, void>> deleteProject({
    required String teamId,
    required String projectId,
  });
}
