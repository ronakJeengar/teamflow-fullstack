import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';
import 'package:teamflow_mobile/core/widgets/stat_card.dart';
import 'package:teamflow_mobile/core/widgets/project_card.dart';
import 'package:teamflow_mobile/core/widgets/task_card.dart';
import 'package:teamflow_mobile/core/widgets/teamflow_shell.dart';
import 'package:teamflow_mobile/core/navigation/navigation_helper.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';
import 'package:teamflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:teamflow_mobile/features/auth/presentation/widgets/logout_modal.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/stats_providers.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_member_entity.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/workspaces_providers.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/widgets/workspace_settings_sheet.dart';
import 'package:teamflow_mobile/features/dashboard/data/models/workspace_model.dart';

import '../../../projects/domain/entitties/project_entity.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final teamsState = ref.watch(teamsStateNotifierProvider);

    final user = authState.user;
    final userName = user?.name ?? 'User';

    useEffect(() {
      Future.microtask(() {
        ref.read(teamsStateNotifierProvider.notifier).loadTeams();
      });
      return null;
    }, []);

    // Get all projects across all teams to populate "Recent Projects"
    final List<ProjectEntity> allProjects = teamsState.teams.expand((t) => t.projects).toList();

    final activeTab = useState('Assigned');
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final myTasksAsync = ref.watch(myTasksProvider);
    myTasksAsync.whenOrNull(
      data: (tasksList) {
        debugPrint('[My Work] Rebuilt with ${tasksList.length} tasks');
      },
    );

    String getTrendText(List<int>? list, String defaultLabel) {
      if (list == null || list.length < 2) return defaultLabel;
      final current = list.last;
      final prev = list[list.length - 2];
      final diff = current - prev;
      if (diff > 0) {
        return '+$diff since yesterday';
      } else if (diff < 0) {
        return '$diff since yesterday';
      } else {
        return 'No change';
      }
    }

    bool getTrendDirection(List<int>? list) {
      if (list == null || list.length < 2) return true;
      final current = list.last;
      final prev = list[list.length - 2];
      return current >= prev;
    }

    // Define statsAsync
    final statsAsync = ref.watch(dashboardStatsProvider);

    Widget buildTabBar(List<TaskEntity> tasksList) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      int getCount(String tab) {
        if (tab == 'Assigned') return tasksList.length;
        if (tab == 'In Progress') {
          return tasksList.where((task) => task.status == TaskStatus.IN_PROGRESS).length;
        }
        if (tab == 'Upcoming') {
          return tasksList.where((task) {
            if (task.status == TaskStatus.DONE) return false;
            if (task.dueDate == null) return false;
            final localDue = task.dueDate!.toLocal();
            return localDue.isAfter(todayEnd);
          }).length;
        }
        if (tab == 'Overdue') {
          return tasksList.where((task) {
            if (task.status == TaskStatus.DONE) return false;
            if (task.dueDate == null) return false;
            final localDue = task.dueDate!.toLocal();
            return localDue.isBefore(todayStart);
          }).length;
        }
        if (tab == 'Completed') {
          return tasksList.where((task) => task.status == TaskStatus.DONE).length;
        }
        return 0;
      }

      final tabs = ['Assigned', 'In Progress', 'Upcoming', 'Overdue', 'Completed'];
      return Container(
        height: 36,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final tab in tabs)
                GestureDetector(
                  onTap: () => activeTab.value = tab,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: activeTab.value == tab
                          ? const Border(
                              bottom: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: activeTab.value == tab
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: activeTab.value == tab
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: activeTab.value == tab
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${getCount(tab)}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: activeTab.value == tab
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget buildMainContent() {
      final workspacesAsync = ref.watch(workspacesListProvider);

      Widget buildWorkspaceStat(String label, String value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, \n$userName 👋',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Here's what's happening with your work.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show team create or logout as dummy action
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const LogoutSheet(),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Workspace Card
            workspacesAsync.when(
              data: (workspaces) {
                if (workspaces.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No workspaces found. Create one to get started.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  );
                }

                final currentWorkspace = workspaces.firstWhere(
                  (w) => w.id == authState.user?.activeWorkspaceId,
                  orElse: () => workspaces.first,
                );
                
                final wColor = currentWorkspace.color != null
                    ? Color(int.parse(currentWorkspace.color!.replaceAll('#', '0xFF')))
                    : AppColors.primary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: wColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              currentWorkspace.name.isNotEmpty ? currentWorkspace.name[0].toUpperCase() : 'W',
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentWorkspace.name,
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Active Workspace',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => WorkspaceSettingsSheet(workspace: currentWorkspace),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 16),
                      statsAsync.maybeWhen(
                        data: (stats) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildWorkspaceStat('Teams', '${stats.team_count ?? 0}'),
                              buildWorkspaceStat('Projects', '${stats.project_count ?? 0}'),
                              buildWorkspaceStat('Tasks', '${stats.task_count ?? 0}'),
                              buildWorkspaceStat('Members', '${stats.member_count ?? 0}'),
                            ],
                          );
                        },
                        orElse: () => const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Active Sprint Card (Sprint Health)
            statsAsync.maybeWhen(
              data: (stats) {
                if (stats.sprintProgress == null) return const SizedBox.shrink();
                final progress = stats.sprintProgress!;
                final totalTasks = progress['totalTasks'] ?? 0;
                final completedTasks = progress['completedTasks'] ?? 0;
                final completionPercentage = progress['completionPercentage'] ?? 0;
                final velocity = stats.sprintVelocity ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Active Sprint Health',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Velocity: $velocity pts',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$completedTasks / $totalTasks Tasks Done',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            '$completionPercentage%',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),

            statsAsync.when(
              data: (statsData) {
                final tasksTodaySpark = statsData.sparklines?['tasksDueToday']?.map((e) => e.toDouble()).toList();
                final inProgressSpark = statsData.sparklines?['inProgress']?.map((e) => e.toDouble()).toList();
                final inReviewSpark = statsData.sparklines?['inReview']?.map((e) => e.toDouble()).toList();
                final blockedSpark = statsData.sparklines?['blocked']?.map((e) => e.toDouble()).toList();
                print('[Stats UI Values] tasksDueToday=${statsData.tasksDueToday}, inProgress=${statsData.inProgress}, inReview=${statsData.inReview}, blocked=${statsData.blocked}');

                return StatBlockRow(cards: [
                  StatCard(
                    value: '${statsData.tasksDueToday}',
                    label: 'Tasks today',
                    color: AppColors.primary,
                    trendText: getTrendText(statsData.sparklines?['tasksDueToday'], 'Real-time stats'),
                    trendIsPositive: getTrendDirection(statsData.sparklines?['tasksDueToday']),
                    sparklineData: tasksTodaySpark,
                  ),
                  StatCard(
                    value: '${statsData.inProgress}',
                    label: 'In Progress',
                    color: AppColors.warning,
                    trendText: getTrendText(statsData.sparklines?['inProgress'], 'Stable trend'),
                    trendIsPositive: getTrendDirection(statsData.sparklines?['inProgress']),
                    sparklineData: inProgressSpark,
                  ),
                  StatCard(
                    value: '${statsData.inReview}',
                    label: 'Review',
                    color: AppColors.danger,
                    trendText: getTrendText(statsData.sparklines?['inReview'], 'Stable trend'),
                    trendIsPositive: getTrendDirection(statsData.sparklines?['inReview']),
                    sparklineData: inReviewSpark,
                  ),
                  StatCard(
                    value: '${statsData.blocked}',
                    label: 'Blocked',
                    color: AppColors.muted,
                    trendText: getTrendText(statsData.sparklines?['blocked'], 'Requires action'),
                    trendIsPositive: getTrendDirection(statsData.sparklines?['blocked']),
                    sparklineData: blockedSpark,
                  ),
                ]);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const StatBlockRow(cards: [
                StatCard(value: '0', label: 'Tasks today', color: AppColors.primary, trendText: 'Error loading', trendIsPositive: false),
                StatCard(value: '0', label: 'In Progress', color: AppColors.warning, trendText: 'Error loading', trendIsPositive: false),
                StatCard(value: '0', label: 'Review', color: AppColors.danger, trendText: 'Error loading', trendIsPositive: false),
                StatCard(value: '0', label: 'Blocked', color: AppColors.muted, trendText: 'Error loading', trendIsPositive: false),
              ]),
            ),

            const SizedBox(height: 24),

            // TabBar for tasks
            Row(
              children: [
                Expanded(
                  child: Text(
                    'My Work',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            buildTabBar(myTasksAsync.value ?? []),
            const SizedBox(height: 12),

            // Tasks List
            myTasksAsync.when(
              skipLoadingOnRefresh: true,
              data: (tasksList) {
                final now = DateTime.now();
                final todayStart = DateTime(now.year, now.month, now.day);
                final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

                final filtered = tasksList.where((task) {
                  if (activeTab.value == 'Assigned') return true;
                  if (activeTab.value == 'In Progress') {
                    return task.status == TaskStatus.IN_PROGRESS;
                  }
                  if (activeTab.value == 'Upcoming') {
                    if (task.status == TaskStatus.DONE) return false;
                    if (task.dueDate == null) return false;
                    final localDue = task.dueDate!.toLocal();
                    return localDue.isAfter(todayEnd);
                  }
                  if (activeTab.value == 'Overdue') {
                    if (task.status == TaskStatus.DONE) return false;
                    if (task.dueDate == null) return false;
                    final localDue = task.dueDate!.toLocal();
                    return localDue.isBefore(todayStart);
                  }
                  if (activeTab.value == 'Completed') {
                    return task.status == TaskStatus.DONE;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  final String emptyTitle;
                  final String emptySubtitle;
                  if (activeTab.value == 'Assigned') {
                    emptyTitle = 'No assigned tasks';
                    emptySubtitle = 'You don\'t have any tasks assigned in this workspace.';
                  } else if (activeTab.value == 'Completed') {
                    emptyTitle = 'No completed tasks';
                    emptySubtitle = 'Completed tasks will show up here.';
                  } else {
                    emptyTitle = 'No ${activeTab.value.toLowerCase()} tasks';
                    emptySubtitle = 'You are all caught up on your ${activeTab.value.toLowerCase()} tasks!';
                  }
                  return SizedBox(
                    height: 250,
                    child: AppEmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: emptyTitle,
                      subtitle: emptySubtitle,
                    ),
                  );
                }

                return Column(
                  children: filtered.map((task) {
                    final proj = allProjects.firstWhere(
                      (p) => p.id == task.projectId,
                      orElse: () => ProjectEntity(
                        id: task.projectId,
                        name: 'Project (${task.projectId})',
                        ownerId: '',
                        createdAt: DateTime.now().toIso8601String(),
                      ),
                    );

                    // Retrieve assignee name dynamically from teams and members state
                    final allMembers = teamsState.teams.expand((t) => t.members).toList();
                    final assigneeMember = allMembers.cast<TeamMemberEntity?>().firstWhere(
                      (m) => m?.userId == task.assignedToId,
                      orElse: () => null,
                    );
                    final assigneeName = assigneeMember?.user?.name;

                    return TaskCard(
                      task: task,
                      projectName: proj.name,
                      category: 'Task',
                      assigneeName: assigneeName,
                      onEdit: () {},
                      onDelete: () {},
                      onCheckboxChanged: (checked) {
                        final newStatus = checked ? TaskStatus.DONE : TaskStatus.TODO;
                        ref
                            .read(updateTaskControllerProvider.notifier)
                            .moveTask(taskId: task.id, newStatus: newStatus);
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Error loading tasks: $err',
                    style: GoogleFonts.inter(color: AppColors.danger),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Projects
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Projects',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => NavigationHelper.instance.goToTeams(),
                  child: Row(
                    children: [
                      Text(
                        'See all teams',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (allProjects.isEmpty)
              const SizedBox(
                height: 250,
                child: AppEmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'No projects yet',
                  subtitle: 'Join or create a team to add projects.',
                ),
              )
            else if (isDesktop)
              // 4-column grid for desktop
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 180,
                ),
                itemCount: allProjects.length,
                itemBuilder: (context, i) {
                  final project = allProjects[i];
                  final team = teamsState.teams.firstWhere(
                    (t) => t.projects.any((p) => p.id == project.id),
                    orElse: () => teamsState.teams.first,
                  );
                  final ownerMember = team.members.where((m) => m.userId == project.ownerId).firstOrNull;
                  final ownerName = ownerMember?.user?.name;

                  return ProjectCard(
                    project: project,
                    canManage: false,
                    category: team.name,
                    ownerName: ownerName,
                    onEdit: () {},
                    onDelete: () {},
                    onTap: () => NavigationHelper.instance.pushTasks(project.id, team.id),
                  );
                },
              )
            else
              // Horizontal scroll projects for mobile
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allProjects.length,
                  itemBuilder: (context, i) {
                    final project = allProjects[i];
                    final team = teamsState.teams.firstWhere(
                      (t) => t.projects.any((p) => p.id == project.id),
                      orElse: () => teamsState.teams.first,
                    );
                    final ownerMember = team.members.where((m) => m.userId == project.ownerId).firstOrNull;
                    final ownerName = ownerMember?.user?.name;

                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      child: ProjectCard(
                        project: project,
                        canManage: false,
                        category: team.name,
                        ownerName: ownerName,
                        onEdit: () {},
                        onDelete: () {},
                        onTap: () => NavigationHelper.instance.pushTasks(project.id, team.id),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    }

    Future<void> handleRefresh() async {
      await ref.read(teamsStateNotifierProvider.notifier).loadTeams();
      ref.invalidate(myTasksProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(unreadNotificationsCountProvider);
    }

    return TeamFlowShell(
      activeTab: 'My Work',
      child: RefreshIndicator(
        onRefresh: handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: buildMainContent(),
        ),
      ),
    );
  }
}
