import '../../features/projects/data/models/project_model.dart';
import '../../features/projects/domain/entitties/project_entity.dart';

extension ProjectModelMapper on Project {
  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      ownerId: ownerId,
      createdAt: createdAt,
      count: count?.toEntity(),
    );
  }
}

extension ProjectCountMapper on ProjectCount {
  ProjectCountEntity toEntity() {
    return ProjectCountEntity(tasks: tasks);
  }
}

extension ProjectEntityMapper on ProjectEntity {
  Project toModel() {
    return Project(
      id: id,
      name: name,
      ownerId: ownerId,
      createdAt: createdAt,
      count: count?.toModel(),
    );
  }
}

extension ProjectCountEntityMapper on ProjectCountEntity {
  ProjectCount toModel() {
    return ProjectCount(tasks: tasks);
  }
}
