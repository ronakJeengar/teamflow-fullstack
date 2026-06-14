import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/mappers/invitation_mapper.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/repository/invitation_repository.dart';
import '../datasources/invitation_remote_datasource.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  final InvitationRemoteDataSource remoteDataSource;

  InvitationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> sendInvitation({
    required String teamId,
    required String email,
    required String role,
  }) async {
    try {
      await remoteDataSource.sendInvitation(
        teamId: teamId,
        email: email,
        role: role,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> acceptInvitation(String token) async {
    try {
      await remoteDataSource.acceptInvitation(token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cancelInvitation({
    required String teamId,
    required String token,
  }) async {
    try {
      await remoteDataSource.cancelInvitation(teamId: teamId, token: token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InvitationEntity>>> getMyInvitations() async {
    try {
      final invitations = await remoteDataSource.getMyInvitations();
      return Right(
        invitations.map((i) => i.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InvitationEntity>>> getTeamInvitations(
      String teamId,
      ) async {
    try {
      final invitations = await remoteDataSource.getTeamInvitations(teamId);
      return Right(
        invitations.map((i) => i.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}