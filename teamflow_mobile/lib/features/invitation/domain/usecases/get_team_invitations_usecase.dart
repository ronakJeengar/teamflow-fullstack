import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/invitation_entity.dart';
import '../repository/invitation_repository.dart';

class GetTeamInvitationsParams {
  final String teamId;

  const GetTeamInvitationsParams({required this.teamId});
}

class GetTeamInvitationsUseCase
    extends UseCase<List<InvitationEntity>, GetTeamInvitationsParams> {
  final InvitationRepository repository;

  GetTeamInvitationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<InvitationEntity>>> call(
      GetTeamInvitationsParams params,
      ) {
    return repository.getTeamInvitations(params.teamId);
  }
}