import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teamflow_mobile/core/router/routes.dart';

import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_notifier_listener.dart';
import '../../features/auth/presentation/providers/auth_state_notifier.dart';
import '../../features/auth/presentation/providers/providers.dart';
import '../navigation/navigation_helper.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStateNotifierProvider.notifier);
  final refreshListenable = AuthNotifierListener(authNotifier);

  return GoRouter(
    navigatorKey: NavigationHelper.navigatorKey, // Add this line
    initialLocation: Routes.splash,
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: Routes.splash,
        name: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.login,
        name: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signup,
        name: RouteNames.signup,
        builder: (_, __) => const SignUpPage(),
      ),
      GoRoute(
        path: Routes.home,
        name: RouteNames.home,
        builder: (_, __) => const HomePage(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateNotifierProvider);
      final currentLocation = state.fullPath;

      if (authState.status == AuthStatus.unknown) return Routes.splash;

      if (authState.status == AuthStatus.unauthenticated &&
          currentLocation != Routes.login &&
          currentLocation != Routes.signup) {
        return Routes.login;
      }

      if (authState.status == AuthStatus.authenticated &&
          (currentLocation == Routes.login ||
              currentLocation == Routes.signup ||
              currentLocation == Routes.splash)) {
        return Routes.home;
      }

      return null;
    },
  );
});