// lib/core/navigation/app_navigation.dart
import '../router/routes.dart';
import 'navigation_helper.dart';

extension AppNavigation on NavigationHelper {
  // Auth Navigation
  void goToSplash() => goToNamed(RouteNames.splash);

  void goToLogin() => goToNamed(RouteNames.login);

  void goToSignup() => goToNamed(RouteNames.signup);

  void goToHome() => goToNamed(RouteNames.home);

  // Push variants (keeps previous screen in stack)
  void pushLogin() => pushNamed(RouteNames.login);

  void pushSignup() => pushNamed(RouteNames.signup);

  void pushHome() => pushNamed(RouteNames.home);

  // Replace variants (removes previous screen from stack)
  void replaceWithLogin() => replaceNamed(RouteNames.login);

  void replaceWithSignup() => replaceNamed(RouteNames.signup);

  void replaceWithHome() => replaceNamed(RouteNames.home);
}
