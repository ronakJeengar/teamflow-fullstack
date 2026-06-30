import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/comment_model.dart';

abstract class CommentsRepository {
  Future<Either<Failure, List<CommentModel>>> getComments(String taskId, {int page, int limit});
  Future<Either<Failure, CommentModel>> createComment(String taskId, String content);
  Future<Either<Failure, CommentModel>> updateComment(String commentId, String content);
  Future<Either<Failure, Unit>> deleteComment(String commentId);
}
