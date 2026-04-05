import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/update_team_usecase.dart';
import 'teams_state_notifier.dart';

class UpdateTeamController extends StateNotifier<AsyncValue<void>> {
  final UpdateTeamUseCase updateTeamUsecase;
  final TeamsStateNotifier teamsStateNotifier;

  UpdateTeamController({
    required this.updateTeamUsecase,
    required this.teamsStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> updateTeam({required String id, required String name}) async {
    state = const AsyncLoading();

    final result = await updateTeamUsecase(
      UpdateTeamParams(teamId: '', name: ''),
    );

    result.fold(
          (failure) =>
      state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
          (team) {
        teamsStateNotifier.replaceTeam(team);
        state = const AsyncData(null);
      },
    );
  }
}