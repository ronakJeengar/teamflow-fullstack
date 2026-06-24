import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/search_result_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResultModel> search(String query, {String? type, int? limit});
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiService apiService;

  SearchRemoteDataSourceImpl(this.apiService);

  @override
  Future<SearchResultModel> search(String query, {String? type, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{'q': query};
      if (type != null) queryParams['type'] = type;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiService.get<SearchResultModel>(
        ApiEndpoints.search,
        queryParameters: queryParams,
        fromJson: (json) => SearchResultModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.status && response.data != null) {
        return response.data!;
      }
      throw ServerException(response.message.isNotEmpty ? response.message : 'Search failed');
    } catch (e) {
      throw ServerException('Failed to perform search');
    }
  }
}
