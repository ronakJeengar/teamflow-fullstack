import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_state_notifier.dart';

class SignupController extends StateNotifier<AsyncValue<void>> {
  final SignupUseCase signupUseCase;
  final AuthStateNotifier authStateNotifier;

  SignupController({
    required this.signupUseCase,
    required this.authStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> signup(String name, String email, String password) async {
    state = const AsyncLoading();

    final result = await signupUseCase(
      SignupParams(name: name, email: email, password: password),
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
