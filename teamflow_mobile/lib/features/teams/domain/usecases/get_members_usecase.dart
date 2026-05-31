import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/team_member_entity.dart';
import '../repositories/team_members_repository.dart';

/// ================= GET MEMBERS =================

class GetMembersParams {
  final String teamId;

  const GetMembersParams({
    required this.teamId,
  });
}

class GetMembersUseCase
    extends UseCase<List<TeamMemberEntity>,
        GetMembersParams> {
  final TeamMembersRepository repository;

  GetMembersUseCase(this.repository);

  @override
  Future<Either<Failure,
      List<TeamMemberEntity>>> call(
      GetMembersParams params,
      ) {
    return repository.getMembers(
      params.teamId,
    );
  }
}