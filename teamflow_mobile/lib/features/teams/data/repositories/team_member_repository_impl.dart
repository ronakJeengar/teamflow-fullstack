import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/core/mappers/team_member_mapper.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/repositories/team_members_repository.dart';
import '../datasources/team_member_remote_datasource.dart';

class TeamMembersRepositoryImpl implements TeamMembersRepository {
  final TeamMembersRemoteDataSource remoteDataSource;

  TeamMembersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TeamMemberEntity>>> getMembers(
    String teamId,
  ) async {
    try {
      final members = await remoteDataSource.getMembers(teamId);

      return Right(members.map((member) => member.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TeamMemberEntity>> addMember({
    required String teamId,
    required String userId,
    required String role,
  }) async {
    try {
      final member = await remoteDataSource.addMember(
        teamId: teamId,
        userId: userId,
        role: role,
      );

      return Right(member.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TeamMemberEntity>> updateMember({
    required String teamId,
    required String memberId,
    required String role,
  }) async {
    try {
      final member = await remoteDataSource.updateMember(
        teamId: teamId,
        memberId: memberId,
        role: role,
      );

      return Right(member.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required String teamId,
    required String memberId,
  }) async {
    try {
      await remoteDataSource.removeMember(teamId: teamId, memberId: memberId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
