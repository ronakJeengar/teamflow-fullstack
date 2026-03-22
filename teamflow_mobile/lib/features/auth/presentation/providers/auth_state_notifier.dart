import 'package:hooks_riverpod/legacy.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.authenticated(User user)
      : this(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated({String? message})
      : this(status: AuthStatus.unauthenticated, errorMessage: message);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthStateNotifier(this.getCurrentUserUseCase) : super(const AuthState.unknown()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final result = await getCurrentUserUseCase();

    result.fold(
          (failure) => state = AuthState.unauthenticated(
          message: failure.message),
          (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      },
    );
  }

  void setUnauthenticated({String? message}) {
    state = AuthState.unauthenticated(message: message);
  }

  void setAuthenticated(User user) {
    state = AuthState.authenticated(user);
  }
}
