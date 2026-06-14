import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/invitation_repository.dart';

class AcceptInvitationParams {
  final String token;

  const AcceptInvitationParams({required this.token});
}

class AcceptInvitationUseCase extends UseCase<void, AcceptInvitationParams> {
  final InvitationRepository repository;

  AcceptInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AcceptInvitationParams params) {
    return repository.acceptInvitation(params.token);
  }
}
