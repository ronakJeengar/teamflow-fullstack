import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignupParams {
  final String name;
  final String email;
  final String password;

  const SignupParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

class SignupUseCase extends UseCase<UserEntity, SignupParams> {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignupParams params) {
    return repository.signup(params.email, params.name, params.password);
  }
}
