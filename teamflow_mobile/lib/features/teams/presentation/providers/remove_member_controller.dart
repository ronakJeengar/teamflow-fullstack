import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/remove_member_usecase.dart';
import 'team_detail_state_notifier.dart';

class RemoveMemberController extends StateNotifier<AsyncValue<void>> {
  final RemoveMemberUseCase removeMemberUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;

  RemoveMemberController({
    required this.removeMemberUsecase,
    required this.teamDetailStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> removeMember({
    required String teamId,
    required String memberId,
  }) async {
    state = const AsyncLoading();

    // RemoveMemberParams matches exactly what's in remove_member_usecase.dart
    final result = await removeMemberUsecase(
      RemoveMemberParams(teamId: teamId, memberId: memberId),
    );

    result.fold(
          (failure) =>
      state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
          (_) {
        teamDetailStateNotifier.removeMember(memberId); // mirrors teamsStateNotifier.removeTeam()
        state = const AsyncData(null);
      },
    );
  }
}