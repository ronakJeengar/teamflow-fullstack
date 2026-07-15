import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';
import 'package:teamflow_mobile/core/widgets/sidebar.dart';
import 'package:teamflow_mobile/core/navigation/navigation_helper.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import 'package:teamflow_mobile/core/di/injection.dart';
import 'package:teamflow_mobile/core/services/api_service.dart';
import '../../features/search/presentation/widgets/search_dialog.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../../features/dashboard/presentation/providers/workspaces_providers.dart';
import '../../features/dashboard/presentation/providers/stats_providers.dart';
import '../../features/teams/presentation/providers/teams_providers.dart';
import '../../features/auth/presentation/providers/providers.dart';
import '../../features/tasks/presentation/providers/task_providers.dart';
import '../../features/dashboard/presentation/widgets/create_workspace_sheet.dart';
import '../../features/dashboard/presentation/widgets/workspace_settings_sheet.dart';
import '../../features/dashboard/data/models/workspace_model.dart';

import '../../features/dashboard/presentation/providers/workspace_controller.dart';

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

    final isApiRegistered = GetIt.instance.isRegistered<ApiService>();
    final syncNotifier = isApiRegistered
        ? sl<ApiService>().syncStatusNotifier
        : ValueNotifier<SyncStatus>(SyncStatus.synced);

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
                  GestureDetector(
                    onTap: () => _showSyncStatusDialog(context),
                    child: ValueListenableBuilder<SyncStatus>(
                      valueListenable: syncNotifier,
                      builder: (context, status, _) {
                        IconData icon;
                        Color color;
                        String tooltip;

                        switch (status) {
                          case SyncStatus.synced:
                            icon = Icons.cloud_done_rounded;
                            color = AppColors.success;
                            tooltip = 'Synced';
                            break;
                          case SyncStatus.pending:
                            icon = Icons.cloud_queue_rounded;
                            color = AppColors.warning;
                            tooltip = 'Pending sync';
                            break;
                          case SyncStatus.retrying:
                            return const Padding(
                              padding: EdgeInsets.only(right: 14.0),
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                              ),
                            );
                          case SyncStatus.offline:
                            icon = Icons.cloud_off_rounded;
                            color = AppColors.danger;
                            tooltip = 'Offline';
                            break;
                        }

                        return Tooltip(
                          message: tooltip,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: Icon(icon, size: 20, color: color),
                          ),
                        );
                      },
                    ),
                  ),
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

  void _showSyncStatusDialog(BuildContext context) async {
    final apiService = sl<ApiService>();
    final queued = await apiService.getQueuedMutations();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Sync Engine & Offline status',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${apiService.syncStatusNotifier.value.name.toUpperCase()}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: apiService.syncStatusNotifier.value == SyncStatus.synced
                      ? AppColors.success
                      : apiService.syncStatusNotifier.value == SyncStatus.pending
                          ? AppColors.warning
                          : AppColors.danger,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Queued offline changes: ${queued.length}',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
              if (queued.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: queued.length,
                    itemBuilder: (context, idx) {
                      final item = queued[idx];
                      return ListTile(
                        dense: true,
                        title: Text(
                          '${item['method']} ${item['path']}',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          'Time: ${item['timestamp']}',
                          style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (queued.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await apiService.clearQueue();
                  Navigator.of(context).pop();
                  showAppSnackBar(context, 'Sync queue cleared.');
                },
                child: Text('Clear Queue', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 13)),
              ),
            TextButton(
              onPressed: () {
                apiService.syncOfflineMutations();
                Navigator.of(context).pop();
              },
              child: Text('Sync Now', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            ),
          ],
        );
      },
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
                            return _buildWorkspaceTile(context, ref, workspace, letter, color);
                          }),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.border),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Close switcher
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const CreateWorkspaceSheet(),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primary),
                          label: Text(
                            'Create Workspace',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 150,
                  child: Center(child: TeamFlowLoader(size: 32)),
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
    WorkspaceModel workspace,
    String letter,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
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
              workspace.name,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
            ),
             onTap: () async {
               final navigator = Navigator.of(context);
               navigator.pop();
               final success = await ref
                   .read(workspaceControllerProvider.notifier)
                   .switchWorkspace(workspace.id);
               if (success && context.mounted) {
                 showAppSnackBar(context, 'Switched to ${workspace.name}');
                 NavigationHelper.instance.goToHome();
               } else if (context.mounted) {
                 showAppSnackBar(context, 'Failed to switch workspace');
               }
             },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 18, color: AppColors.textSecondary),
          onPressed: () {
            Navigator.pop(context); // Close switcher
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => WorkspaceSettingsSheet(workspace: workspace),
            );
          },
        ),
      ],
    );
  }
}
