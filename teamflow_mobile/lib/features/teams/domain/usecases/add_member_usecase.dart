import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/team_member_entity.dart';
import '../repositories/team_members_repository.dart';

/// ================= ADD MEMBER =================

class AddMemberParams {
  final String teamId;
  final String userId;
  final String role;

  const AddMemberParams({
    required this.teamId,
    required this.userId,
    required this.role,
  });
}

class AddMemberUseCase extends UseCase<TeamMemberEntity, AddMemberParams> {
  final TeamMembersRepository repository;

  AddMemberUseCase(this.repository);

  @override
  Future<Either<Failure, TeamMemberEntity>> call(AddMemberParams params) {
    return repository.addMember(
      teamId: params.teamId,
      userId: params.userId,
      role: params.role,
    );
  }
}
