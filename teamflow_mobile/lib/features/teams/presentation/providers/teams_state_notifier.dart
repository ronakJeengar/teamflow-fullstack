import 'package:hooks_riverpod/legacy.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/usecases/get_teams_use_case.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum TeamsStatus { unknown, loaded, error }

class TeamsState {
  final TeamsStatus status;
  final List<TeamEntity> teams;
  final String? errorMessage;

  const TeamsState({
    required this.status,
    this.teams = const [],
    this.errorMessage,
  });

  const TeamsState.unknown() : this(status: TeamsStatus.unknown);

  const TeamsState.loaded(List<TeamEntity> teams)
    : this(status: TeamsStatus.loaded, teams: teams);

  const TeamsState.error(String message)
    : this(status: TeamsStatus.error, errorMessage: message);

  TeamsState copyWith({
    TeamsStatus? status,
    List<TeamEntity>? teams,
    String? errorMessage,
  }) => TeamsState(
    status: status ?? this.status,
    teams: teams ?? this.teams,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class TeamsStateNotifier extends StateNotifier<TeamsState> {
  final GetTeamsUseCase getTeamsUsecase;

  TeamsStateNotifier(this.getTeamsUsecase) : super(const TeamsState.unknown()) {
    loadTeams();
  }

  Future<void> loadTeams() async {
    final result = await getTeamsUsecase();
    result.fold(
      (failure) => state = TeamsState.error(failure.message),
      (teams) => state = TeamsState.loaded(teams),
    );
  }

  // Called by CreateTeamController / UpdateTeamController / DeleteTeamController
  // after a successful mutation — mirrors how AuthStateNotifier.setAuthenticated()
  // is called from LoginController / SignupController
  void addTeam(TeamEntity team) {
    state = TeamsState.loaded([...state.teams, team]);
  }

  void replaceTeam(TeamEntity updated) {
    state = TeamsState.loaded(
      state.teams.map((t) => t.id == updated.id ? updated : t).toList(),
    );
  }

  void removeTeam(String id) {
    state = TeamsState.loaded(state.teams.where((t) => t.id != id).toList());
  }
}
