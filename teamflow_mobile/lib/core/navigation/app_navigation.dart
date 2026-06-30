// lib/core/navigation/app_navigation.dart

import '../router/routes.dart';
import 'package:teamflow_mobile/core/navigation/navigation_helper.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';

extension AppNavigation on NavigationHelper {
  // Auth Navigation
  void goToSplash() => goToNamed(RouteNames.splash);

  void goToLogin() => goToNamed(RouteNames.login);

  void goToSignup() => goToNamed(RouteNames.signup);

  void goToHome() => goToNamed(RouteNames.home);

  void goToProjects() => goToNamed(RouteNames.projects);

  // Teams
  void goToTeams() => goToNamed(RouteNames.teams);

  void goToTeamDetails(String teamId) =>
      goToNamed(RouteNames.teamDetails, params: {'teamId': teamId});

  // Invitations
  void goToInvitations() => goToNamed(RouteNames.invitations);

  // Tasks
  void goToTasks(String projectId, String teamId) => goToNamed(
    RouteNames.tasks,
    params: {'projectId': projectId, 'teamId': teamId},
  );

  // Settings
  void goToSettings() => goToNamed(RouteNames.settings);

  // Push variants
  void pushLogin() => pushNamed(RouteNames.login);

  void pushSignup() => pushNamed(RouteNames.signup);

  void pushHome() => pushNamed(RouteNames.home);

  void pushProjects() => pushNamed(RouteNames.projects);

  void pushTeams() => pushNamed(RouteNames.teams);

  void pushInvitations() => pushNamed(RouteNames.invitations);

  void pushTeamDetails(String teamId) =>
      pushNamed(RouteNames.teamDetails, params: {'teamId': teamId});

  void pushTasks(String projectId, String teamId) => pushNamed(
    RouteNames.tasks,
    params: {'projectId': projectId, 'teamId': teamId},
  );

  void pushTaskDetail({
    required String teamId,
    required String projectId,
    required String taskId,
    required TaskEntity task,
    required String projectName,
  }) =>
      pushNamed(
        RouteNames.taskDetail,
        params: {'teamId': teamId, 'projectId': projectId, 'taskId': taskId},
        extra: {'task': task, 'projectName': projectName},
      );

  void pushSettings() => pushNamed(RouteNames.settings);

  // Replace variants
  void replaceWithLogin() => replaceNamed(RouteNames.login);

  void replaceWithSignup() => replaceNamed(RouteNames.signup);

  void replaceWithHome() => replaceNamed(RouteNames.home);

  void replaceWithProjects() => replaceNamed(RouteNames.projects);

  void replaceWithTeams() => replaceNamed(RouteNames.teams);

  void replaceWithInvitations() => replaceNamed(RouteNames.invitations);

  void replaceWithTasks(String projectId, String teamId) => replaceNamed(
    RouteNames.tasks,
    params: {'projectId': projectId, 'teamId': teamId},
  );

  void replaceWithSettings() => replaceNamed(RouteNames.settings);
}
