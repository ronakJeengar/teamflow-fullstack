import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../teams/presentation/providers/team_detail_state_notifier.dart';
import '../../domain/usecases/creaet_project_usecase.dart';

class CreateProjectController extends StateNotifier<AsyncValue<void>> {
  final CreateProjectUseCase createProjectUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;

  CreateProjectController({
    required this.createProjectUsecase,
    required this.teamDetailStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> createProject({
    required String teamId,
    required String name,
  }) async {
    state = const AsyncLoading();

    final result = await createProjectUsecase(
      CreateProjectParams(teamId: teamId, name: name),
    );

    result.fold(
      (failure) =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (project) {
        teamDetailStateNotifier.addProject(
          project,
        ); // mirrors teamsStateNotifier.addTeam()
        state = const AsyncData(null);
      },
    );
  }
}
