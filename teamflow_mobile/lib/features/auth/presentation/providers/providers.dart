import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_current_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_state_notifier.dart';
import 'login_controller.dart';
import 'signup_controller.dart';

final authStateNotifierProvider =
StateNotifierProvider<AuthStateNotifier, AuthState>(
      (ref) => AuthStateNotifier(sl<GetCurrentUserUseCase>()),
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
