import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/update_member_usecase.dart';
import 'team_detail_state_notifier.dart';

class UpdateMemberController extends StateNotifier<AsyncValue<void>> {
  final UpdateMemberUseCase updateMemberUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;

  UpdateMemberController({
    required this.updateMemberUsecase,
    required this.teamDetailStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> updateMember({
    required String teamId,
    required String memberId,
    required String role,
  }) async {
    state = const AsyncLoading();

    // UpdateMemberParams matches exactly what's in update_member_usecase.dart
    final result = await updateMemberUsecase(
      UpdateMemberParams(teamId: teamId, memberId: memberId, role: role),
    );

    result.fold(
          (failure) =>
      state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
          (updatedMember) {
        // UpdateMemberUseCase returns TeamMemberEntity so we replace the whole object
        // mirrors teamsStateNotifier.replaceTeam()
        teamDetailStateNotifier.replaceMember(updatedMember);
        state = const AsyncData(null);
      },
    );
  }
}