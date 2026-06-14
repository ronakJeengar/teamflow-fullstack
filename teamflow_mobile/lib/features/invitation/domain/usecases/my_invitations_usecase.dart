import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../entities/invitation_entity.dart';
import '../repository/invitation_repository.dart';

class MyInvitationsUseCase
    extends NoParams<List<InvitationEntity>> {
  final InvitationRepository repository;

  MyInvitationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<InvitationEntity>>> call() {
    return repository.getMyInvitations();
  }
}