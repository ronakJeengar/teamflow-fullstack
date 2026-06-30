import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/comment_model.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments(String taskId, {int page, int limit});
  Future<CommentModel> createComment(String taskId, String content);
  Future<CommentModel> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
}

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final ApiService apiService;

  CommentsRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<CommentModel>> getComments(String taskId, {int page = 1, int limit = 20}) async {
    final response = await apiService.getList<CommentModel>(
      ApiEndpoints.getComments(taskId),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => CommentModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    return [];
  }

  @override
  Future<CommentModel> createComment(String taskId, String content) async {
    final response = await apiService.post<CommentModel>(
      ApiEndpoints.createComment(taskId),
      body: {'message': content},
      fromJson: (json) => CommentModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<CommentModel> updateComment(String commentId, String content) async {
    final response = await apiService.patch<CommentModel>(
      ApiEndpoints.editComment(commentId),
      body: {'message': content},
      fromJson: (json) => CommentModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final response = await apiService.delete<void>(
      ApiEndpoints.removeComment(commentId),
      fromJson: (_) {},
    );
    if (!response.status) {
      throw Exception(response.message);
    }
  }
}
