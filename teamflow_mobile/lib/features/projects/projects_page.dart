import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';
import 'package:teamflow_mobile/core/widgets/project_card.dart';
import 'package:teamflow_mobile/core/navigation/navigation_helper.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import 'package:teamflow_mobile/core/widgets/teamflow_shell.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/widget/create_project_sheet.dart';
import 'package:teamflow_mobile/features/teams/presentation/widget/edit_project_sheet.dart';
import 'package:teamflow_mobile/features/teams/presentation/widget/delete_project_sheet.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/membership_entity.dart';

class ProjectsPage extends HookConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsState = ref.watch(teamsStateNotifierProvider);
    final authState = ref.watch(authStateNotifierProvider);
    final memberships = authState.memberships;

    final hasManageableTeam = teamsState.teams.any((team) {
      final membership = memberships.firstWhere(
        (m) => m.team.id == team.id,
        orElse: () => const MembershipEntity(
          role: 'VIEWER',
          team: MembershipTeamEntity(id: '', name: ''),
        ),
      );
      return ['OWNER', 'ADMIN'].contains(membership.role.toUpperCase());
    });
    
    // Load teams if not loaded
    useEffect(() {
      Future.microtask(() {
        ref.read(teamsStateNotifierProvider.notifier).loadTeams();
      });
      return null;
    }, const []);

    final activeFilter = useState('');
    final isGridView = useState(true);
    final sortBy = useState('Updated'); // 'Updated' | 'Name'

    // Gather all projects across all teams
    final allProjects = teamsState.teams.expand((t) => t.projects).toList();
    final tabs = teamsState.teams.map((t) => t.name).toList();

    useEffect(() {
      if (tabs.isNotEmpty) {
        if (!tabs.contains(activeFilter.value)) {
          activeFilter.value = tabs.first;
        }
      } else {
        activeFilter.value = '';
      }
      return null;
    }, [tabs]);

    // Dynamic backend integration logs
    debugPrint('[Backend Projects Response] Projects: ${allProjects.map((p) => "${p.id}:${p.name}").toList()}');
    debugPrint('[Generated Tabs] Tabs: $tabs');
    debugPrint('[Selected Workspace] Switched to workspace via session cookie');
    debugPrint('[Active Filters] Selected tab filter: ${activeFilter.value}');

    // Map workspace names to categories / filters
    final filteredProjects = allProjects.where((p) {
      if (activeFilter.value.isEmpty) return false;
      
      final team = teamsState.teams.firstWhere(
        (t) => t.projects.any((proj) => proj.id == p.id),
        orElse: () => teamsState.teams.first,
      );
      return team.name.toLowerCase() == activeFilter.value.toLowerCase();
    }).toList();

    // Sort projects
    if (sortBy.value == 'Name') {
      filteredProjects.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      filteredProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    void showCreateProject() {
      final manageableTeams = teamsState.teams.where((team) {
        final membership = memberships.firstWhere(
          (m) => m.team.id == team.id,
          orElse: () => const MembershipEntity(
            role: 'VIEWER',
            team: MembershipTeamEntity(id: '', name: ''),
          ),
        );
        return ['OWNER', 'ADMIN'].contains(membership.role.toUpperCase());
      }).toList();

      if (manageableTeams.isEmpty) {
        showAppSnackBar(context, 'You do not have permission to create projects on any team.');
        return;
      }
      final defaultTeamId = manageableTeams.first.id;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CreateProjectSheet(teamId: defaultTeamId),
      );
    }

    Widget buildTabBar() {
      if (tabs.isEmpty) return const SizedBox.shrink();
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
                  onTap: () => activeFilter.value = tab,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: activeFilter.value == tab
                          ? const Border(
                        bottom: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      )
                          : null,
                    ),
                    child: Text(
                      tab,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: activeFilter.value == tab
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: activeFilter.value == tab
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget buildViewToggleAndSort() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.list_rounded,
                color: !isGridView.value ? AppColors.primary : AppColors.muted,
                size: 20,
              ),
              onPressed: () => isGridView.value = false,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                Icons.grid_view_rounded,
                color: isGridView.value ? AppColors.primary : AppColors.muted,
                size: 20,
              ),
              onPressed: () => isGridView.value = true,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              onSelected: (val) => sortBy.value = val,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Sort: ${sortBy.value}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Updated',
                  child: Text(
                    'Updated',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
                PopupMenuItem(
                  value: 'Name',
                  child: Text(
                    'Name',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Future<void> handleRefresh() async {
      await ref.read(teamsStateNotifierProvider.notifier).loadTeams();
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;

    return TeamFlowShell(
      activeTab: 'Projects',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (isDesktop) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Projects',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (hasManageableTeam)
                    ElevatedButton.icon(
                      onPressed: showCreateProject,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('New Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            buildTabBar(),
            buildViewToggleAndSort(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: handleRefresh,
                child: filteredProjects.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: AppEmptyState(
                              icon: Icons.folder_open_rounded,
                              title: 'No projects found',
                              subtitle: 'Add your first project to get started',
                              actionLabel: hasManageableTeam ? 'New Project' : null,
                              onAction: hasManageableTeam ? showCreateProject : null,
                            ),
                          ),
                        ),
                      )
                    : isGridView.value
                        ? GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 175,
                            ),
                            itemCount: filteredProjects.length,
                            itemBuilder: (context, i) {
                              final p = filteredProjects[i];
                              final team = teamsState.teams.firstWhere(
                                (t) => t.projects.any((proj) => proj.id == p.id),
                                orElse: () => teamsState.teams.first,
                              );
                              final membership = memberships.firstWhere(
                                (m) => m.team.id == team.id,
                                orElse: () => const MembershipEntity(
                                  role: 'VIEWER',
                                  team: MembershipTeamEntity(id: '', name: ''),
                                ),
                              );
                              final canManage = ['OWNER', 'ADMIN'].contains(membership.role.toUpperCase());
                              final ownerMember = team.members.where((m) => m.userId == p.ownerId).firstOrNull;
                              final ownerName = ownerMember?.user?.name;

                              return ProjectCard(
                                project: p,
                                canManage: canManage,
                                category: team.name,
                                ownerName: ownerName,
                                onEdit: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => EditProjectSheet(project: p, teamId: team.id),
                                  );
                                },
                                onDelete: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => DeleteProjectSheet(project: p, teamId: team.id),
                                  );
                                },
                                onTap: () => NavigationHelper.instance.pushTasks(p.id, team.id),
                              );
                            },
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filteredProjects.length,
                            itemBuilder: (context, i) {
                              final p = filteredProjects[i];
                              final team = teamsState.teams.firstWhere(
                                (t) => t.projects.any((proj) => proj.id == p.id),
                                orElse: () => teamsState.teams.first,
                              );
                              final membership = memberships.firstWhere(
                                (m) => m.team.id == team.id,
                                orElse: () => const MembershipEntity(
                                  role: 'VIEWER',
                                  team: MembershipTeamEntity(id: '', name: ''),
                                ),
                              );
                              final canManage = ['OWNER', 'ADMIN'].contains(membership.role.toUpperCase());
                              final ownerMember = team.members.where((m) => m.userId == p.ownerId).firstOrNull;
                              final ownerName = ownerMember?.user?.name;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ProjectCard(
                                  project: p,
                                  canManage: canManage,
                                  category: team.name,
                                  ownerName: ownerName,
                                  onEdit: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => EditProjectSheet(project: p, teamId: team.id),
                                    );
                                  },
                                  onDelete: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => DeleteProjectSheet(project: p, teamId: team.id),
                                    );
                                  },
                                  onTap: () => NavigationHelper.instance.pushTasks(p.id, team.id),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
