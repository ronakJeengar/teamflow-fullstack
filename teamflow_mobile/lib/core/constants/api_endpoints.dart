class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.0.2.2:3000/api/v1/';
  // static const String baseUrl = 'https://teamflow-fullstack.onrender.com/api/v1/';

  /// ================= AUTH =================
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String signup = 'auth/register';
  static const String me = 'auth/me';
  static const String refresh = 'auth/refresh';
  static const String myMemberships = 'auth/memberships';

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
  static const String getMyTasks = 'tasks/my';

  static String getTasks(String projectId) => 'tasks/$projectId';

  static String updateTask(String taskId) => 'tasks/$taskId';

  static String deleteTask(String taskId) => 'tasks/$taskId';

  /// ================= INVITATIONS =================

  /// GET /api/v1/teams/my
  static const String getMyInvitations = 'invitations/my';

  /// GET /api/v1/teams/:teamId/invitations
  static String getTeamInvitations(String teamId) =>
      'invitations/$teamId/invitations';

  /// POST /api/v1/teams/:teamId/invitations
  static String sendInvitation(String teamId) => 'invitations/$teamId/invitations';

  /// POST /api/v1/teams/accept/:token
  static String acceptInvitation(String token) => 'invitations/accept/$token';

  /// DELETE /api/v1/teams/:teamId/invitations/:token
  static String cancelInvitation(String teamId, String token) =>
      'invitations/$teamId/invitations/$token';

  /// ================= WORKSPACES =================
  static const String workspaces = 'workspaces';
  static String switchWorkspace(String workspaceId) => 'workspaces/$workspaceId/switch';
  static String getWorkspaceById(String id) => 'workspaces/$id';
  static String updateWorkspace(String id) => 'workspaces/$id';

  /// ================= STATS =================
  static const String dashboardStats = 'stats/dashboard';
  static String projectStats(String projectId) => 'stats/project/$projectId';

  /// ================= NOTIFICATIONS =================
  static const String notifications = 'notifications';
  static const String readAllNotifications = 'notifications/read-all';
  static const String unreadNotificationsCount = 'notifications/unread-count';
  static String markNotificationAsRead(String id) => 'notifications/$id/read';
  static String deleteNotification(String id) => 'notifications/$id';

  /// ================= COMMENTS =================
  static String getComments(String taskId) => 'tasks/$taskId/comments';
  static String createComment(String taskId) => 'tasks/$taskId/comments';
  static String updateComment(String taskId, String commentId) => 'tasks/$taskId/comments/$commentId';
  static String deleteComment(String taskId, String commentId) => 'tasks/$taskId/comments/$commentId';
  static String editComment(String commentId) => 'comments/$commentId';
  static String removeComment(String commentId) => 'comments/$commentId';

  /// ================= SEARCH =================
  static const String search = 'search';

  /// ================= ACTIVITIES =================
  static String getTaskActivities(String taskId) => 'activities/tasks/$taskId';
  static String getProjectActivities(String projectId) => 'activities/projects/$projectId';
}
