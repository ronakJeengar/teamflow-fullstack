import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';
import '../providers/search_providers.dart';
import 'package:teamflow_mobile/core/navigation/navigation_helper.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';

class SearchDialog extends HookConsumerWidget {

  const SearchDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchCtrl = useTextEditingController();
    final searchAsync = ref.watch(searchControllerProvider);
    final teamsState = ref.watch(teamsStateNotifierProvider);

    useEffect(() {
      void onQueryChanged() {
        ref
            .read(searchControllerProvider.notifier)
            .performSearch(searchCtrl.text);
      }

      searchCtrl.addListener(onQueryChanged);
      return () => searchCtrl.removeListener(onQueryChanged);
    }, [searchCtrl]);

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.muted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search tasks, projects, teams...',
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.muted,
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 24),
            Expanded(
              child: searchAsync.when(
                data: (results) {
                  if (results == null ||
                      (results.tasks.isEmpty &&
                          results.projects.isEmpty &&
                          results.teams.isEmpty)) {
                    return Center(
                      child: Text(
                        searchCtrl.text.isEmpty
                            ? 'Type to search...'
                            : 'No results found',
                        style: GoogleFonts.inter(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      if (results.tasks.isNotEmpty) ...[
                        _buildSectionHeader('TASKS'),
                        ...results.tasks.map(
                          (task) => _buildResultTile(
                            context,
                            title: task.title,
                            subtitle: task.description ?? '',
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: AppColors.primary,
                            onTap: () {
                              Navigator.of(context).pop();
                              final team = teamsState.teams.firstWhere(
                                (t) => t.projects.any((p) => p.id == task.projectId),
                                orElse: () => teamsState.teams.first,
                              );
                              NavigationHelper.instance.goToTasks(task.projectId, team.id);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (results.projects.isNotEmpty) ...[
                        _buildSectionHeader('PROJECTS'),
                        ...results.projects.map(
                          (project) => _buildResultTile(
                            context,
                            title: project.name,
                            subtitle: '',
                            icon: Icons.folder_open_rounded,
                            iconColor: AppColors.success,
                            onTap: () {
                              Navigator.of(context).pop();
                              final team = teamsState.teams.firstWhere(
                                (t) => t.projects.any((p) => p.id == project.id),
                                orElse: () => teamsState.teams.first,
                              );
                              NavigationHelper.instance.goToTasks(project.id, team.id);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (results.teams.isNotEmpty) ...[
                        _buildSectionHeader('TEAMS'),
                        ...results.teams.map(
                          (team) => _buildResultTile(
                            context,
                            title: team.name,
                            subtitle: team.description ?? '',
                            icon: Icons.people_outline_rounded,
                            iconColor: AppColors.warning,
                            onTap: () {
                              Navigator.of(context).pop();
                              NavigationHelper.instance.goToTeamDetails(
                                team.id,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: TeamFlowLoader(size: 32)),
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: GoogleFonts.inter(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildResultTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 18),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}
