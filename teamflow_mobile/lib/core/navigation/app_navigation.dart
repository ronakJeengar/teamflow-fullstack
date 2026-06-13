// lib/core/navigation/app_navigation.dart

import '../router/routes.dart';
import 'navigation_helper.dart';

extension AppNavigation on NavigationHelper {
  // Auth Navigation
  void goToSplash() => goToNamed(RouteNames.splash);

  void goToLogin() => goToNamed(RouteNames.login);

  void goToSignup() => goToNamed(RouteNames.signup);

  void goToHome() => goToNamed(RouteNames.home);

  // Teams
  void goToTeams() => goToNamed(RouteNames.teams);

  void goToTeamDetails(String teamId) =>
      goToNamed(RouteNames.teamDetails, params: {'teamId': teamId});

  // Invitations
  void goToInvitations() => goToNamed(RouteNames.invitations);

  // Tasks
  void goToTasks(String projectId) =>
      goToNamed(RouteNames.tasks, params: {'projectId': projectId});

  // Push variants
  void pushLogin() => pushNamed(RouteNames.login);

  void pushSignup() => pushNamed(RouteNames.signup);

  void pushHome() => pushNamed(RouteNames.home);

  void pushTeams() => pushNamed(RouteNames.teams);

  void pushInvitations() => pushNamed(RouteNames.invitations);

  void pushTeamDetails(String teamId) =>
      pushNamed(RouteNames.teamDetails, params: {'teamId': teamId});

  void pushTasks(String projectId) =>
      pushNamed(RouteNames.tasks, params: {'projectId': projectId});

  // Replace variants
  void replaceWithLogin() => replaceNamed(RouteNames.login);

  void replaceWithSignup() => replaceNamed(RouteNames.signup);

  void replaceWithHome() => replaceNamed(RouteNames.home);

  void replaceWithTeams() => replaceNamed(RouteNames.teams);

  void replaceWithInvitations() => replaceNamed(RouteNames.invitations);

  void replaceWithTasks(String projectId) =>
      replaceNamed(RouteNames.tasks, params: {'projectId': projectId});
}
