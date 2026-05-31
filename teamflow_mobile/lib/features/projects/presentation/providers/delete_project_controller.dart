import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../teams/presentation/providers/team_detail_state_notifier.dart';
import '../../domain/usecases/delete_project_usecase.dart';

class DeleteProjectController extends StateNotifier<AsyncValue<void>> {
  final DeleteProjectUseCase deleteProjectUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;

  DeleteProjectController({
    required this.deleteProjectUsecase,
    required this.teamDetailStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> deleteProject({
    required String teamId,
    required String projectId,
  }) async {
    state = const AsyncLoading();

    final result = await deleteProjectUsecase(
      DeleteProjectParams(teamId: teamId, projectId: projectId),
    );

    result.fold(
      (failure) =>
          state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
      (_) {
        teamDetailStateNotifier.removeProject(
          projectId,
        ); // mirrors teamsStateNotifier.removeTeam()
        state = const AsyncData(null);
      },
    );
  }
}
