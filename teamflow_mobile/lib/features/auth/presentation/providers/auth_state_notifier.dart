import 'package:hooks_riverpod/legacy.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/membership_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_memberships_usecase.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final List<MembershipEntity> memberships;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.memberships = const [],
    this.errorMessage,
  });

  const AuthState.unknown()
      : this(
    status: AuthStatus.unknown,
  );

  const AuthState.authenticated(
      UserEntity user, {
        List<MembershipEntity> memberships = const [],
      }) : this(
    status: AuthStatus.authenticated,
    user: user,
    memberships: memberships,
  );

  const AuthState.unauthenticated({
    String? message,
  }) : this(
    status: AuthStatus.unauthenticated,
    errorMessage: message,
  );

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    List<MembershipEntity>? memberships,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      memberships: memberships ?? this.memberships,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetMyMembershipsUseCase getMyMembershipsUseCase;

  AuthStateNotifier(
      this.getCurrentUserUseCase,
      this.getMyMembershipsUseCase,
      ) : super(const AuthState.unknown()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final result = await getCurrentUserUseCase();

    await result.fold(
          (failure) async {
        state = AuthState.unauthenticated(
          message: failure.message,
        );
      },
          (user) async {
        if (user == null) {
          state = const AuthState.unauthenticated();
          return;
        }

        await authenticate(user);
      },
    );
  }

  /// Call after successful login/signup
  Future<void> authenticate(UserEntity user) async {
    final membershipsResult = await getMyMembershipsUseCase();

    membershipsResult.fold(
          (_) {
        state = AuthState.authenticated(user);
      },
          (memberships) {
        state = AuthState.authenticated(
          user,
          memberships: memberships,
        );
      },
    );
  }

  void setUnauthenticated({String? message}) {
    state = AuthState.unauthenticated(
      message: message,
    );
  }

  Future<void> refreshMemberships() async {
    if (state.user == null) return;

    final result = await getMyMembershipsUseCase();

    result.fold(
          (_) {},
          (memberships) {
        state = state.copyWith(
          memberships: memberships,
        );
      },
    );
  }

  Future<void> refreshUserSession() async {
    final result = await getCurrentUserUseCase();
    await result.fold(
      (_) async {},
      (user) async {
        if (user != null) {
          await authenticate(user);
        }
      },
    );
  }

  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? bio,
    String? password,
  }) async {
    final authRepository = sl<AuthRepository>();
    final result = await authRepository.updateProfile(
      name: name,
      bio: bio,
      password: password,
    );
    result.fold(
      (_) {},
      (user) {
        state = state.copyWith(user: user);
      },
    );
    return result;
  }
}