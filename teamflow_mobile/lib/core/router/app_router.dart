import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_notifier_listener.dart';
import '../../features/auth/presentation/providers/auth_state_notifier.dart';
import '../../features/auth/presentation/providers/providers.dart';
import '../../features/invitation/presentation/pages/invitation_page.dart';
import '../../features/projects/projects_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/tasks/domain/entitties/task_entity.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/tasks/task_detail_page.dart';
import '../../features/teams/presentation/pages/team_detail_page.dart';
import '../../features/teams/presentation/pages/teams_page.dart';
import '../navigation/navigation_helper.dart';
import 'routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStateNotifierProvider.notifier);

  return GoRouter(
    navigatorKey: NavigationHelper.navigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: AuthNotifierListener(authNotifier),

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

      GoRoute(
        path: Routes.projects,
        name: RouteNames.projects,
        builder: (_, __) => const ProjectsPage(),
      ),

      GoRoute(
        path: Routes.teams,
        name: RouteNames.teams,
        builder: (_, __) => const TeamsPage(),
      ),

      GoRoute(
        path: Routes.teamDetails,
        name: RouteNames.teamDetails,
        builder: (_, state) {
          final teamId = state.pathParameters['teamId']!;
          return TeamDetailPage(teamId: teamId);
        },
      ),

      GoRoute(
        path: Routes.invitations,
        name: RouteNames.invitations,
        builder: (_, __) => const InvitationsPage(),
      ),

      GoRoute(
        path: Routes.tasks,
        name: RouteNames.tasks,
        builder: (_, state) {
          final projectId = state.pathParameters['projectId']!;
          final teamId = state.pathParameters['teamId']!;
          return TasksPage(projectId: projectId, teamId: teamId,);
        },
      ),

      GoRoute(
        path: Routes.taskDetail,
        name: RouteNames.taskDetail,
        builder: (_, state) {
          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            final task = extra['task'] as TaskEntity;
            final projectName = extra['projectName'] as String;
            final teamId = state.pathParameters['teamId']!;
            return TaskDetailPage(task: task, projectName: projectName, teamId: teamId);
          }
          return const Scaffold(
            body: Center(
              child: Text('Task details not found'),
            ),
          );
        },
      ),

      GoRoute(
        path: Routes.settings,
        name: RouteNames.settings,
        builder: (_, __) => const SettingsPage(),
      ),
    ],

    redirect: (context, state) {
      final authState = ref.read(authStateNotifierProvider);
      final currentLocation = state.matchedLocation;

      // Still checking auth state
      if (authState.status == AuthStatus.unknown) {
        return currentLocation == Routes.splash ? null : Routes.splash;
      }

      // Not logged in
      if (authState.status == AuthStatus.unauthenticated) {
        final isAuthPage =
            currentLocation == Routes.login || currentLocation == Routes.signup;

        return isAuthPage ? null : Routes.login;
      }

      // Logged in
      if (authState.status == AuthStatus.authenticated) {
        final isAuthPage =
            currentLocation == Routes.splash ||
            currentLocation == Routes.login ||
            currentLocation == Routes.signup;

        if (isAuthPage) {
          final memberships = authState.memberships;

          // No memberships yet
          if (memberships.isEmpty) {
            return Routes.teams;
          }

          // Single membership and not admin/owner
          if (memberships.length == 1) {
            final membership = memberships.first;

            if (!['OWNER', 'ADMIN'].contains(membership.role)) {
              return Routes.teamDetailPath(membership.team.id);
            }
          }
          return Routes.teams;
        }

        // Redirect unauthorized team detail deep links
        if (currentLocation.startsWith('/teams/')) {
          final teamId = state.pathParameters['teamId'];
          if (teamId != null) {
            final hasAccess = authState.memberships.any((m) => m.team.id == teamId);
            if (!hasAccess) {
              return Routes.teams;
            }
          }
        }

        // Redirect unauthorized task board deep links
        if (currentLocation.startsWith('/teams/') && currentLocation.contains('/projects/') && currentLocation.endsWith('/tasks')) {
          final teamId = state.pathParameters['teamId'];
          if (teamId != null) {
            final hasAccess = authState.memberships.any((m) => m.team.id == teamId);
            if (!hasAccess) {
              return Routes.teams;
            }
          }
        }
      }
      return null;
    },
  );
});
