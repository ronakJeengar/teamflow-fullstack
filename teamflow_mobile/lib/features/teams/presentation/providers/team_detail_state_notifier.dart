import 'package:hooks_riverpod/legacy.dart';
import '../../../projects/domain/entitties/project_entity.dart';
import '../../../projects/domain/usecases/get_projects_usecase.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/usecases/get_team_by_id_usecase.dart';
import '../../domain/usecases/get_members_usecase.dart';

enum TeamDetailStatus { unknown, loaded, error }

class TeamDetailState {
  final TeamDetailStatus status;
  final TeamEntity? team;
  final List<ProjectEntity> projects;
  final List<TeamMemberEntity> members;
  final String? errorMessage;

  const TeamDetailState({
    required this.status,
    this.team,
    this.projects = const [],
    this.members = const [],
    this.errorMessage,
  });

  const TeamDetailState.unknown() : this(status: TeamDetailStatus.unknown);

  const TeamDetailState.loaded({
    required TeamEntity team,
    required List<ProjectEntity> projects,
    required List<TeamMemberEntity> members,
  }) : this(
         status: TeamDetailStatus.loaded,
         team: team,
         projects: projects,
         members: members,
       );

  const TeamDetailState.error(String message)
    : this(status: TeamDetailStatus.error, errorMessage: message);

  TeamDetailState copyWith({
    TeamDetailStatus? status,
    TeamEntity? team,
    List<ProjectEntity>? projects,
    List<TeamMemberEntity>? members,
    String? errorMessage,
  }) => TeamDetailState(
    status: status ?? this.status,
    team: team ?? this.team,
    projects: projects ?? this.projects,
    members: members ?? this.members,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

class TeamDetailStateNotifier extends StateNotifier<TeamDetailState> {
  final GetTeamByIdUseCase getTeamByIdUsecase;
  final GetMembersUseCase getMembersUsecase;
  final GetProjectsByTeamUseCase getProjectsUsecase;

  TeamDetailStateNotifier({
    required this.getTeamByIdUsecase,
    required this.getMembersUsecase,
    required this.getProjectsUsecase,
  }) : super(const TeamDetailState.unknown());

  Future<void> loadTeamDetail(String teamId) async {
    state = const TeamDetailState.unknown();

    final results = await Future.wait([
      getTeamByIdUsecase(GetTeamByIdParams(teamId)),
      getMembersUsecase(GetMembersParams(teamId: teamId)),
      getProjectsUsecase(GetProjectsByTeamParams(teamId: teamId)),
    ]);

    final teamResult = results[0];
    final membersResult = results[1];
    final projectsResult = results[2];

    teamResult.fold(
      (failure) => state = TeamDetailState.error(failure.message),
      (team) => membersResult.fold(
        (failure) => state = TeamDetailState.error(failure.message),
        (members) => projectsResult.fold(
          (failure) => state = TeamDetailState.error(failure.message),
          (projects) => state = TeamDetailState.loaded(
            team: team as TeamEntity,
            members: members as List<TeamMemberEntity>,
            projects: projects as List<ProjectEntity>,
          ),
        ),
      ),
    );
  }


  void addProject(ProjectEntity project) {
    state = state.copyWith(projects: [...state.projects, project]);
  }

  void replaceProject(ProjectEntity updated) {
    state = state.copyWith(
      projects: state.projects
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
    );
  }

  void removeProject(String projectId) {
    state = state.copyWith(
      projects: state.projects.where((p) => p.id != projectId).toList(),
    );
  }

  void removeMember(String memberId) {
    state = state.copyWith(
      members: state.members.where((m) => m.id != memberId).toList(),
    );
  }

  void replaceMember(TeamMemberEntity updated) {
    state = state.copyWith(
      members: state.members
          .map((m) => m.id == updated.id ? updated : m)
          .toList(),
    );
  }

  void addMember(TeamMemberEntity member) {
    state = state.copyWith(members: [...state.members, member]);
  }
}
