class ApiEndpoints {
  ApiEndpoints._();

  /// ================= AUTH =================
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String signup = 'auth/register';
  static const String me = 'auth/me';
  static const String refresh = 'auth/refresh';

  /// ================= TEAMS =================
  static const String createTeam = 'teams/create';
  static const String getTeams = 'teams';
  static String getTeamById(String teamId) => 'teams/$teamId';
  static String updateTeam(String teamId) => 'teams/$teamId';
  static String deleteTeam(String teamId) => 'teams/$teamId';

  /// ================= MEMBERS =================
  static String getMembers(String teamId) => 'teams/$teamId/members';
  static String addMember(String teamId) => 'teams/$teamId/members';
  static String updateMember(String teamId, String memberId) =>
      'teams/$teamId/members/$memberId';
  static String removeMember(String teamId, String memberId) =>
      'teams/$teamId/members/$memberId';

  /// ================= PROJECTS =================
  static String createProject(String teamId) => 'projects/$teamId/create';
  static String getProjects(String teamId) => 'projects/$teamId';
  static String updateProject(String teamId, String projectId) =>
      'projects/$teamId/$projectId';
  static String deleteProject(String teamId, String projectId) =>
      'projects/$teamId/$projectId';

  /// ================= TASKS =================
  static const String createTask = 'tasks/create';
  static String getTasks(String projectId) => 'tasks/$projectId';
  static String updateTask(String taskId) => 'tasks/$taskId';
  static String deleteTask(String taskId) => 'tasks/$taskId';

  /// ================= INVITATIONS =================
  static String sendInvitation(String teamId) => 'teams/$teamId/invitations';
  static String acceptInvitation(String token) => 'teams/invitations/accept/$token';
  static String cancelInvitation(String teamId, String token) =>
      'teams/$teamId/invitations/$token';
  static const String getInvitations = 'teams/invitations';
}