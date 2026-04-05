import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends NoParams<void> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
