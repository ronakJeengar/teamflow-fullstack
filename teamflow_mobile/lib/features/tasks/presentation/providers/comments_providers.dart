import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repository/comments_repository.dart';
import '../../data/models/comment_model.dart';

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return sl<CommentsRepository>();
});

final taskCommentsProvider = StateNotifierProvider.family<TaskCommentsNotifier, AsyncValue<List<CommentModel>>, String>((ref, taskId) {
  return TaskCommentsNotifier(ref.watch(commentsRepositoryProvider), taskId);
});

class TaskCommentsNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final CommentsRepository repository;
  final String taskId;

  TaskCommentsNotifier(this.repository, this.taskId) : super(const AsyncLoading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = const AsyncLoading();
    final result = await repository.getComments(taskId);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (comments) => state = AsyncData(comments),
    );
  }

  Future<void> postComment(String content) async {
    final result = await repository.createComment(taskId, content);
    result.fold(
      (failure) => null, // or update error state
      (newComment) {
        state.whenData((comments) {
          state = AsyncData([...comments, newComment]);
        });
      },
    );
  }
}
