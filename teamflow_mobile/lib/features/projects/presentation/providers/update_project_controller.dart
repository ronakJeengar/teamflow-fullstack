import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../teams/presentation/providers/team_detail_state_notifier.dart';
import '../../domain/usecases/update_project_usecase.dart';

class UpdateProjectController extends StateNotifier<AsyncValue<void>> {
  final UpdateProjectUseCase updateProjectUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;

  UpdateProjectController({
    required this.updateProjectUsecase,
    required this.teamDetailStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> updateProject({
    required String teamId,
    required String projectId,
    required String name,
  }) async {
    state = const AsyncLoading();

    final result = await updateProjectUsecase(
      UpdateProjectParams(teamId: teamId, projectId: projectId, name: name),
    );

    result.fold(
      (failure) =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (updatedProject) {
        teamDetailStateNotifier.replaceProject(
          updatedProject,
        ); // mirrors teamsStateNotifier.replaceTeam()
        state = const AsyncData(null);
      },
    );
  }
}
