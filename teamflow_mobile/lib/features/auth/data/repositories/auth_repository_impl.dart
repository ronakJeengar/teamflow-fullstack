import 'package:dartz/dartz.dart';
import 'package:teamflow_mobile/core/mappers/membership_mapper.dart';
import 'package:teamflow_mobile/core/mappers/user_mapper.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/membership_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/membership_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
      String email,
      String password,
      ) async {
    try {
      final UserModel user = await remoteDataSource.login(email, password);
      return right(user.toEntity());
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signup(
      String email,
      String name,
      String password,
      ) async {
    try {
      await remoteDataSource.signup(name, email, password);

      final UserModel user = await remoteDataSource.login(
        email,
        password,
      );

      return right(user.toEntity());
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      try {
        await remoteDataSource.logout();
      } catch (_) {}

      await remoteDataSource.clearSession();
      await localDataSource.clearTokens();

      return right(null);
    } catch (_) {
      return left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final token = await localDataSource.getAccessToken();

      if (token == null) {
        return const Right(null);
      }

      final UserModel? user = await remoteDataSource.getCurrentUser();

      if (user != null) {
        return right(user.toEntity());
      }

      return const Right(null);
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<MembershipEntity>>> getMyMemberships() async {
    try {
      final List<MembershipModel> memberships =
      await remoteDataSource.getMyMemberships();

      return right(
        memberships.map((membership) => membership.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(ServerFailure('Unexpected error'));
    }
  }
}