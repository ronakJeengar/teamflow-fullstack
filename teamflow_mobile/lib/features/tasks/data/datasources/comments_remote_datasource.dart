import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/comment_model.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments(String taskId);
  Future<CommentModel> createComment(String taskId, String content);
}

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final ApiService apiService;

  CommentsRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<CommentModel>> getComments(String taskId) async {
    final response = await apiService.getList<CommentModel>(
      ApiEndpoints.getComments(taskId),
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
      body: {'content': content},
      fromJson: (json) => CommentModel.fromJson(json),
    );
    if (response.status && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
