import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/delete_team_usecase.dart';
import 'teams_state_notifier.dart';

class DeleteTeamController extends StateNotifier<AsyncValue<void>> {
  final DeleteTeamUseCase deleteTeamUsecase;
  final TeamsStateNotifier teamsStateNotifier;

  DeleteTeamController({
    required this.deleteTeamUsecase,
    required this.teamsStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> deleteTeam(String id) async {
    state = const AsyncLoading();

    final result = await deleteTeamUsecase(DeleteTeamParams(id));

    result.fold(
      (failure) =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (_) {
        teamsStateNotifier.removeTeam(
          id,
        ); // mirrors authStateNotifier.setUnauthenticated()
        state = const AsyncData(null);
      },
    );
  }
}
