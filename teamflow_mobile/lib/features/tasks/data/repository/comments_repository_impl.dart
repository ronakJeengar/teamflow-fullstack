import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repository/comments_repository.dart';
import '../datasources/comments_remote_datasource.dart';
import '../models/comment_model.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  CommentsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CommentModel>>> getComments(String taskId) async {
    try {
      final comments = await remoteDataSource.getComments(taskId);
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure('Failed to load comments'));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> createComment(String taskId, String content) async {
    try {
      final comment = await remoteDataSource.createComment(taskId, content);
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure('Failed to post comment'));
    }
  }
}
