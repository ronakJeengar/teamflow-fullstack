import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class InvitationsRepository {
  /// Send Invitation
  Future<Either<Failure, void>> sendInvitation({
    required String teamId,
    required String email,
    required String role,
  });

  /// Accept Invitation
  Future<Either<Failure, void>> acceptInvitation(String token);

  /// Cancel Invitation
  Future<Either<Failure, void>> cancelInvitation({
    required String teamId,
    required String token,
  });
}
