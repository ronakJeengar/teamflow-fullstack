import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Use this for use cases that require parameters
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this for use cases that do NOT require parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}
