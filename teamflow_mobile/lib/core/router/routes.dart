class Routes {
  Routes._();

  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const teams = '/teams';
  static const teamDetails = '/teams/:teamId'; // ← parameterised path
  static String teamDetailPath(String teamId) => '/teams/$teamId';
}

class RouteNames {
  RouteNames._();

  static const splash = 'splash';
  static const login = 'login';
  static const signup = 'signup';
  static const home = 'home';
  static const teams = 'teams';
  static const teamDetails = 'team-details';
}
