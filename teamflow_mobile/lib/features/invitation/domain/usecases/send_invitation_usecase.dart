import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/invitation_repository.dart';

class SendInvitationParams {
  final String teamId;
  final String email;
  final String role;

  const SendInvitationParams({
    required this.teamId,
    required this.email,
    required this.role,
  });
}

class SendInvitationUseCase extends UseCase<void, SendInvitationParams> {
  final InvitationRepository repository;

  SendInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendInvitationParams params) {
    return repository.sendInvitation(
      teamId: params.teamId,
      email: params.email,
      role: params.role,
    );
  }
}
