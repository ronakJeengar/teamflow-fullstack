import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/team_member_entity.dart';
import '../repositories/team_members_repository.dart';

/// ================= UPDATE MEMBER =================

class UpdateMemberParams {
  final String teamId;
  final String memberId;
  final String role;

  const UpdateMemberParams({
    required this.teamId,
    required this.memberId,
    required this.role,
  });
}

class UpdateMemberUseCase
    extends UseCase<TeamMemberEntity, UpdateMemberParams> {
  final TeamMembersRepository repository;

  UpdateMemberUseCase(this.repository);

  @override
  Future<Either<Failure, TeamMemberEntity>> call(UpdateMemberParams params) {
    return repository.updateMember(
      teamId: params.teamId,
      memberId: params.memberId,
      role: params.role,
    );
  }
}
