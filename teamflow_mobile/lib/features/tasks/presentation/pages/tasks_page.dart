import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/ui/app_tokens.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../../core/widgets/task_card.dart';
import '../../../auth/presentation/widgets/logout_modal.dart';
import '../../data/models/task_model.dart';
import '../../domain/entitties/task_entity.dart';
import '../providers/task_providers.dart';
import '../widget/create_task_sheet.dart';
import '../widget/delete_task_sheet.dart';
import '../widget/edit_task_sheet.dart';
import 'package:teamflow_mobile/features/auth/presentation/providers/providers.dart';
import 'package:teamflow_mobile/features/auth/domain/entities/membership_entity.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_member_entity.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/team_details_providers.dart';

class _ColumnConfig {
  final String title;
  final String subtitle;
  final String emoji;
  final TaskStatus status;
  final Color accent;
  final Color accentSurface;
  final Color accentMuted;
  final IconData icon;

  const _ColumnConfig({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.status,
    required this.accent,
    required this.accentSurface,
    required this.accentMuted,
    required this.icon,
  });
}

const _columns = [
  _ColumnConfig(
    title: 'To Do',
    subtitle: 'Not started',
    emoji: '○',
    status: TaskStatus.TODO,
    accent: Color(0xFF687280),
    accentSurface: Color(0x1A687280),
    accentMuted: Color(0xFF1F2430),
    icon: Icons.circle_outlined,
  ),
  _ColumnConfig(
    title: 'In Progress',
    subtitle: 'Active now',
    emoji: '◑',
    status: TaskStatus.IN_PROGRESS,
    accent: Color(0xFFF59E0B),
    accentSurface: Color(0x1AF59E0B),
    accentMuted: Color(0xFF1F2430),
    icon: Icons.timelapse_rounded,
  ),
  _ColumnConfig(
    title: 'Done',
    subtitle: 'Completed',
    emoji: '●',
    status: TaskStatus.DONE,
    accent: Color(0xFF22C55E),
    accentSurface: Color(0x1A22C55E),
    accentMuted: Color(0xFF1F2430),
    icon: Icons.check_circle_outline_rounded,
  ),
];

class TasksPage extends HookConsumerWidget {
  final String projectId;
  final String teamId;

  const TasksPage({super.key, required this.projectId, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final memberships = authState.memberships;

    useEffect(() {
      Future.microtask(() {
        ref.read(taskStateNotifierProvider.notifier).loadTasks(projectId);
      });
      return null;
    }, [projectId]);

    final state = ref.watch(taskStateNotifierProvider);
    final activeTab = useState(0);
    final dragTarget = useState<int?>(null);

    // Direct lookup using the passed teamId — no reverse project search needed
    final membership = memberships.firstWhere(
          (m) => m.team.id == teamId,
      orElse: () => const MembershipEntity(
        role: 'VIEWER',
        team: MembershipTeamEntity(id: '', name: ''),
      ),
    );

    final userRole = membership.role.toUpperCase();
    final isViewer = userRole == 'VIEWER';
    final screenWidth = MediaQuery.of(context).size.width;

    final tasksByStatus = [
      state.tasks.where((e) => e.status == TaskStatus.TODO || e.status == TaskStatus.BLOCKED).toList(),
      state.tasks.where((e) => e.status == TaskStatus.IN_PROGRESS || e.status == TaskStatus.REVIEW).toList(),
      state.tasks.where((e) => e.status == TaskStatus.DONE).toList(),
    ];

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
            activeTab: activeTab.value,
            counts: tasksByStatus.map((l) => l.length).toList(),
            dragTarget: dragTarget.value,
            isViewer: isViewer,
            onTabChanged: (i) {
              activeTab.value = i;
              HapticFeedback.selectionClick();
            },
            onDragOver: (i) => dragTarget.value = i,
            onDragLeft: () => dragTarget.value = null,
            onDropped: isViewer ? (_, __) {} : (task, i) {
              dragTarget.value = null;
              final newStatus = _columns[i].status;
              if (task.status == newStatus) return;

              // Verify permission
              final currentUserId = ref.read(authStateNotifierProvider).user?.id ?? '';
              final isOwnerOrAdminOrManager = ['OWNER', 'ADMIN', 'MANAGER'].contains(userRole);
              final isAssignee = task.assignedToId == currentUserId;

              if (!isOwnerOrAdminOrManager && !isAssignee) {
                showAppSnackBar(context, "You don't have permission to modify this task");
                return;
              }

              activeTab.value = i;
              ref
                  .read(updateTaskControllerProvider.notifier)
                  .moveTask(taskId: task.id, newStatus: newStatus);
            },
            onLogoutTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => const LogoutSheet(),
            ),
          ),
          Expanded(
            child: _Body(
              config: _columns[activeTab.value],
              tasks: tasksByStatus[activeTab.value],
              tabKey: activeTab.value,
              userRole: userRole,
              teamId: teamId,
            ),
          ),
        ],
      ),
      floatingActionButton: (screenWidth < 768 && !isViewer)
          ? _Fab(projectId: projectId, teamId: teamId)
          : null,
    );
  }
}

class _TopBar extends StatelessWidget {
  final int activeTab;
  final List<int> counts;
  final int? dragTarget;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<int> onDragOver;
  final VoidCallback onDragLeft;
  final VoidCallback onLogoutTap;
  final void Function(TaskEntity, int) onDropped;
  final bool isViewer;

  const _TopBar({
    required this.activeTab,
    required this.counts,
    required this.dragTarget,
    required this.onTabChanged,
    required this.onDragOver,
    required this.onDragLeft,
    required this.onDropped,
    required this.onLogoutTap,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final col = _columns[activeTab];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        border: Border(
          bottom: BorderSide(color: AppTokens.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: top + AppTokens.s16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: AppTokens.s16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(parent: anim, curve: Curves.easeOut),
                            ),
                            child: child,
                          ),
                        ),
                        child: _StatusPill(config: col, key: ValueKey(activeTab)),
                      ),

                      SizedBox(height: AppTokens.s8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOut,
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.12),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(parent: anim, curve: Curves.easeOut),
                                  ),
                                  child: child,
                                ),
                              ),
                              child: Text(
                                col.title,
                                key: ValueKey('title_$activeTab'),
                                style: AppTokens.displayLg,
                              ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            transitionBuilder: (c, a) =>
                                ScaleTransition(scale: a, child: c),
                            child: Text(
                              '${counts[activeTab]}',
                              key: ValueKey('cnt_$activeTab${counts[activeTab]}'),
                              style: GoogleFonts.inter(
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                color: col.accent.withOpacity(0.10),
                                letterSpacing: -2,
                                height: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppTokens.s4),
                      Text(col.subtitle, style: AppTokens.bodySm),
                    ],
                  ),
                ),

                SizedBox(width: AppTokens.s16),
                AppIconButton(icon: Icons.logout_rounded, onTap: onLogoutTap),
              ],
            ),
          ),

          SizedBox(height: AppTokens.s24),

          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.s20),
              itemCount: _columns.length,
              separatorBuilder: (_, __) => SizedBox(width: AppTokens.s8),
              itemBuilder: (_, i) {
                final c = _columns[i];
                final isActive = activeTab == i;
                final isDragHover = dragTarget == i;

                return DragTarget<TaskEntity>(
                  onWillAcceptWithDetails: (d) {
                    if (isViewer) return false;
                    if (d.data.status == c.status) return false;
                    onDragOver(i);
                    return true;
                  },
                  onLeave: (_) => onDragLeft(),
                  onAcceptWithDetails: (d) {
                    HapticFeedback.mediumImpact();
                    onDropped(d.data, i);
                  },
                  builder: (_, candidates, __) {
                    final hovering = candidates.isNotEmpty || isDragHover;

                    return GestureDetector(
                      onTap: () => onTabChanged(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.s16,
                        ),
                        decoration: BoxDecoration(
                          color: hovering
                              ? c.accentSurface
                              : isActive
                              ? AppTokens.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTokens.r8),
                          border: Border.all(
                            color: hovering
                                ? c.accent
                                : isActive
                                ? AppTokens.brand
                                : AppTokens.border,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                hovering ? Icons.add_circle_rounded : c.icon,
                                key: ValueKey(hovering),
                                size: 15,
                                color: isActive && !hovering
                                    ? AppTokens.brand
                                    : hovering
                                    ? c.accent
                                    : AppTokens.textSecondary,
                              ),
                            ),
                            SizedBox(width: AppTokens.s6),
                            Text(
                              c.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                                color: isActive && !hovering
                                    ? AppTokens.textPrimary
                                    : hovering
                                    ? c.accent
                                    : AppTokens.textSecondary,
                              ),
                            ),
                            SizedBox(width: AppTokens.s8),
                            _CountBadge(
                              count: counts[i],
                              isActive: isActive && !hovering,
                              color: c.accent,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SizedBox(height: AppTokens.s20),
          Container(height: 1, color: AppTokens.border),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _ColumnConfig config;

  const _StatusPill({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s10,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: config.accentSurface,
        borderRadius: BorderRadius.circular(AppTokens.r8),
        border: Border.all(color: config.accent.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.accent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTokens.s6),
          Text(
            config.title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: config.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool isActive;
  final Color color;

  const _CountBadge({
    required this.count,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s6,
        vertical: AppTokens.s2,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppTokens.brand.withOpacity(0.1)
            : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isActive ? AppTokens.brand : color,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final _ColumnConfig config;
  final List<TaskEntity> tasks;
  final int tabKey;
  final String userRole;
  final String teamId;

  const _Body({
    required this.config,
    required this.tasks,
    required this.tabKey,
    required this.userRole,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return _EmptyState(config: config);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: ListView.builder(
        key: ValueKey('list_$tabKey'),
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s20,
          AppTokens.s20,
          AppTokens.s20,
          110,
        ),
        itemCount: tasks.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.s12),
          child: _DraggableCard(
            task: tasks[i],
            index: i,
            accentColor: config.accent,
            userRole: userRole,
            teamId: teamId,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _ColumnConfig config;

  const _EmptyState({required this.config});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: config.icon,
      title: 'Nothing here yet',
      subtitle: 'Tasks in "${config.title}" will appear here.\nDrag cards from other columns to move them.',
    );
  }
}

class _Fab extends StatelessWidget {
  final String projectId;
  final String teamId;

  const _Fab({required this.projectId, required this.teamId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CreateTaskSheet(projectId: projectId, teamId: teamId),
        );
      },
      backgroundColor: AppTokens.brand,
      elevation: 0,
      shape: const CircleBorder(),
      child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
    );
  }
}

class _DraggableCard extends ConsumerStatefulWidget {
  final TaskEntity task;
  final int index;
  final Color accentColor;
  final String userRole;
  final String teamId;

  const _DraggableCard({
    required this.task,
    required this.index,
    required this.accentColor,
    required this.userRole,
    required this.teamId,
  });

  @override
  ConsumerState<_DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends ConsumerState<_DraggableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showEdit(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EditTaskSheet(task: widget.task, projectId: widget.task.projectId, teamId: widget.teamId),
  );

  void _showDelete(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DeleteTaskSheet(task: widget.task, projectId: widget.task.projectId),
  );

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authStateNotifierProvider).user?.id ?? '';
    final role = widget.userRole.toUpperCase();
    final isOwnerOrAdminOrManager = ['OWNER', 'ADMIN', 'MANAGER'].contains(role);
    final isAssignee = widget.task.assignedToId == currentUserId;

    final canEdit = isOwnerOrAdminOrManager || isAssignee;
    final canDelete = isOwnerOrAdminOrManager; // Remove creator ownership
    final isViewer = role == 'VIEWER';

    final teamDetailState = ref.watch(teamDetailStateNotifierProvider);
    final assigneeMember = teamDetailState.members.cast<TeamMemberEntity?>().firstWhere(
      (m) => m?.userId == widget.task.assignedToId,
      orElse: () => null,
    );
    final assigneeName = assigneeMember?.user?.name;

    final cardContent = TaskCard(
      task: widget.task,
      canEdit: canEdit,
      canDelete: canDelete,
      assigneeName: assigneeName,
      onEdit: () => _showEdit(context),
      onDelete: () => _showDelete(context),
      onCheckboxChanged: (checked) {
        if (!canEdit) {
          showAppSnackBar(context, "You don't have permission to modify this task");
          return;
        }
        final newStatus = checked ? TaskStatus.DONE : TaskStatus.TODO;
        ref
            .read(updateTaskControllerProvider.notifier)
            .moveTask(taskId: widget.task.id, newStatus: newStatus);
      },
    );

    if (isViewer) {
      return cardContent;
    }

    return LongPressDraggable<TaskEntity>(
      data: widget.task,
      delay: const Duration(milliseconds: 300),
      onDragStarted: () {
        HapticFeedback.selectionClick();
        _ctrl.forward();
      },
      onDraggableCanceled: (_, __) => _ctrl.reverse(),
      onDragEnd: (_) => _ctrl.reverse(),
      feedback: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - (AppTokens.s20 * 2),
            child: Transform.scale(
              scale: 1.03,
              child: TaskCard(
                task: widget.task,
                isFloating: true,
                canEdit: false,
                canDelete: false,
                assigneeName: assigneeName,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: FadeTransition(opacity: _opacity, child: cardContent),
      child: ScaleTransition(scale: _scale, child: cardContent),
    );
  }
}