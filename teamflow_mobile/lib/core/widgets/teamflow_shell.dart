import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';
import 'package:teamflow_mobile/core/widgets/sidebar.dart';
import 'package:teamflow_mobile/core/navigation/navigation_helper.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import '../../features/search/presentation/widgets/search_dialog.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../../features/dashboard/presentation/providers/workspaces_providers.dart';
import '../../features/dashboard/presentation/providers/stats_providers.dart';
import '../../features/teams/presentation/providers/teams_providers.dart';
import '../../features/auth/presentation/providers/providers.dart';
import '../../features/tasks/presentation/providers/task_providers.dart';

class TeamFlowShell extends ConsumerStatefulWidget {
  final Widget child;
  final String activeTab; // 'Inbox' | 'My Work' | 'Projects' | 'Teams' | 'More'

  const TeamFlowShell({
    super.key,
    required this.child,
    required this.activeTab,
  });

  @override
  ConsumerState<TeamFlowShell> createState() => _TeamFlowShellState();
}

class _TeamFlowShellState extends ConsumerState<TeamFlowShell> with WidgetsBindingObserver {
  void _onNavigationSelect(BuildContext context, String item) {
    if (item == widget.activeTab) return;
    
    switch (item) {
      case 'Inbox':
        NavigationHelper.instance.goToInvitations();
        break;
      case 'My Work':
        NavigationHelper.instance.goToHome();
        break;
      case 'Projects':
        NavigationHelper.instance.goToProjects();
        break;
      case 'Teams':
        NavigationHelper.instance.goToTeams();
        break;
      case 'More':
      case 'Settings':
        NavigationHelper.instance.goToSettings();
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      if (mounted) {
        ref.read(unreadNotificationsCountProvider.notifier).loadUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[App Resumed] Refreshing unread notifications count');
      ref.read(unreadNotificationsCountProvider.notifier).loadUnreadCount();
      ref.read(teamsStateNotifierProvider.notifier).loadTeams();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            Sidebar(
              activeItem: widget.activeTab,
              onItemSelect: (item) => _onNavigationSelect(context, item),
              isIconOnly: width <= 1000, // collapse sidebar to icon-only on tablet width
              onSearchTap: () => _showSearchDialog(context),
            ),
            Expanded(
              child: widget.child,
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          height: 52 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title + Chevron
              GestureDetector(
                onTap: () {
                  _showWorkspaceSwitcher(context, ref);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.activeTab,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              // Right Actions: bell + New
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ref.watch(unreadNotificationsCountProvider) > 0
                      ? Badge(
                          label: Text('${ref.watch(unreadNotificationsCountProvider)}'),
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                              color: AppColors.muted,
                            ),
                            onPressed: () {
                              NavigationHelper.instance.goToInvitations();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            size: 20,
                            color: AppColors.muted,
                          ),
                          onPressed: () {
                            NavigationHelper.instance.goToInvitations();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      showAppSnackBar(context, 'Creating quick item...');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      '+ New',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
      bottomNavigationBar: Container(
        height: 56 + MediaQuery.of(context).padding.bottom,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(context, 'Inbox', Icons.inbox_rounded),
            _buildBottomNavItem(context, 'My Work', Icons.check_circle_outline_rounded),
            _buildBottomNavItem(context, 'Projects', Icons.folder_open_rounded),
            _buildBottomNavItem(context, 'Teams', Icons.people_outline_rounded),
            _buildBottomNavItem(context, 'More', Icons.more_horiz_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, String tabName, IconData icon) {
    final isActive = widget.activeTab == tabName;
    final color = isActive ? AppColors.primary : AppColors.muted;

    Widget iconWidget = Icon(icon, size: 22, color: color);

    if (tabName == 'Inbox') {
      final unreadCount = ref.watch(unreadNotificationsCountProvider);
      if (unreadCount > 0) {
        iconWidget = Badge(
          label: Text('$unreadCount'),
          child: iconWidget,
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onNavigationSelect(context, tabName),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 2),
            Text(
              tabName,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SearchDialog(),
    );
  }

  void _showWorkspaceSwitcher(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              final workspacesAsync = ref.watch(workspacesListProvider);

              return workspacesAsync.when(
                data: (list) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Switch Workspace',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (list.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No workspaces found',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          ...list.map((workspace) {
                            final letter = workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : 'W';
                            final color = workspace.color != null
                                ? Color(int.parse(workspace.color!.replaceAll('#', '0xFF')))
                                : AppColors.primary;
                            return _buildWorkspaceTile(context, ref, workspace.name, letter, color, workspace.id);
                          }),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading workspaces', style: GoogleFonts.inter(color: AppColors.danger)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkspaceTile(
    BuildContext context,
    WidgetRef ref,
    String name,
    String letter,
    Color color,
    String workspaceId,
  ) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      ),
      onTap: () async {
        final navigator = Navigator.of(context);
        navigator.pop();
        try {
          await ref.read(workspacesRepositoryProvider).switchWorkspace(workspaceId);
          if (context.mounted) {
            showAppSnackBar(context, 'Switched to $name');
          }
          await ref.read(authStateNotifierProvider.notifier).refreshMemberships();
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(myTasksProvider);
          ref.invalidate(unreadNotificationsCountProvider);
          ref.invalidate(notificationsListProvider);
          ref.read(teamsStateNotifierProvider.notifier).loadTeams();
        } catch (e) {
          if (context.mounted) {
            showAppSnackBar(context, 'Failed to switch workspace');
          }
        }
      },
    );
  }
}
