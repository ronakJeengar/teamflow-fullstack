import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repository/search_repository.dart';
import '../../data/models/search_result_model.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return sl<SearchRepository>();
});

final searchControllerProvider = StateNotifierProvider<SearchNotifier, AsyncValue<SearchResultModel?>>((ref) {
  return SearchNotifier(ref.watch(searchRepositoryProvider));
});

class SearchNotifier extends StateNotifier<AsyncValue<SearchResultModel?>> {
  final SearchRepository repository;

  SearchNotifier(this.repository) : super(const AsyncData(null));

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading();
    final result = await repository.search(query);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (data) => state = AsyncData(data),
    );
  }
}
