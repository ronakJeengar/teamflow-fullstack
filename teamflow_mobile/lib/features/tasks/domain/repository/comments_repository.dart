import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/comment_model.dart';

abstract class CommentsRepository {
  Future<Either<Failure, List<CommentModel>>> getComments(String taskId);
  Future<Either<Failure, CommentModel>> createComment(String taskId, String content);
}
