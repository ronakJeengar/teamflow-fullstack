import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/invitation_repository.dart';

class CancelInvitationParams {
  final String teamId;
  final String token;

  const CancelInvitationParams({required this.teamId, required this.token});
}

class CancelInvitationUseCase extends UseCase<void, CancelInvitationParams> {
  final InvitationRepository repository;

  CancelInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelInvitationParams params) {
    return repository.cancelInvitation(
      teamId: params.teamId,
      token: params.token,
    );
  }
}
