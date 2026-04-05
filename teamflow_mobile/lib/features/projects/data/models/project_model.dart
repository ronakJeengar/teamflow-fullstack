import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_model.freezed.dart';

part 'project_model.g.dart';

@freezed
abstract class ProjectCount with _$ProjectCount {
  const factory ProjectCount({required int tasks}) = _ProjectCount;

  factory ProjectCount.fromJson(Map<String, dynamic> json) =>
      _$ProjectCountFromJson(json);
}

@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    required String ownerId,
    required String createdAt,

    @JsonKey(name: '_count') ProjectCount? count,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
