import '../../../tasks/data/models/task_model.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../teams/data/models/team_model.dart';

class SearchResultModel {
  final List<TaskModel> tasks;
  final List<Project> projects;
  final List<Team> teams;

  SearchResultModel({
    required this.tasks,
    required this.projects,
    required this.teams,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      projects: (json['projects'] as List? ?? [])
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      teams: (json['teams'] as List? ?? [])
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
