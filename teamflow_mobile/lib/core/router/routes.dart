class Routes {
  Routes._();

  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  // Teams
  static const teams = '/teams';
  static const teamDetails = '/teams/:teamId';

  static String teamDetailPath(String teamId) => '/teams/$teamId';

  // Invitations
  static const invitations = '/invitations';

  // Tasks
  static const tasks = '/projects/:projectId/tasks';

  static String tasksPath(String projectId) => '/projects/$projectId/tasks';
}

class RouteNames {
  RouteNames._();

  static const splash = 'splash';
  static const login = 'login';
  static const signup = 'signup';
  static const home = 'home';

  // Teams
  static const teams = 'teams';
  static const teamDetails = 'team-details';

  // Invitations
  static const invitations = 'invitations';

  // Tasks
  static const tasks = 'tasks';
}
