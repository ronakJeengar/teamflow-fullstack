import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repository/comments_repository.dart';
import '../datasources/comments_remote_datasource.dart';
import '../models/comment_model.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  CommentsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CommentModel>>> getComments(String taskId, {int page = 1, int limit = 20}) async {
    try {
      final comments = await remoteDataSource.getComments(taskId, page: page, limit: limit);
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure('Failed to load comments: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> createComment(String taskId, String content) async {
    try {
      final comment = await remoteDataSource.createComment(taskId, content);
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure('Failed to post comment: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> updateComment(String commentId, String content) async {
    try {
      final comment = await remoteDataSource.updateComment(commentId, content);
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure('Failed to update comment: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete comment: $e'));
    }
  }
}
