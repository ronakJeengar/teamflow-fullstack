import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state_notifier.dart';

class LoginController extends StateNotifier<AsyncValue<void>> {
  final LoginUseCase loginUseCase;
  final AuthStateNotifier authStateNotifier;

  LoginController({required this.loginUseCase, required this.authStateNotifier})
    : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (user) {
        authStateNotifier.setAuthenticated(user);
        state = const AsyncData(null);
      },
    );
  }
}
