class Routes {
  Routes._();

  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const projects = '/projects';

  // Teams
  static const teams = '/teams';
  static const teamDetails = '/teams/:teamId';

  static String teamDetailPath(String teamId) => '/teams/$teamId';

  // Invitations
  static const invitations = '/invitations';

  // Tasks
  static const tasks = '/teams/:teamId/projects/:projectId/tasks';

  static String tasksPath(String teamId, String projectId) => '/teams/$teamId/projects/$projectId/tasks';

  // Settings
  static const settings = '/settings';
}

class RouteNames {
  RouteNames._();

  static const splash = 'splash';
  static const login = 'login';
  static const signup = 'signup';
  static const home = 'home';
  static const projects = 'projects';

  // Teams
  static const teams = 'teams';
  static const teamDetails = 'team-details';

  // Invitations
  static const invitations = 'invitations';

  // Tasks
  static const tasks = 'tasks';

  // Settings
  static const settings = 'settings';
}
