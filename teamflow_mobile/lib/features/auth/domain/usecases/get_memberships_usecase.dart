import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/membership_entity.dart';
import '../repositories/auth_repository.dart';

class GetMyMembershipsUseCase extends NoParams<List<MembershipEntity>> {
  final AuthRepository repository;

  GetMyMembershipsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MembershipEntity>>> call() {
    return repository.getMyMemberships();
  }
}
