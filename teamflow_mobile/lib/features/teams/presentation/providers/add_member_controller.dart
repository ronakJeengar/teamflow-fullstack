import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../domain/usecases/add_member_usecase.dart';
import 'team_detail_state_notifier.dart';

class AddMemberController extends StateNotifier<AsyncValue<void>> {
  final AddMemberUseCase addMemberUsecase;
  final TeamDetailStateNotifier teamDetailStateNotifier;

  AddMemberController({
    required this.addMemberUsecase,
    required this.teamDetailStateNotifier,
  }) : super(const AsyncData(null));

  Future<void> addMember({
    required String teamId,
    required String userId,
    required String role,
  }) async {
    state = const AsyncLoading();

    // AddMemberParams matches exactly what's in add_member_usecase.dart
    final result = await addMemberUsecase(
      AddMemberParams(teamId: teamId, userId: userId, role: role),
    );

    result.fold(
          (failure) =>
      state = AsyncError(mapFailureToMessage(failure), StackTrace.current),
          (newMember) {
        teamDetailStateNotifier.addMember(newMember); // mirrors teamsStateNotifier.addTeam()
        state = const AsyncData(null);
      },
    );
  }
}