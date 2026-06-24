import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/workspaces_providers.dart';
import 'package:teamflow_mobile/features/dashboard/presentation/providers/stats_providers.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/teams_providers.dart';

class Sidebar extends ConsumerWidget {
  final String activeItem;
  final ValueChanged<String> onItemSelect;
  final bool isIconOnly;
  final VoidCallback? onSearchTap;

  const Sidebar({
    super.key,
    required this.activeItem,
    required this.onItemSelect,
    this.isIconOnly = false,
    this.onSearchTap,
  });

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    int? badgeCount,
  }) {
    final isActive = activeItem == label;

    if (isIconOnly) {
      return GestureDetector(
        onTap: () => onItemSelect(label),
        child: Container(
          height: 36,
          width: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: isActive
                ? const Border(
                    left: BorderSide(color: AppColors.primary, width: 2),
                  )
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? AppColors.primary : AppColors.muted,
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onItemSelect(label),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 2),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Container(
                height: 16,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceItem(String letter, String label, Color color) {
    if (isIconOnly) {
      return Container(
        height: 36,
        alignment: Alignment.center,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = isIconOnly ? 56.0 : 220.0;

    return Container(
      width: width,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo / Header Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Logo Mark
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.hexagon_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  if (!isIconOnly) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'TeamFlow',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.muted,
                    ),
                  ],
                ],
              ),
            ),

            // Search Bar Layer
            if (!isIconOnly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search...',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '⌘K',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: onSearchTap,
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Main Nav Items
            _buildNavItem(
              icon: Icons.inbox_rounded,
              label: 'Inbox',
              badgeCount: ref.watch(unreadNotificationsCountProvider),
            ),
            _buildNavItem(
              icon: Icons.check_circle_outline_rounded,
              label: 'My Work',
            ),
            _buildNavItem(
              icon: Icons.folder_open_rounded,
              label: 'Projects',
            ),
            _buildNavItem(
              icon: Icons.people_outline_rounded,
              label: 'Teams',
            ),
            _buildNavItem(
              icon: Icons.calendar_today_rounded,
              label: 'Calendar',
            ),
            _buildNavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Reports',
            ),
            _buildNavItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
            ),

            const Divider(color: AppColors.border, height: 24),

            // Workspaces section
            if (!isIconOnly)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WORKSPACES',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),

            Consumer(
              builder: (context, ref, child) {
                final workspacesAsync = ref.watch(workspacesListProvider);
                return workspacesAsync.when(
                  data: (workspaces) {
                    return Column(
                      children: workspaces.map((workspace) {
                        final letter = workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : 'W';
                        final color = workspace.color != null
                            ? Color(int.parse(workspace.color!.replaceAll('#', '0xFF')))
                            : AppColors.primary;
                        return GestureDetector(
                          onTap: () async {
                            try {
                              await ref.read(workspacesRepositoryProvider).switchWorkspace(workspace.id);
                              await ref.read(authStateNotifierProvider.notifier).refreshMemberships();
                              ref.invalidate(dashboardStatsProvider);
                              ref.invalidate(myTasksProvider);
                              ref.invalidate(unreadNotificationsCountProvider);
                              ref.invalidate(notificationsListProvider);
                              ref.read(teamsStateNotifierProvider.notifier).loadTeams();
                            } catch (_) {}
                          },
                          child: _buildWorkspaceItem(letter, workspace.name, color),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),

            const Spacer(),

            const Divider(color: AppColors.border, height: 1),

            // User row
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authStateNotifierProvider);
                final name = authState.user?.name ?? 'User';
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      AppAvatar(
                        name: name,
                        size: 32,
                      ),
                      if (!isIconOnly) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: AppColors.muted,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
