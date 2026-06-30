import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repository/comments_repository.dart';
import '../../data/models/comment_model.dart';
import '../../../auth/data/models/user_model.dart';

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return sl<CommentsRepository>();
});

final taskCommentsProvider = StateNotifierProvider.family<TaskCommentsNotifier, AsyncValue<List<CommentModel>>, String>((ref, taskId) {
  return TaskCommentsNotifier(ref.watch(commentsRepositoryProvider), taskId);
});

class TaskCommentsNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final CommentsRepository repository;
  final String taskId;

  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  TaskCommentsNotifier(this.repository, this.taskId) : super(const AsyncLoading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    state = const AsyncLoading();

    final result = await repository.getComments(taskId, page: _currentPage, limit: _limit);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (comments) {
        if (comments.length < _limit) {
          _hasMore = false;
        }
        // Since getComments returns newest-first, we reverse them to display chronologically (oldest at top, newest at bottom).
        final chronologicalComments = comments.reversed.toList();
        state = AsyncData(chronologicalComments);
      },
    );
  }

  Future<void> loadMoreComments() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    _currentPage++;
    final result = await repository.getComments(taskId, page: _currentPage, limit: _limit);
    result.fold(
      (failure) {
        _isLoadingMore = false;
        _currentPage--;
      },
      (comments) {
        _isLoadingMore = false;
        if (comments.length < _limit) {
          _hasMore = false;
        }
        state.whenData((currentComments) {
          // Prepend older pages (reversed) to the top of the chronological list
          final chronologicalMore = comments.reversed.toList();
          state = AsyncData([...chronologicalMore, ...currentComments]);
        });
      },
    );
  }

  Future<void> postComment(String content, UserModel? currentUser) async {
    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final tempComment = CommentModel(
      id: tempId,
      content: content,
      taskId: taskId,
      userId: currentUser?.id ?? '',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      user: currentUser,
    );

    // Optimistic Update
    state.whenData((comments) {
      state = AsyncData([...comments, tempComment]);
    });

    final result = await repository.createComment(taskId, content);
    result.fold(
      (failure) {
        // Revert Optimistic Update
        state.whenData((comments) {
          state = AsyncData(comments.where((c) => c.id != tempId).toList());
        });
      },
      (newComment) {
        // Replace temp comment with actual comment
        state.whenData((comments) {
          state = AsyncData(comments.map((c) => c.id == tempId ? newComment : c).toList());
        });
      },
    );
  }

  Future<void> editComment(String commentId, String content) async {
    final previousState = state;

    // Optimistic Update
    state.whenData((comments) {
      state = AsyncData(comments.map((c) => c.id == commentId ? c.copyWith(content: content, editedAt: DateTime.now().toIso8601String()) : c).toList());
    });

    final result = await repository.updateComment(commentId, content);
    result.fold(
      (failure) {
        state = previousState; // Revert
      },
      (updatedComment) {
        state.whenData((comments) {
          state = AsyncData(comments.map((c) => c.id == commentId ? updatedComment : c).toList());
        });
      },
    );
  }

  Future<void> removeComment(String commentId) async {
    final previousState = state;

    // Optimistic Update
    state.whenData((comments) {
      state = AsyncData(comments.where((c) => c.id != commentId).toList());
    });

    final result = await repository.deleteComment(commentId);
    result.fold(
      (failure) {
        state = previousState; // Revert
      },
      (_) => null,
    );
  }
}
