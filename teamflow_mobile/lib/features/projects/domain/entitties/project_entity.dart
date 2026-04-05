import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_entity.freezed.dart';

@freezed
abstract class ProjectCountEntity with _$ProjectCountEntity {
  const factory ProjectCountEntity({
    required int tasks,
  }) = _ProjectCountEntity;
}

@freezed
abstract class ProjectEntity with _$ProjectEntity {
  const factory ProjectEntity({
    required String id,
    required String name,
    required String ownerId,
    required String createdAt,

    ProjectCountEntity? count,
  }) = _ProjectEntity;
}