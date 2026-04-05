import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/create_team_usecase.dart';
import 'teams_state_notifier.dart';

class CreateTeamController extends StateNotifier<AsyncValue<void>> {
  final CreateTeamUseCase createTeamUsecase;
  final TeamsStateNotifier teamsStateNotifier;

  CreateTeamController({
    required this.createTeamUsecase,
    required this.teamsStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> createTeam(String name) async {
    state = const AsyncLoading();

    final result = await createTeamUsecase(
      CreateTeamParams(name: name),
    );

    result.fold(
          (failure) =>
      state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
          (team) {
        teamsStateNotifier.addTeam(team);   // mirrors authStateNotifier.setAuthenticated(user)
        state = const AsyncData(null);
      },
    );
  }
}