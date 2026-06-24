import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/search_result_model.dart';

abstract class SearchRepository {
  Future<Either<Failure, SearchResultModel>> search(String query, {String? type, int? limit});
}
