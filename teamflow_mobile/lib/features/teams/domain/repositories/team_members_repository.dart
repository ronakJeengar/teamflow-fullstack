import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/team_member_entity.dart';

abstract class TeamMembersRepository {
  /// Get Members
  Future<Either<Failure, List<TeamMemberEntity>>> getMembers(String teamId);

  /// Add Member
  Future<Either<Failure, TeamMemberEntity>> addMember({
    required String teamId,
    required String userId,
    required String role,
  });

  /// Update Member
  Future<Either<Failure, TeamMemberEntity>> updateMember({
    required String teamId,
    required String memberId,
    required String role,
  });

  /// Remove Member
  Future<Either<Failure, void>> removeMember({
    required String teamId,
    required String memberId,
  });
}
