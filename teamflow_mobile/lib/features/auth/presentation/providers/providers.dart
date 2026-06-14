import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/di/injection.dart';

import '../../../invitation/presentation/providers/invitations_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../teams/presentation/providers/team_details_providers.dart';
import '../../../teams/presentation/providers/teams_providers.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_memberships_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

import 'auth_state_notifier.dart';
import 'login_controller.dart';
import 'logout_controller.dart';
import 'signup_controller.dart';

final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>(
      (ref) => AuthStateNotifier(
        sl<GetCurrentUserUseCase>(),
        sl<GetMyMembershipsUseCase>(),
      ),
    );

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>(
      (ref) => LoginController(
        loginUseCase: sl<LoginUseCase>(),
        authStateNotifier: ref.read(authStateNotifierProvider.notifier),
      ),
    );

final signupControllerProvider =
    StateNotifierProvider<SignupController, AsyncValue<void>>(
      (ref) => SignupController(
        signupUseCase: sl<SignupUseCase>(),
        authStateNotifier: ref.read(authStateNotifierProvider.notifier),
      ),
    );

final logoutControllerProvider =
    StateNotifierProvider<LogoutController, AsyncValue<void>>(
      (ref) => LogoutController(
        logoutUseCase: sl<LogoutUseCase>(),
        authStateNotifier: ref.read(authStateNotifierProvider.notifier),

        // Clear app state on logout
        teamsStateNotifier: ref.read(teamsStateNotifierProvider.notifier),

        teamDetailStateNotifier: ref.read(
          teamDetailStateNotifierProvider.notifier,
        ),

        tasksStateNotifier: ref.read(taskStateNotifierProvider.notifier),

        invitationsStateNotifier: ref.read(
          invitationsStateNotifierProvider.notifier,
        ),
      ),
    );
