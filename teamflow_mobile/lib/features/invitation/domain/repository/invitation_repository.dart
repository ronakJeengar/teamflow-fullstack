import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/invitation_entity.dart';

abstract class InvitationRepository {
  Future<Either<Failure, void>> sendInvitation({
    required String teamId,
    required String email,
    required String role,
  });

  Future<Either<Failure, void>> acceptInvitation(String token);

  Future<Either<Failure, void>> cancelInvitation({
    required String teamId,
    required String token,
  });

  Future<Either<Failure, List<InvitationEntity>>> getMyInvitations();

  Future<Either<Failure, List<InvitationEntity>>> getTeamInvitations(
      String teamId,
      );
}