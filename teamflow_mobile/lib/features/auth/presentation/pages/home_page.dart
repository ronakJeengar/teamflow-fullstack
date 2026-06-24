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

    final activeTab = useState('All');
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
        if (tab == 'All') return tasksList.length;
        if (tab == 'Due Today') {
          return tasksList.where((task) {
            if (task.status == TaskStatus.DONE) return false;
            if (task.dueDate == null) return false;
            final localDue = task.dueDate!.toLocal();
            return localDue.isAfter(todayStart.subtract(const Duration(milliseconds: 1))) &&
                   localDue.isBefore(todayEnd.add(const Duration(milliseconds: 1)));
          }).length;
        }
        if (tab == 'Upcoming') {
          return tasksList.where((task) {
            if (task.status == TaskStatus.DONE) return false;
            if (task.dueDate == null) return false;
            final localDue = task.dueDate!.toLocal();
            return localDue.isAfter(todayEnd);
          }).length;
        }
        if (tab == 'Completed') {
          return tasksList.where((task) => task.status == TaskStatus.DONE).length;
        }
        return 0;
      }

      final tabs = ['All', 'Due Today', 'Upcoming', 'Completed'];
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

            statsAsync.when(
              data: (statsData) {
                final tasksTodaySpark = statsData.sparklines?['tasksDueToday']?.map((e) => e.toDouble()).toList();
                final inProgressSpark = statsData.sparklines?['inProgress']?.map((e) => e.toDouble()).toList();
                final inReviewSpark = statsData.sparklines?['inReview']?.map((e) => e.toDouble()).toList();
                final blockedSpark = statsData.sparklines?['blocked']?.map((e) => e.toDouble()).toList();

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
                    'My Tasks',
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
                  if (activeTab.value == 'All') return true;
                  if (activeTab.value == 'Due Today') {
                    if (task.status == TaskStatus.DONE) return false;
                    if (task.dueDate == null) return false;
                    final localDue = task.dueDate!.toLocal();
                    return localDue.isAfter(todayStart.subtract(const Duration(milliseconds: 1))) &&
                           localDue.isBefore(todayEnd.add(const Duration(milliseconds: 1)));
                  }
                  if (activeTab.value == 'Upcoming') {
                    if (task.status == TaskStatus.DONE) return false;
                    if (task.dueDate == null) return false;
                    final localDue = task.dueDate!.toLocal();
                    return localDue.isAfter(todayEnd);
                  }
                  if (activeTab.value == 'Completed') {
                    return task.status == TaskStatus.DONE;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const SizedBox(
                    height: 190,
                    child: AppEmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'No tasks found',
                      subtitle: 'You are all caught up on your tasks!',
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
                height: 190,
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
