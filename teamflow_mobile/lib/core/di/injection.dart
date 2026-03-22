import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/presentation/providers/auth_state_notifier.dart';
import '../../features/auth/presentation/providers/login_controller.dart';
import '../../features/auth/presentation/providers/signup_controller.dart';
import '../services/api_service.dart';

final sl = GetIt.instance;

Future<void> setupDI({String baseUrl = 'http://10.0.2.2:3000/api/v1/'}) async {
  // -------------------
  // Core Services
  // -------------------
  sl.registerLazySingleton<ApiService>(() => ApiService(baseUrl: baseUrl));
  sl.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ),
  );

  // -------------------
  // Data sources
  // -------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // -------------------
  // Repositories
  // -------------------
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // -------------------
  // Use Cases
  // -------------------
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<SignupUseCase>(() => SignupUseCase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl()),
  );

  // -------------------
  // Providers / Notifiers
  // -------------------
  sl.registerFactory<AuthStateNotifier>(
    () => AuthStateNotifier(sl<GetCurrentUserUseCase>()),
  );

  // LoginController depends on AuthStateNotifier, so we use factory
  sl.registerFactory<LoginController>(
    () => LoginController(
      loginUseCase: sl<LoginUseCase>(),
      authStateNotifier: sl<AuthStateNotifier>(),
    ),
  );

  // SignupController depends on AuthStateNotifier, so we use factory
  sl.registerFactory<SignupController>(
    () => SignupController(
      signupUseCase: sl<SignupUseCase>(),
      authStateNotifier: sl<AuthStateNotifier>(),
    ),
  );
}
