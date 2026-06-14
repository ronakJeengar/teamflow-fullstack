import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/team_members_repository.dart';

/// ================= REMOVE MEMBER =================

class RemoveMemberParams {
  final String teamId;
  final String memberId;

  const RemoveMemberParams({required this.teamId, required this.memberId});
}

class RemoveMemberUseCase extends UseCase<void, RemoveMemberParams> {
  final TeamMembersRepository repository;

  RemoveMemberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveMemberParams params) {
    return repository.removeMember(
      teamId: params.teamId,
      memberId: params.memberId,
    );
  }
}
